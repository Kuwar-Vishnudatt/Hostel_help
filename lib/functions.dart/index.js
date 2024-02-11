const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendComplaintNotification = functions.firestore
  .document('complaints/{complaintId}')
  .onCreate(async (snap, context) => {
    const complaint = snap.data();

    if (!facultyType || !facultyId) {
      console.log('Faculty Type or Faculty ID not provided in the complaint');
      return;
    }

    try {
      const facultyDoc = await admin.firestore().collection('faculty').doc(facultyId).get();
      const facultyToken = facultyDoc.data()?.fcmToken;

      if (!facultyToken) {
        console.log('Faculty FCM token not found');
        return;
      }

      const message = {
        notification: {
          title: 'New Complaint',
          body: 'A new complaint has been submitted.',
        },
        token: facultyToken,
      };

      await admin.messaging().send(message);
      console.log('Notification sent to faculty');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  });