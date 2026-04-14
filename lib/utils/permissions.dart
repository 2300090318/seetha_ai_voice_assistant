import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> requestStorage() async {
    final photos = await Permission.photos.request();
    final videos = await Permission.videos.request();
    final storage = await Permission.storage.request();
    return photos.isGranted || videos.isGranted || storage.isGranted;
  }

  static Future<bool> requestContacts() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  static Future<bool> requestPhone() async {
    final status = await Permission.phone.request();
    return status.isGranted;
  }

  static Future<Map<Permission, PermissionStatus>> requestAll() async {
    return await [
      Permission.microphone,
      Permission.storage,
      Permission.photos,
      Permission.videos,
      Permission.contacts,
      Permission.phone,
    ].request();
  }

  static Future<bool> hasMicrophone() async =>
      await Permission.microphone.isGranted;

  static Future<bool> hasStorage() async =>
      await Permission.storage.isGranted ||
      await Permission.photos.isGranted;

  static Future<bool> hasContacts() async =>
      await Permission.contacts.isGranted;

  static void openSettings() => openAppSettings();
}
