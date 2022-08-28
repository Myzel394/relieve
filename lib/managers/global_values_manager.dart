import 'package:camera/camera.dart';
import 'package:quid_faciam_hodie/models/settings.dart';

class GlobalValuesManager {
  static List<CameraDescription> _cameras = [];
  static Settings? _settings;

  static List<CameraDescription> get cameras => [..._cameras];
  static Settings? get settings => _settings;

  static Future<void> initialize() async {
    _settings = await Settings.restore();
    _cameras = await availableCameras();
  }
}
