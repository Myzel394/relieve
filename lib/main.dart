import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:relieve/constants/themes.dart';
import 'package:relieve/managers/startup_page_manager.dart';
import 'package:relieve/screens/calendar_screen.dart';
import 'package:relieve/screens/grant_permission_screen.dart';
import 'package:relieve/screens/main_screen.dart';
import 'package:relieve/screens/settings_screen.dart';
import 'package:relieve/screens/support_screen.dart';
import 'package:relieve/screens/timeline_screen.dart';
import 'package:relieve/screens/welcome_screen.dart';

import 'managers/global_values_manager.dart';
import 'models/memories.dart';
import 'models/settings.dart';
import 'native_events/window_focus.dart';
import 'screens/empty_screen.dart';
import 'utils/permissions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await GlobalValuesManager.initialize();

  EventChannelWindowFocus.initialize();

  final initialPage = await StartupPageManager.getPageWithFallback();
  final hasGrantedPermissions = await hasGrantedRequiredPermissions();
  final memories = await Memories.restore();
  final settings = await Settings.restore();

  runApp(
    MyApp(
      initialPage: (initialPage != WelcomeScreen.ID && !hasGrantedPermissions)
          ? GrantPermissionScreen.ID
          : initialPage,
      memories: memories,
      settings: settings,
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialPage;
  final Memories memories;
  final Settings settings;

  const MyApp({
    required this.initialPage,
    required this.memories,
    required this.settings,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: memories),
        ChangeNotifierProvider.value(value: settings),
      ],
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
          TimelineScreen.ID: (context) => const TimelineScreen(),
          GrantPermissionScreen.ID: (context) => const GrantPermissionScreen(),
          CalendarScreen.ID: (context) => const CalendarScreen(),
          EmptyScreen.ID: (context) => const EmptyScreen(),
          SettingsScreen.ID: (context) => const SettingsScreen(),
          SupportScreen.ID: (context) => const SupportScreen(),
        },
        initialRoute: initialPage,
      ),
    );
  }
}
