import 'package:cloud_firestore/cloud_firestore.dart';

class SMSService {
  static final SMSService _instance = SMSService._internal();

  factory SMSService() {
    return _instance;
  }

  SMSService._internal();

  static SMSService get instance => _instance;

  Future<bool> sendSMS(
    String recipientId,
    String senderName,
    String messageText,
  ) async {
    try {
      // Get recipient's FCM token from Firestore
      final recipientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId)
          .get();

      if (!recipientDoc.exists) {
        print('Recipient not found');
        return false;
      }

      final recipientData = recipientDoc.data() as Map<String, dynamic>;
      final fcmToken = recipientData['fcmToken'] as String?;

      if (fcmToken == null || fcmToken.isEmpty) {
        print('FCM token not available for recipient');
        return false;
      }

      // Save notification to Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'recipientId': recipientId,
        'senderName': senderName,
        'messageText': messageText,
        'fcmToken': fcmToken,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'message',
      });

      print('Notification saved for sending via Cloud Function');
      return true;
    } catch (e) {
      print('Error saving notification: $e');
      return false;
    }
  }
}
