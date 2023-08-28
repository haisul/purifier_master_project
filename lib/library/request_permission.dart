import 'package:permission_handler/permission_handler.dart';

class RequestPermission {
  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
    } else if (status.isDenied) {
      // 使用者拒絕定位權限，可以提示使用者開啟權限設定頁面
    } else if (status.isPermanentlyDenied) {
      // 使用者永久拒絕定位權限，可以提示使用者開啟權限設定頁面
    }
  }

  Future<bool> checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    return status == PermissionStatus.granted;
  }

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.request();
  }
}
