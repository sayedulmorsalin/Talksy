import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  FCMService._privateConstructor();

  static final FCMService instance = FCMService._privateConstructor();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      provisional: false,
      sound: true,
    );
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
  }
}
