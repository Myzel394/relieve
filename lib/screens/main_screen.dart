import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/extensions/snackbar.dart';
import 'package:share_location/managers/file_manager.dart';
import 'package:share_location/managers/global_values_manager.dart';
import 'package:share_location/screens/main_screen/permissions_required_page.dart';
import 'package:share_location/utils/auth_required.dart';
import 'package:share_location/utils/loadable.dart';
import 'package:share_location/widgets/camera_button.dart';
import 'package:share_location/widgets/change_camera_button.dart';
import 'package:share_location/widgets/today_photo_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatefulWidget {
  static const ID = 'main';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends AuthRequiredState<MainScreen> with Loadable {
  bool isRecording = false;
  bool hasGrantedPermissions = false;
  List? lastPhoto;

  late User _user;

  CameraController? controller;

  @override
  bool get isLoading =>
      super.isLoading || controller == null || !controller!.value.isInitialized;

  @override
  void initState() {
    super.initState();

    callWithLoading(getLastPhoto);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void onAuthenticated(Session session) {
    final user = session.user;

    if (user != null) {
      _user = user;
    }
  }

  Future<void> getLastPhoto() async {
    final data = await FileManager.getLastFile(_user);

    setState(() {
      lastPhoto = data;
    });
  }

  void onNewCameraSelected(final CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    cameraController.setFlashMode(FlashMode.off);

    await previousCameraController?.dispose();

    controller = cameraController;

    // Update UI if controller updates
    controller!.addListener(() {
      if (mounted) setState(() {});
    });

    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> takePhoto() async {
    if (controller!.value.isTakingPicture) {
      return;
    }

    controller!.setFlashMode(FlashMode.off);
    final file = File((await controller!.takePicture()).path);

    try {
      await FileManager.uploadFile(_user, file);
    } catch (error) {
      if (mounted) {
        context.showErrorSnackBar(message: error.toString());
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo saved.'),
          backgroundColor: Colors.green,
        ),
      );

      await getLastPhoto();
    }
  }

  Future<void> takeVideo() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording has already been stopped
      return;
    }

    setState(() {
      isRecording = false;
    });

    final file = File((await controller!.stopVideoRecording()).path);

    try {
      await FileManager.uploadFile(_user, file);
    } catch (error) {
      if (mounted) {
        context.showErrorSnackBar(message: error.toString());
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video saved.'),
          backgroundColor: Colors.green,
        ),
      );
      await getLastPhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: () {
          if (!hasGrantedPermissions) {
            return Center(
              child: PermissionsRequiredPage(
                onPermissionsGranted: () {
                  onNewCameraSelected(GlobalValuesManager.cameras[0]);

                  setState(() {
                    hasGrantedPermissions = true;
                  });
                },
              ),
            );
          }

          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                controller!.buildPreview(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(LARGE_SPACE),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ChangeCameraButton(onChangeCamera: () {
                            final currentCameraIndex = GlobalValuesManager
                                .cameras
                                .indexOf(controller!.description);
                            final availableCameras =
                                GlobalValuesManager.cameras.length;

                            onNewCameraSelected(
                              GlobalValuesManager.cameras[
                                  (currentCameraIndex + 1) % availableCameras],
                            );
                          }),
                          CameraButton(
                            active: isRecording,
                            onVideoBegin: () async {
                              if (controller!.value.isRecordingVideo) {
                                // A recording has already started, do nothing.
                                return;
                              }

                              setState(() {
                                isRecording = true;
                              });

                              await controller!.startVideoRecording();
                            },
                            onVideoEnd: takeVideo,
                            onPhotoShot: takePhoto,
                          ),
                          lastPhoto == null
                              ? TodayPhotoButton()
                              : TodayPhotoButton(
                                  data: lastPhoto![0],
                                  type: lastPhoto![1],
                                ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        }(),
      ),
    );
  }
}
