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
exports.getFeedModule = function (req, res) {
    const uid = String(req.query.uid);
    function compileFeedPost() {
        return __awaiter(this, void 0, void 0, function* () {
            const following = yield getFollowing(uid, res);
            let listOfPosts = yield getAllPosts(following, res);
            listOfPosts = [].concat.apply([], listOfPosts); // flattens list
            res.send(listOfPosts);
        });
    }
    compileFeedPost().then().catch();
};
function getAllPosts(following, res) {
    return __awaiter(this, void 0, void 0, function* () {
        let listOfPosts = [];
        for (let user in following) {
            listOfPosts.push(yield getUserPosts(following[user], res));
        }
        return listOfPosts;
    });
}
function getUserPosts(userId, res) {
    const posts = admin.firestore().collection("insta_posts").where("ownerId", "==", userId).orderBy("timestamp");
    return posts.get()
        .then(function (querySnapshot) {
        let listOfPosts = [];
        querySnapshot.forEach(function (doc) {
            listOfPosts.push(doc.data());
        });
        return listOfPosts;
    });
}
function getFollowing(uid, res) {
    const doc = admin.firestore().doc(`insta_users/${uid}`);
    return doc.get().then(snapshot => {
        const followings = snapshot.data().following;
        let following_list = [];
        for (const following in followings) {
            if (followings[following] === true) {
                following_list.push(following);
            }
        }
        return following_list;
    }).catch(error => {
        res.status(500).send(error);
    });
}
//# sourceMappingURL=getFeed.js.map