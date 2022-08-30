import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:relieve/constants/storage_keys.dart';
import 'package:relieve/screens/welcome_screen.dart';

const storage = FlutterSecureStorage();

class StartupPageManager {
  static Future<String?> getPage() async => storage.read(key: STARTUP_PAGE_KEY);
  static Future<String> getPageWithFallback() async =>
      (await getPage()) ?? WelcomeScreen.ID;

  static Future<void> setPage(String page) async =>
      storage.write(key: STARTUP_PAGE_KEY, value: page);
}
