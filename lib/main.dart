import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/themes.dart';
import 'package:quid_faciam_hodie/managers/startup_page_manager.dart';
import 'package:quid_faciam_hodie/screens/calendar_screen.dart';
import 'package:quid_faciam_hodie/screens/grant_permission_screen.dart';
import 'package:quid_faciam_hodie/screens/login_screen.dart';
import 'package:quid_faciam_hodie/screens/main_screen.dart';
import 'package:quid_faciam_hodie/screens/settings_screen.dart';
import 'package:quid_faciam_hodie/screens/timeline_screen.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen.dart';

import 'managers/global_values_manager.dart';
import 'models/memories.dart';
import 'screens/empty_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  GlobalValuesManager.initialize();

  final initialPage = await StartupPageManager.getPageWithFallback();

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final String initialPage;

  const MyApp({
    required this.initialPage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Memories(),
      child: PlatformApp(
        title: 'Relieve',
        material: (_, __) => MaterialAppData(
          theme: LIGHT_THEME_MATERIAL,
          darkTheme: DARK_THEME_MATERIAL,
          themeMode: ThemeMode.system,
        ),
        cupertino: (_, __) => CupertinoAppData(
          theme: LIGHT_THEME_CUPERTINO,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          WelcomeScreen.ID: (context) => const WelcomeScreen(),
          MainScreen.ID: (context) => const MainScreen(),
          LoginScreen.ID: (context) => const LoginScreen(),
          TimelineScreen.ID: (context) => const TimelineScreen(),
          GrantPermissionScreen.ID: (context) => const GrantPermissionScreen(),
          CalendarScreen.ID: (context) => const CalendarScreen(),
          EmptyScreen.ID: (context) => const EmptyScreen(),
          SettingsScreen.ID: (context) => const SettingsScreen(),
        },
        initialRoute: initialPage,
      ),
    );
  }
}
