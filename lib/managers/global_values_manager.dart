import 'package:camera/camera.dart';

class GlobalValuesManager {
  static List<CameraDescription> _cameras = [];

  static List<CameraDescription> get cameras => [..._cameras];

  static Future<void> initialize() async {
    _cameras = await availableCameras();
  }
}
