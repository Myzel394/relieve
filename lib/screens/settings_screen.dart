import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/enum_mapping/record_button_behavior/texts.dart';
import 'package:quid_faciam_hodie/enum_mapping/resolution_preset/texts.dart';
import 'package:quid_faciam_hodie/enums/record_button_behavior.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/managers/global_values_manager.dart';
import 'package:quid_faciam_hodie/managers/user_help_sheets_manager.dart';
import 'package:settings_ui/settings_ui.dart';

import 'settings_screen/dropdown_tile.dart';

const storage = FlutterSecureStorage();

class SettingsScreen extends StatefulWidget {
  static const ID = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? hasGrantedMediaAccess;

  @override
  void initState() {
    super.initState();

    final settings = GlobalValuesManager.settings!;

    // Update UI when settings change
    settings.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }
        checkMediaPermissionStatus();
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

  @override
  Widget build(BuildContext context) {
    final settings = GlobalValuesManager.settings!;
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
                localizations.settingsScreenGeneralSectionTitle,
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
                  initialValue: settings.saveToGallery,
                  onToggle: (newValue) async {
                    if (hasGrantedMediaAccess == false) {
                      final status = await Permission.photosAddOnly.request();

                      if (status.isGranted) {
                        setState(() {
                          hasGrantedMediaAccess = true;
                        });
                      }
                    }

                    if (hasGrantedMediaAccess == true) {
                      settings.setSaveToGallery(newValue);
                    }
                  },
                  title: Text(
                    localizations.settingsScreenSaveToGalleryLabel,
                  ),
                  enabled: hasGrantedMediaAccess != null,
                  description: hasGrantedMediaAccess == null
                      ? Text(
                          localizations.generalLoadingLabel,
                        )
                      : null,
                  leading: Icon(context.platformIcons.collections),
                ),
                SettingsTile.switchTile(
                  initialValue: settings.askForMemoryAnnotations,
                  onToggle: settings.setAskForMemoryAnnotations,
                  leading: Icon(context.platformIcons.pen),
                  title: Text(
                    localizations
                        .settingsScreenGeneralSectionAskForMemoryAnnotationsLabel,
                  ),
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
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
