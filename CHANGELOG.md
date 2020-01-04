# Changelog
All notable changes to this project will be documented in this file.

## [1.2.3] - 2020-01-04
### Changes
- Add animation to Heart when liking a post
- add user's post to their own feed
- add logout button to edit profile page
- tabs now keep state after switching pages, improves overall ux
- Code clean up
- Dependency bumps 
- Fixed bugs
  - remove width constraint on follow button
  - feed now loads after username selection
  - fix duplicate username screens on first google signin
  - fixed error on open + removed useless code
  - Set maxWidth and maxHeight on pickImage()
  - added missing keys
  

## [1.2.2] - 2018-11-07
### Changes
- New - Location suggestions on upload page 


## [1.2.1] - 2018-11-04
### Changes
- Changed `BottomNavigationBar` to `CupertinoTabBar` to remove empty space underneath icons
- Added highlighting for the active page on the `CupertinoTabBar` 


## [1.2.0] - 2018-10-26
### Changes
- Added push notifications with Cloud Functions (Android)
  - Get notifications when someone likes or comments on a post and follows you
  - Notifications are for android as iOS notifications need an Apple developer account.
  - Cloud Functions Changes
    - Separated functions to individual files
    - npm dependencies updated


## [1.1.0] - 2018-10-22
### Changes
- Updated to most recent dependencies
