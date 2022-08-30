import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:relieve/constants/help_sheet_id.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/constants/values.dart';
import 'package:relieve/extensions/snackbar.dart';
import 'package:relieve/foreign_types/memory.dart';
import 'package:relieve/foreign_types/memory_location.dart';
import 'package:relieve/managers/global_values_manager.dart';
import 'package:relieve/models/memories.dart';
import 'package:relieve/models/settings.dart';
import 'package:relieve/native_events/window_focus.dart';
import 'package:relieve/screens/main_screen/annotation_dialog.dart';
import 'package:relieve/screens/main_screen/camera_help_content.dart';
import 'package:relieve/screens/main_screen/cancel_recording_button.dart';
import 'package:relieve/screens/main_screen/settings_button_overlay.dart';
import 'package:relieve/screens/main_screen/zoom_level_overlay.dart';
import 'package:relieve/utils/format_zoom_level.dart';
import 'package:relieve/utils/loadable.dart';
import 'package:relieve/utils/tag_location_to_image.dart';
import 'package:relieve/widgets/animate_in_builder.dart';
import 'package:relieve/widgets/fade_and_move_in_animation.dart';
import 'package:relieve/widgets/help_sheet.dart';
import 'package:relieve/widgets/icon_button_child.dart';
import 'package:relieve/widgets/sheet_indicator.dart';

import 'main_screen/change_camera_button.dart';
import 'main_screen/record_button.dart';
import 'main_screen/recording_overlay.dart';
import 'main_screen/today_photo_button.dart';
import 'main_screen/uploading_photo.dart';

class MainScreen extends StatefulWidget {
  static const ID = '/main';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with Loadable {
  int currentZoomLevelIndex = 0;
  double currentCameraZoomLevel = 1.0;
  double baseZoomLevel = 1.0;

  bool hasRecordedOnStartup = false;
  bool isRecording = false;
  bool lockCamera = false;
  bool isTorchEnabled = false;
  Uint8List? uploadingPhotoAnimation;
  List<double>? zoomLevels;

  CameraController? controller;

  int getCurrentZoomLevelIndex() {
    int index = 0;

    // available zoom levels: [1, 2, 5, 10]
    // current zoom level: 3
    // current index should be `1`
    for (final zoomLevel in zoomLevels!) {
      if (zoomLevel == currentCameraZoomLevel) {
        return index;
      }

      if (zoomLevel > currentCameraZoomLevel) {
        return max(0, index - 1);
      }

      index++;
    }

    return zoomLevels!.length - 1;
  }

  @override
  bool get isLoading =>
      super.isLoading || controller == null || !controller!.value.isInitialized;

  @override
  void initState() {
    super.initState();

    loadSettings();
    onNewCameraSelected(GlobalValuesManager.cameras[0]);

    EventChannelWindowFocus.addListener(loadCameraIfNecessary);
  }

  @override
  void dispose() {
    controller?.dispose();
    EventChannelWindowFocus.removeListener(loadCameraIfNecessary);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _updateCamera(state);
  }

  void loadCameraIfNecessary(final bool isAppFocused) async {
    if (isAppFocused) {
      onNewCameraSelected(GlobalValuesManager.cameras[0]);
    } else {
      await cancelRecording();
      controller?.dispose();
      controller = null;
    }
  }

  Future<void> loadSettings() async {
    final settings = context.read<Settings>();

    settings.addListener(() {
      if (!mounted || controller == null) {
        return;
      }

      onNewCameraSelected(controller!.description);
    });
  }

  void _updateCamera(final AppLifecycleState state) async {
    // App state changed before we got the chance to initialize.
    if (controller == null || controller?.value.isInitialized != true) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      await cancelRecording();
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(
          controller?.description ?? GlobalValuesManager.cameras[0]);
    }
  }

  Future<void> startRecording() async {
    setState(() {
      isRecording = true;
    });

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    await controller!.startVideoRecording();
  }

  void onNewCameraSelected(final CameraDescription cameraDescription) async {
    final settings = context.read<Settings>();

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      settings.resolution,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    if (controller != null) {
      await controller?.dispose();

      setState(() {
        controller = null;
      });
    }

    try {
      await cameraController.initialize();
    } catch (error) {
      // Phone is off
      return;
    }

    controller = cameraController;

    // Update UI if controller updates
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    await controller!.prepareForVideoRecording();

    if (settings.recordOnStartup && !hasRecordedOnStartup) {
      startRecording();

      hasRecordedOnStartup = true;
    }

    await determineZoomLevels();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> determineZoomLevels() async {
    final minZoomLevel = await controller!.getMinZoomLevel();
    final maxZoomLevel = await controller!.getMaxZoomLevel();

    final availableZoomLevels = ([...DEFAULT_ZOOM_LEVELS]
            .where((zoomLevel) =>
                zoomLevel >= minZoomLevel && zoomLevel <= maxZoomLevel)
            .toSet()
          ..add(minZoomLevel)
          ..add(maxZoomLevel))
        .toList()
      ..sort();

    setState(() {
      zoomLevels = availableZoomLevels;
    });
  }

  Future<String?> _createAskAnnotationDialog() => showPlatformDialog(
        barrierDismissible: true,
        context: context,
        builder: (dialogContext) => const AnnotationDialog(),
      );

  void _lockCamera() => setState(() {
        lockCamera = true;
      });

  void _releaseCamera() => setState(() {
        lockCamera = false;
      });

  void _showUploadingPhotoAnimation(final File file) => setState(() {
        uploadingPhotoAnimation = file.readAsBytesSync();
      });

  void _releaseUploadingPhotoAnimation() => setState(() {
        uploadingPhotoAnimation = null;
      });

  Future<String?> getAnnotation() async {
    final settings = context.read<Settings>();

    if (settings.askForMemoryAnnotations) {
      return _createAskAnnotationDialog();
    } else {
      return '';
    }
  }

  Future<void> setFlashModeBeforeApplyingAction() async {
    if (isTorchEnabled) {
      await controller!.setFlashMode(FlashMode.torch);
    } else {
      await controller!.setFlashMode(FlashMode.off);
    }
  }

  Future<LocationData?> getLocation([
    final File? fileToTag,
  ]) async {
    if (!(await Permission.location.isGranted)) {
      return null;
    }

    final locationData = await Location().getLocation();

    if (fileToTag != null && Platform.isAndroid) {
      await tagLocationToImage(fileToTag, locationData);
    }

    return locationData;
  }

  Future<void> takePhoto() async {
    final settings = context.read<Settings>();
    final memories = context.read<Memories>();
    final localizations = AppLocalizations.of(context)!;

    if (controller!.value.isTakingPicture) {
      return;
    }

    _lockCamera();

    try {
      context.showPendingSnackBar(
        message: localizations.mainScreenTakePhotoActionTakingPhoto,
      );

      await setFlashModeBeforeApplyingAction();

      final file = File((await controller!.takePicture()).path);

      final locationData = await getLocation(file);
      final annotation = await getAnnotation();

      _showUploadingPhotoAnimation(file);

      if (!mounted) {
        return;
      }

      try {
        final memory = await Memory.createFromFile(
          file: file,
          location: locationData == null
              ? null
              : MemoryLocation.fromLocationData(locationData),
          annotation: annotation,
        );

        if (settings.saveToGallery) {
          await memory.saveFileToGallery();
        }

        await memories.addMemory(memory);
      } catch (error) {
        if (!mounted) {
          return;
        }

        context.showErrorSnackBar(message: error.toString());

        return;
      }

      if (!mounted) {
        return;
      }

      context.showSuccessSnackBar(
        message: localizations.mainScreenMemorySuccess,
      );
    } finally {
      _releaseCamera();
    }
  }

  Future<void> takeVideo() async {
    final settings = context.read<Settings>();
    final memories = context.read<Memories>();
    final localizations = AppLocalizations.of(context)!;

    if (!controller!.value.isRecordingVideo) {
      // Recording has already been stopped
      return;
    }

    setState(() {
      isRecording = false;
    });

    _lockCamera();

    try {
      context.showPendingSnackBar(
        message: localizations.mainScreenTakeVideoActionSaveVideo,
      );

      final file = File((await controller!.stopVideoRecording()).path);

      final annotation = await getAnnotation();
      final locationData = await getLocation();

      if (!mounted) {
        return;
      }

      try {
        final memory = await Memory.createFromFile(
          file: file,
          location: locationData == null
              ? null
              : MemoryLocation.fromLocationData(locationData),
          annotation: annotation,
        );

        if (settings.saveToGallery) {
          await memory.saveFileToGallery();
        }

        await memories.addMemory(memory);
      } catch (error) {
        if (!mounted) {
          return;
        }

        context.showErrorSnackBar(message: error.toString());

        return;
      }

      if (!mounted) {
        return;
      }

      context.showSuccessSnackBar(
        message: localizations.mainScreenMemorySuccess,
      );
    } finally {
      _releaseCamera();
    }
  }

  Future<void> cancelRecording() async {
    if (controller!.value.isRecordingVideo) {
      setState(() {
        isRecording = false;
      });

      await controller!.stopVideoRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        SystemNavigator.pop();
        exit(0);
      },
      child: PlatformScaffold(
        backgroundColor: Colors.black,
        body: () {
          if (isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PlatformCircularProgressIndicator(),
                  const SizedBox(height: MEDIUM_SPACE),
                  Text(
                    localizations.generalLoadingLabel,
                    style: platformThemeData(
                      context,
                      material: (data) => data.textTheme.bodyText1,
                      cupertino: (data) => data.textTheme.textStyle,
                    ),
                  ),
                ],
              ),
            );
          }

          return GestureDetector(
            onScaleEnd: (_) {
              baseZoomLevel = currentCameraZoomLevel;
            },
            onScaleUpdate: (details) {
              if (zoomLevels == null || controller == null) {
                return;
              }

              final newZoomLevel = double.parse(
                max(
                  zoomLevels!.first,
                  min(
                    zoomLevels!.last,
                    baseZoomLevel * details.scale,
                  ),
                ).toStringAsFixed(1),
              );

              setState(() {
                currentCameraZoomLevel = newZoomLevel;
              });

              if (controller != null) {
                controller!.setZoomLevel(newZoomLevel);
              }
            },
            child: HelpSheet(
              title: localizations.mainScreenHelpSheetTitle,
              helpContent: const CameraHelpContent(),
              helpID: HelpSheetID.mainScreen,
              child: Container(
                color: Colors.black,
                child: ExpandableBottomSheet(
                  background: SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: AnimateInBuilder(
                        builder: (showPreview) => AnimatedOpacity(
                          opacity: showPreview ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 1100),
                          curve: Curves.easeOutQuad,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(SMALL_SPACE),
                            child: AspectRatio(
                              aspectRatio: 1 / controller!.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.expand,
                                children: <Widget>[
                                  controller!.buildPreview(),
                                  ZoomLevelOverlay(
                                    zoomLevel: currentCameraZoomLevel,
                                  ),
                                  if (isRecording)
                                    RecordingOverlay(controller: controller!),
                                  if (!isRecording)
                                    const SettingsButtonOverlay(),
                                  if (uploadingPhotoAnimation != null)
                                    UploadingPhoto(
                                      data: uploadingPhotoAnimation!,
                                      onDone: _releaseUploadingPhotoAnimation,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  persistentHeader: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(LARGE_SPACE),
                        topRight: Radius.circular(LARGE_SPACE),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: MEDIUM_SPACE,
                            horizontal: MEDIUM_SPACE,
                          ),
                          child: SheetIndicator(),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: SMALL_SPACE),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: FadeAndMoveInAnimation(
                                  translationDuration:
                                      DEFAULT_TRANSLATION_DURATION *
                                          SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                                  opacityDuration: DEFAULT_OPACITY_DURATION *
                                      SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                                  child: isRecording
                                      ? CancelRecordingButton(
                                          onCancel: cancelRecording,
                                        )
                                      : ChangeCameraButton(
                                          disabled: lockCamera || isRecording,
                                          onChangeCamera: () {
                                            final currentCameraIndex =
                                                GlobalValuesManager.cameras
                                                    .indexOf(controller!
                                                        .description);
                                            final availableCameras =
                                                GlobalValuesManager
                                                    .cameras.length;

                                            onNewCameraSelected(
                                              GlobalValuesManager.cameras[
                                                  (currentCameraIndex + 1) %
                                                      availableCameras],
                                            );
                                          },
                                        ),
                                ),
                              ),
                              Expanded(
                                child: FadeAndMoveInAnimation(
                                  child: RecordButton(
                                    disabled: lockCamera,
                                    active: isRecording,
                                    onVideoBegin: startRecording,
                                    onVideoEnd: takeVideo,
                                    onPhotoShot: takePhoto,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FadeAndMoveInAnimation(
                                  translationDuration:
                                      DEFAULT_TRANSLATION_DURATION *
                                          SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                                  opacityDuration: DEFAULT_OPACITY_DURATION *
                                      SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                                  child: TodayPhotoButton(
                                    onLeave: () {
                                      controller!.setFlashMode(FlashMode.off);
                                    },
                                    onComeBack: () {
                                      if (isTorchEnabled) {
                                        controller!
                                            .setFlashMode(FlashMode.torch);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  expandableContent: Container(
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: LARGE_SPACE,
                        right: LARGE_SPACE,
                        bottom: MEDIUM_SPACE,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (_) => isTorchEnabled
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (_) => isTorchEnabled
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isTorchEnabled = !isTorchEnabled;

                                if (isTorchEnabled) {
                                  controller!.setFlashMode(FlashMode.torch);
                                } else {
                                  controller!.setFlashMode(FlashMode.off);
                                }
                              });
                            },
                            child: IconButtonChild(
                              icon: const Icon(Icons.flashlight_on_rounded),
                              label: Text(
                                  localizations.mainScreenActionsTorchButton),
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (_) => Colors.white10,
                              ),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                (_) => Colors.white,
                              ),
                            ),
                            onPressed: zoomLevels == null
                                ? null
                                : () {
                                    final currentZoomLevelIndex =
                                        getCurrentZoomLevelIndex();
                                    final newZoomLevelIndex =
                                        ((currentZoomLevelIndex + 1) %
                                            zoomLevels!.length);

                                    controller!.setZoomLevel(
                                        zoomLevels![newZoomLevelIndex]);

                                    setState(() {
                                      currentCameraZoomLevel =
                                          zoomLevels![newZoomLevelIndex];
                                    });
                                  },
                            child: zoomLevels == null
                                ? Text(formatZoomLevel(1.0))
                                : Text(
                                    formatZoomLevel(currentCameraZoomLevel),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }(),
      ),
    );
  }
}
