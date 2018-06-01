# firestore_test

A new Flutter application.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

## Notes to improve Readme at some date

# Steps to create your own instance:

-Enable FireStore
  - https://pub.dartlang.org/packages/cloud_firestore
    - follow the instructions in the above link to set up your firebase console to be able use firestore / login for both iOS and Android
    - Create clound functions

- Enable googleSignIn
  - https://pub.dartlang.org/packages/firebase_auth
  - which when u look at instructions then takes you to https://pub.dartlang.org/packages/google_sign_in#-readme-tab-
  - copy the google-serivies.plist into runner
    -which says to paste this code into info.plst in iOS:
    

				    <!-- Google Sign-in Section -->
				<key>CFBundleURLTypes</key>
				<array>
					<dict>
						<key>CFBundleTypeRole</key>
						<string>Editor</string>
						<key>CFBundleURLSchemes</key>
						<array>
							<!-- TODO Replace this value: -->
							<!-- Copied from GoogleServices-Info.plist key REVERSE_CLIENT_ID -->
							<string>com.googleusercontent.apps.861823949799-vc35cprkp249096uujjn0vvnmcvjppkn</string>
						</array>
					</dict>
				</array>
				<!-- End of the Google Sign-in Section -->
   



# What's Next?
 - remove sensative items from git
 - googleservice-info.plist from both  android and ios folders
 - Improve Caching of Profiles, Images, Etc.
 - Clean up Code
