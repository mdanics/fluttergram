"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const admin = require("firebase-admin");
exports.notificationHandlerModule = function (snapshot, context) {
    return __awaiter(this, void 0, void 0, function* () {
        console.log(snapshot.data());
        const ownerDoc = admin.firestore().doc("insta_users/" + context.params.userId);
        const ownerData = yield ownerDoc.get();
        const androidNotificationToken = ownerData.data()["androidNotificationToken"];
        if (androidNotificationToken) {
            sendNotification(androidNotificationToken, snapshot.data());
        }
        else {
            console.log("No token for User, not sending a notification");
        }
        return 0;
    });
};
function sendNotification(androidNotificationToken, activityItem) {
    let title;
    let body = "";
    if (activityItem['type'] === "comment") {
        title = "New Comment";
        body = activityItem['username'] + " commented on your post: " + activityItem["commentData"];
    }
    else if (activityItem["type"] === "like") {
        title = activityItem['username'] + " liked your post";
    }
    else if (activityItem["type"] === "follow") {
        title = activityItem['username'] + " started following you";
    }
    const message = {
        notification: {
            title: title,
            body: body
        },
        token: androidNotificationToken
    };
    admin.messaging().send(message)
        .then((response) => {
        // Response is a message ID string.
        console.log('Successfully sent message:', response);
    })
        .catch((error) => {
        console.log('Error sending message:', error);
    });
}
//# sourceMappingURL=notificationHandler.js.map