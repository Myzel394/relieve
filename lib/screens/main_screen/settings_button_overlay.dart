import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/screens/settings_screen.dart';

class SettingsButtonOverlay extends StatelessWidget {
  const SettingsButtonOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: SMALL_SPACE,
      top: SMALL_SPACE,
      child: PlatformIconButton(
        icon: Icon(
          context.platformIcons.settings,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushNamed(context, SettingsScreen.ID);
        },
      ),
    );
  }
}
