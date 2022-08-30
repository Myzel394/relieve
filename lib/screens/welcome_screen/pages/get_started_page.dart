import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:relieve/constants/spacing.dart';
import 'package:relieve/managers/startup_page_manager.dart';
import 'package:relieve/screens/grant_permission_screen.dart';
import 'package:relieve/screens/main_screen.dart';
import 'package:relieve/screens/welcome_screen/crabs/logo.dart';
import 'package:relieve/utils/permissions.dart';
import 'package:relieve/utils/theme.dart';
import 'package:relieve/widgets/icon_button_child.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CrabLogo(),
            const SizedBox(height: LARGE_SPACE),
            Text(
              localizations.appTitleQuestion,
              style: getTitleTextStyle(context),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            Text(
              localizations.welcomeScreenGetStartedLabel,
              style: getSubTitleTextStyle(context),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            PlatformElevatedButton(
              child: IconButtonChild(
                icon: Icon(context.platformIcons.forward),
                label: Text(localizations.welcomeScreenStartButtonTitle),
              ),
              onPressed: () async {
                await StartupPageManager.setPage(MainScreen.ID);

                if (await hasGrantedRequiredPermissions()) {
                  Navigator.pushReplacementNamed(context, MainScreen.ID);
                } else {
                  Navigator.pushReplacementNamed(
                    context,
                    GrantPermissionScreen.ID,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
