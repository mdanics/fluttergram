import * as admin from 'firebase-admin';
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore';

export const notificationHandlerModule = async function (snapshot, context) {      
      console.log(snapshot.data())

      const ownerDoc = admin.firestore().doc("insta_users/" + context.params.userId)
      const ownerData = await ownerDoc.get()



      const androidNotificationToken = ownerData.data()["androidNotificationToken"];
      if (androidNotificationToken) {
         sendNotification(androidNotificationToken, snapshot.data());
        

      } else {
        console.log("No token for User, not sending a notification");
      }
      
      return 0;
    };

function sendNotification(androidNotificationToken: string, activityItem: FirebaseFirestore.DocumentData) {

    let title: string;
    let body: string = "";
  
    if (activityItem['type'] === "comment") {
      title = "New Comment"
      body = activityItem['username'] + " commented on your post: " + activityItem["commentData"]
    } else if (activityItem["type"] === "like") {
      title = activityItem['username'] + " liked your post"
    } else if (activityItem["type"] === "follow"){
      title = activityItem['username'] + " started following you"
    }
  
    const message = {
      notification: {
        title: title,
        body: body
      },
      token: androidNotificationToken
    }
  
    admin.messaging().send(message)
    .then((response) => {
      // Response is a message ID string.
      console.log('Successfully sent message:', response);
    })
    .catch((error) => {
      console.log('Error sending message:', error);
    });
  }
    