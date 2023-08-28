import 'package:permission_handler/permission_handler.dart';

Future<void> grantExternalStoragePermission() async {
  if (!(await Permission.storage.status.isGranted)) {
    await Permission.storage.request();
  }
}
