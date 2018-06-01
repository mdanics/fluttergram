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
 


## Dependencies

* [Flutter](https://flutter.io/)
* [Firestore](https://github.com/flutter/plugins/tree/master/packages/cloud_firestore)
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

#### 2. Clone the repoz

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

3. (skip if not running on Android)

* Create an app within your Firebase instance for Android, with package name com.yourcompany.news
* Run the following command to get your SHA-1 key:

```
keytool -exportcert -list -v \
-alias androiddebugkey -keystore ~/.android/debug.keystore
```

* In the Firebase console, in the settings of your Android app, add your SHA-1 key by clicking "Add Fingerprint".
* Follow instructions to download google-services.json
* place `google-services.json` into `/android/app/`.


4. (skip if not running on iOS)

* Create an app within your Firebase instance for iOS, with your app package name 
* Follow instructions to download GoogleService-Info.plist, and place it into /ios/Runner in XCode
* Open /ios/Runner/Info.plist. Locate the CFBundleURLSchemes key. The second item in the array value of this key is specific to the Firebase instance. Replace it with the value for REVERSED_CLIENT_ID from GoogleService-Info.plist

Double check install instructions for both
   - Google Auth Plugin
     - https://pub.dartlang.org/packages/firebase_auth 
   - Firestore Plugin
     -  https://pub.dartlang.org/packages/cloud_firestore 

# What's Next?
 - remove sensative items from git
 - googleservice-info.plist from both  android and ios folders
 - Improve Caching of Profiles, Images, Etc.
 - Clean up Code
