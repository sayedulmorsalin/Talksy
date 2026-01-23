// This is the Cloud Function template for sending push notifications
// Save this as: functions/index.js in your Firebase project

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

// Cloud Function to send push notifications
exports.sendNotification = onDocumentCreated(
    "notifications/{notificationId}",
    async (event) => {
      const snap = event.data;
      const notification = snap.data();

      try {
        const {recipientId, senderName, messageText, fcmToken} = notification;

        const shortBody = messageText.length > 100 ?
                messageText.substring(0, 100) + "..." :
                messageText;

        const message = {
          notification: {title: senderName, body: shortBody},
          data: {
            recipientId: recipientId,
            senderName: senderName,
            messageText: messageText,
          },
          token: fcmToken,
        };

        const response = await admin.messaging().send(message);
        console.log("Notification sent successfully:", response);

        await snap.ref.update({
          sent: true,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {success: true, response};
      } catch (error) {
        console.error("Error sending notification:", error);

        await snap.ref.update({
          sent: false,
          error: error.message,
        });

        return {success: false, error: error.message};
      }
    });

