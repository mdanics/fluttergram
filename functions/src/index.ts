import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
const notificationHandlerModule = require('./notificationHandler');
const getFeedModule = require('./getFeed');

admin.initializeApp();

export const notificationHandler = functions.firestore.document("/insta_a_feed/{userId}/items/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
       notificationHandlerModule.notificationHandler(snapshot, context);
    });


export const getFeed = functions.https.onRequest((req, res) => {
  getFeed(req, res);
})