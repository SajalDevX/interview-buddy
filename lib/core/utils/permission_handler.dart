import 'package:permission_handler/permission_handler.dart';

class AppPermissionHandler {
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> checkMicrophonePermission() async {
    return await Permission.microphone.isGranted;
  }

  Future<bool> checkStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  Future<bool> checkCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.microphone,
      Permission.storage,
      Permission.camera,
    ].request();
  }
}
