import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<bool> requestStoragePermission();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> requestStoragePermission() async {
    // Request notification permission for the background service controls (especially for Android 13+)
    await Permission.notification.request();

    // Check Android 13+ (SDK 33+) audio permission
    final audioStatus = await Permission.audio.request();
    if (audioStatus.isGranted) {
      return true;
    }

    // Fallback to legacy storage permission for older Android/other platforms
    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      return true;
    }

    return false;
  }
}
