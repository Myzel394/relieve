import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/screens/main_screen.dart';

import 'grant_permission_screen/permissions_required_page.dart';

class GrantPermissionScreen extends StatelessWidget {
  static const ID = '/grant_permission';

  const GrantPermissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(localizations.grantPermissionScreenTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(MEDIUM_SPACE),
        child: Center(
          child: PermissionsRequiredPage(
            onPermissionsGranted: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                MainScreen.ID,
                (route) => false,
              );
            },
          ),
        ),
      ),
    );
  }
}
