import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/widgets/icon_button_child.dart';

class PermissionsRequiredPage extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionsRequiredPage({
    Key? key,
    required this.onPermissionsGranted,
  }) : super(key: key);

  @override
  State<PermissionsRequiredPage> createState() =>
      _PermissionsRequiredPageState();
}

class _PermissionsRequiredPageState extends State<PermissionsRequiredPage> {
  bool hasDeniedForever = false;
  bool hasGrantedCameraPermission = false;
  bool hasGrantedMicrophonePermission = false;
  bool hasGrantedLocationPermission = false;
  bool hasGrantedMediaPermission = false;

  bool get hasGrantedRequiredPermissions =>
      hasGrantedCameraPermission && hasGrantedMicrophonePermission;

  bool get hasGrantedAllPermissions =>
      hasGrantedRequiredPermissions &&
      hasGrantedLocationPermission &&
      (isMaterial(context) ||
          (isCupertino(context) && hasGrantedMediaPermission));

  @override
  void initState() {
    super.initState();

    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    final locationStatus = await Permission.location.status;
    final mediaLocationStatus = await Permission.photosAddOnly.status;

    setState(() {
      hasGrantedCameraPermission = cameraStatus.isGranted;
      hasGrantedMicrophonePermission = microphoneStatus.isGranted;
      hasGrantedLocationPermission = locationStatus.isGranted;
      hasGrantedMediaPermission = mediaLocationStatus.isGranted;
    });

    // These permissions are crucially required for the app to work
    if (cameraStatus.isPermanentlyDenied ||
        microphoneStatus.isPermanentlyDenied) {
      setState(() {
        hasDeniedForever = true;
      });

      return;
    }

    if (hasGrantedAllPermissions) {
      widget.onPermissionsGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          localizations.permissionsRequiredPageTitle,
          style: platformThemeData(
            context,
            material: (data) => data.textTheme.headline1,
            cupertino: (data) => data.textTheme.navLargeTitleTextStyle,
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        Text(
          localizations.permissionsRequiredPageDescription,
          style: platformThemeData(
            context,
            material: (data) => data.textTheme.bodyText1,
            cupertino: (data) => data.textTheme.textStyle,
          ),
        ),
        const SizedBox(height: LARGE_SPACE),
        if (hasDeniedForever) ...[
          Text(localizations.permissionsRequiredPagePermanentlyDenied),
          const SizedBox(height: LARGE_SPACE),
          PlatformElevatedButton(
            onPressed: () => openAppSettings(),
            child: IconButtonChild(
              icon: Icon(context.platformIcons.settings),
              label: Text(localizations.permissionsRequiredPageOpenSettings),
            ),
          ),
        ] else ...[
          Text(
            localizations.permissionsRequiredPageRequiredPermissionsLabel,
            style: platformThemeData(
              context,
              material: (data) => data.textTheme.caption!,
              cupertino: (data) => data.textTheme.navTitleTextStyle,
            ),
          ),
          const SizedBox(height: SMALL_SPACE),
          const Divider(),
          const SizedBox(height: SMALL_SPACE),
          PlatformTextButton(
            onPressed: hasGrantedCameraPermission
                ? null
                : () async {
                    await Permission.camera.request();
                    await checkPermissions();
                  },
            child: IconButtonChild(
              icon: Icon(context.platformIcons.photoCamera),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    localizations.permissionsRequiredPageGrantCameraPermission,
                  ),
                  if (hasGrantedCameraPermission)
                    Icon(context.platformIcons.checkMark),
                  if (!hasGrantedCameraPermission) const SizedBox(),
                ],
              ),
            ),
          ),
          const SizedBox(height: SMALL_SPACE),
          PlatformTextButton(
            onPressed: hasGrantedMicrophonePermission
                ? null
                : () async {
                    await Permission.microphone.request();
                    await checkPermissions();
                  },
            child: IconButtonChild(
              icon: Icon(context.platformIcons.mic),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    localizations
                        .permissionsRequiredPageGrantMicrophonePermission,
                  ),
                  if (hasGrantedMicrophonePermission)
                    Icon(context.platformIcons.checkMark),
                  if (!hasGrantedMicrophonePermission) const SizedBox(),
                ],
              ),
            ),
          ),
          const SizedBox(height: LARGE_SPACE),
          Text(
            localizations.permissionsRequiredPageOptionalPermissionsLabel,
            style: platformThemeData(
              context,
              material: (data) => data.textTheme.caption!,
              cupertino: (data) => data.textTheme.navTitleTextStyle,
            ),
          ),
          const SizedBox(height: SMALL_SPACE),
          const Divider(),
          const SizedBox(height: SMALL_SPACE),
          PlatformTextButton(
            onPressed: hasGrantedLocationPermission
                ? null
                : () async {
                    await Permission.location.request();
                    await checkPermissions();
                  },
            child: IconButtonChild(
              icon: Icon(context.platformIcons.location),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    localizations
                        .permissionsRequiredPageGrantLocationPermission,
                  ),
                  if (hasGrantedLocationPermission)
                    Icon(context.platformIcons.checkMark),
                  if (!hasGrantedLocationPermission) const SizedBox(),
                ],
              ),
            ),
          ),
          const SizedBox(height: SMALL_SPACE),
          if (isCupertino(context))
            PlatformTextButton(
              onPressed: hasGrantedMediaPermission
                  ? null
                  : () async {
                      await Permission.photosAddOnly.request();
                      await checkPermissions();
                    },
              child: IconButtonChild(
                icon: Icon(context.platformIcons.collections),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      localizations.permissionsRequiredPageGrantMediaPermission,
                    ),
                    if (hasGrantedMediaPermission)
                      Icon(context.platformIcons.checkMark),
                    if (!hasGrantedMediaPermission) const SizedBox(),
                  ],
                ),
              ),
            ),
        ],
        const SizedBox(height: LARGE_SPACE),
        PlatformElevatedButton(
          onPressed: hasGrantedRequiredPermissions
              ? widget.onPermissionsGranted
              : null,
          child: IconButtonChild(
            icon: Icon(context.platformIcons.forward),
            label: Text(localizations.generalContinueButtonLabel),
          ),
        ),
      ],
    );
  }
}
