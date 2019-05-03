# Fluttergram
A working Instagram clone written in Flutter using Firebase / Firestore

# Demo
[Download the release APK to try out Fluttergram](https://github.com/mdanics/fluttergram/raw/master/app-release.apk) 

I update Fluttergram with new features and bugs fixes, but the apk may be behind master. Take a look at the [changelog](/CHANGELOG.md) to see the most recent additions to the apk.


## Features

 * Custom photo feed based on who you follow (using firebase cloud functions)
 * Post photo posts from camera or gallery
   * Like posts
   * Comment on posts
        * View all comments on a post
 * Search for users
 * Profile Pages
   * Follow / Unfollow Users
   * Change image view from grid layout to feed layout
   * Add your own bio
 * Activity Feed showing recent likes / comments of your posts + new followers


## Screenshots
<p>
<img src="https://user-images.githubusercontent.com/10066840/45931079-61844e00-bf36-11e8-80d5-e02f8123db59.gif" alt="feed example" width="250">
<img src="https://user-images.githubusercontent.com/10066840/45931292-153b0d00-bf3a-11e8-84f3-e9e9547d679b.gif" alt="upload photo example" width="250">
<img src="https://user-images.githubusercontent.com/10066840/45931289-0d7b6880-bf3a-11e8-8d4b-8e4086924a08.gif" alt="go to a profile from feed" width="250">
<img src="https://user-images.githubusercontent.com/10066840/45931293-166c3a00-bf3a-11e8-8d67-4d89dfeac18d.gif" alt="edit profile example" width="250">
<img src="https://user-images.githubusercontent.com/10066840/45931251-7e6e5080-bf39-11e8-857b-18e7709b0f0c.gif" alt="comment and activity feed example" width="250">

</p>

## Dependencies

* [Flutter](https://flutter.io/)
* [Firestore](https://github.com/flutter/plugins/tree/master/packages/cloud_firestore)
* [Image Picker](https://github.com/flutter/plugins/tree/master/packages/image_picker)
* [Google Sign In](https://github.com/flutter/plugins/tree/master/packages/google_sign_in)
* [Firebase Auth](https://github.com/flutter/plugins/tree/master/packages/firebase_auth)
* [UUID](https://github.com/Daegalus/dart-uuid)
* [Dart Image](https://github.com/brendan-duncan/image)
* [Path Provider](https://github.com/flutter/plugins/tree/master/packages/path_provider)
* [Font Awesome](https://github.com/brianegan/font_awesome_flutter)
* [Dart HTTP](https://github.com/dart-lang/http)
* [Dart Async](https://github.com/dart-lang/async)
* [Flutter Shared Preferences]()
* [Cached Network Image](https://github.com/renefloor/flutter_cached_network_image)

## Getting started


#### 1. [Setup Flutter](https://flutter.io/setup/)

#### 2. Clone the repo

```sh
$ git clone https://github.com/mdanics/fluttergram.git
$ cd fluttergram/
```

#### 3. Setup the firebase app

1. You'll need to create a Firebase instance. Follow the instructions at https://console.firebase.google.com.
2. Once your Firebase instance is created, you'll need to enable anonymous authentication.

* Go to the Firebase Console for your new instance.
* Click "Authentication" in the left-hand menu
* Click the "sign-in method" tab
* Click "Google" and enable it

3. Create Cloud Functions (to make the Feed work)
* Create a new firebase project with `firebase init`
* Copy this project's `functions/lib/index.js` to your firebase project's `functions/index.js`
* Push the function `getFeed` with `firebase deploy --only functions`  In the output, you'll see the getFeed URL, copy that.
* Replace the url in the `_getFeed` function in `feed.dart` with your cloud function url from the previous step.


_**If this does not work**  and you get the error `Error: Error parsing triggers: Cannot find module './notificationHandler'` Try following [these steps](https://github.com/mdanics/fluttergram/issues/25#issuecomment-434031430). If you are still unable to get it to work please open a new issue._

_**If you are getting no errors, but an empty feed** You must follow users with posts as the getFeed function only returns posts from people you follow._



4. Enable the Firebase Database
* Go to the Firebase Console
* Click "Database" in the left-hand menu
* Click the Cloudstore "Create Database" button
* Select "Start in test mode" and "Enable"

5. (skip if not running on Android)

* Create an app within your Firebase instance for Android, with package name com.yourcompany.news
* Run the following command to get your SHA-1 key:

```
keytool -exportcert -list -v \
-alias androiddebugkey -keystore ~/.android/debug.keystore
```

* In the Firebase console, in the settings of your Android app, add your SHA-1 key by clicking "Add Fingerprint".
* Follow instructions to download google-services.json
* place `google-services.json` into `/android/app/`.


6. (skip if not running on iOS)

* Create an app within your Firebase instance for iOS, with your app package name
* Follow instructions to download GoogleService-Info.plist
* Open XCode, right click the Runner folder, select the "Add Files to 'Runner'" menu, and select the GoogleService-Info.plist file to add it to /ios/Runner in XCode
* Open /ios/Runner/Info.plist in a text editor. Locate the CFBundleURLSchemes key. The second item in the array value of this key is specific to the Firebase instance. Replace it with the value for REVERSED_CLIENT_ID from GoogleService-Info.plist

Double check install instructions for both
   - Google Auth Plugin
     - https://pub.dartlang.org/packages/firebase_auth
   - Firestore Plugin
     -  https://pub.dartlang.org/packages/cloud_firestore

# What's Next?
 - [x] Notificaitons for likes, comments, follows, etc
 - [ ] Improve Caching of Profiles, Images, Etc.
 - [ ] Better post creation, add filters to your image
 - [ ] Custom Camera Implementation
 - [ ] Animations (heart when liking image)
 - [ ] Firebase Security Rules
 - [ ] Delete Posts
 - [ ] Registration without Google SignIn
 - [ ] Direct Messaging
 - [ ] Stories
 - [ ] Clean up code
