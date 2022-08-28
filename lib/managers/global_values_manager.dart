import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quid_faciam_hodie/models/settings.dart';

class GlobalValuesManager {
  static Future? _settingsInitializationFuture;
  static List<CameraDescription> _cameras = [];
  static Settings? _settings;

  static List<CameraDescription> get cameras => [..._cameras];
  static Settings? get settings => _settings;

  static void setCameras(List<CameraDescription> cameras) {
    if (_cameras.isNotEmpty) {
      return;
    }

    _cameras = cameras;
  }

  static void _initializeSettings() {
    _settingsInitializationFuture = Settings.restore()
      ..then((settings) {
        _settings = settings;
        _settingsInitializationFuture = null;
      });
  }

  static void initialize() {
    _initializeSettings();
  }

  static Future<void> waitForInitialization() async {
    // Settings initialization
    if (_settingsInitializationFuture == null) {
      if (_settings == null) {
        throw Exception('Settings have not been initialized yet');
      } else {
        return;
      }
    } else {
      await _settingsInitializationFuture;
    }
  }

  static Future<bool> hasGrantedPermissions() async =>
      (await Permission.camera.isGranted) &&
      (await Permission.microphone.isGranted) &&
      (await Permission.location.isGranted);
}
