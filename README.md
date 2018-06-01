
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
