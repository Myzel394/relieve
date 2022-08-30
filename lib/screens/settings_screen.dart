import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/enum_mapping/record_button_behavior/texts.dart';
import 'package:relieve/enum_mapping/resolution_preset/texts.dart';
import 'package:relieve/enums/record_button_behavior.dart';
import 'package:relieve/extensions/snackbar.dart';
import 'package:relieve/managers/user_help_sheets_manager.dart';
import 'package:relieve/models/settings.dart';
import 'package:settings_ui/settings_ui.dart';

import 'settings_screen/dropdown_tile.dart';
import 'support_screen.dart';

const storage = FlutterSecureStorage();

class SettingsScreen extends StatefulWidget {
  static const ID = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? hasGrantedMediaAccess;
  bool? hasGrantedLocationAccess;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }
        checkMediaPermissionStatus();
        checkLocationPermissionStatus();
      },
    );
  }

  Future<void> checkMediaPermissionStatus() async {
    if (isMaterial(context)) {
      setState(() {
        hasGrantedMediaAccess = true;
      });
    } else {
      final hasGranted = await Permission.photosAddOnly.isGranted;

      setState(() {
        hasGrantedMediaAccess = hasGranted;
      });
    }
  }

  Future<void> checkLocationPermissionStatus() async {
    final hasGranted = await Permission.location.isGranted;

    setState(() {
      hasGrantedLocationAccess = hasGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final localizations = AppLocalizations.of(context)!;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(localizations.settingsScreenTitle),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: isCupertino(context) ? LARGE_SPACE : 0),
        child: SettingsList(
          sections: [
            SettingsSection(
              title: Text(
                localizations.settingsScreenCameraBehaviorSectionTitle,
              ),
              tiles: [
                SettingsDropdownTile<ResolutionPreset>(
                  leading: const Icon(Icons.high_quality),
                  title: Text(
                    localizations.settingsScreenGeneralSectionQualityLabel,
                  ),
                  onUpdate: settings.setResolution,
                  textMapping: getResolutionTextMapping(context),
                  value: settings.resolution,
                  values: ResolutionPreset.values,
                ),
                SettingsDropdownTile<RecordButtonBehavior>(
                  leading: const Icon(Icons.fiber_manual_record),
                  title: Text(
                    localizations
                        .settingsScreenGeneralSectionRecordButtonBehaviorLabel,
                  ),
                  onUpdate: settings.setRecordButtonBehavior,
                  textMapping: getRecordButtonBehaviorTextMapping(context),
                  value: settings.recordButtonBehavior,
                  values: RecordButtonBehavior.values,
                ),
                SettingsTile.switchTile(
                  initialValue: settings.recordOnStartup,
                  onToggle: settings.setRecordOnStartup,
                  leading: Icon(context.platformIcons.photoCamera),
                  title: Text(
                    localizations
                        .settingsScreenGeneralSectionStartRecordingOnStartupLabel,
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text(
                localizations.settingsScreenMemorySectionTitle,
              ),
              tiles: [
                SettingsTile.switchTile(
                  initialValue: settings.saveToGallery,
                  onToggle: settings.setSaveToGallery,
                  title: Text(
                    localizations.settingsScreenMemorySectionSaveToGalleryLabel,
                  ),
                  enabled: hasGrantedMediaAccess != null,
                  description: hasGrantedMediaAccess == false
                      ? Text(
                          localizations.generalDeniedBecausePermissionIsMissing,
                        )
                      : null,
                  leading: Icon(context.platformIcons.collections),
                ),
                SettingsTile.switchTile(
                  enabled: hasGrantedLocationAccess == true,
                  initialValue: settings.tagWithLocation,
                  onToggle: settings.setTagWithLocation,
                  leading: Icon(context.platformIcons.location),
                  title: Text(
                    localizations
                        .settingsScreenMemorySectionTagWithLocationLabel,
                  ),
                  description: hasGrantedLocationAccess == false
                      ? Text(
                          localizations.generalDeniedBecausePermissionIsMissing)
                      : null,
                ),
                SettingsTile.switchTile(
                  initialValue: settings.askForMemoryAnnotations,
                  onToggle: settings.setAskForMemoryAnnotations,
                  leading: Icon(context.platformIcons.pen),
                  title: Text(
                    localizations
                        .settingsScreenMemorySectionAskForMemoryAnnotationsLabel,
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text(
                localizations.settingsScreenOtherSectionTitle,
              ),
              tiles: [
                SettingsTile(
                  leading: Icon(context.platformIcons.help),
                  title: Text(
                    localizations.settingsScreenResetHelpSheetsLabel,
                  ),
                  onPressed: (_) async {
                    await UserHelpSheetsManager.deleteAll();

                    if (!mounted) {
                      return;
                    }

                    context.showSuccessSnackBar(
                      message: localizations
                          .settingsScreenResetHelpSheetsResetSuccessfully,
                    );
                  },
                ),
                SettingsTile.navigation(
                  title: Text(localizations.supportScreenTitle),
                  onPressed: (_) =>
                      Navigator.pushNamed(context, SupportScreen.ID),
                  leading: Icon(context.platformIcons.favoriteSolid),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
