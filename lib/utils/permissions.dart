import 'package:permission_handler/permission_handler.dart';

Future<bool> hasGrantedRequiredPermissions() async =>
    await Permission.camera.isGranted && await Permission.microphone.isGranted;
