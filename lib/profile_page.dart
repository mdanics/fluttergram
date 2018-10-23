import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'image_post.dart';
import 'dart:async';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({this.userId});

  final String userId;

  _ProfilePage createState() => new _ProfilePage(this.userId);
}

class _ProfilePage extends State<ProfilePage> {
  final String profileId;
  String currentUserId = googleSignIn.currentUser.id;
  String view = "grid"; // default view
  bool isFollowing = false;
  bool followButtonClicked = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  _ProfilePage(this.profileId);

  editProfile() {
    EditProfilePage editPage = new EditProfilePage();

    Navigator.of(context)
        .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
      return new Center(
        child: new Scaffold(
            appBar: new AppBar(
              leading: new IconButton(
                icon: new Icon(Icons.close),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
              title: new Text('Edit Profile',
                  style: new TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              actions: <Widget>[
                new IconButton(
                    icon: new Icon(
                      Icons.check,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      editPage.applyChanges();
                      Navigator.maybePop(context);
                    })
              ],
            ),
            body: new ListView(
              children: <Widget>[
                new Container(
                  child: editPage,
                ),
              ],
            )),
      );
    }));
  }

  followUser() {
    print('following user');
    setState(() {
      this.isFollowing = true;
      followButtonClicked = true;
    });

    Firestore.instance.document("insta_users/$profileId").updateData({
      'followers.$currentUserId': true
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance.document("insta_users/$currentUserId").updateData({
      'following.$profileId': true
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    //updates activity feed
    Firestore.instance
        .collection("insta_a_feed")
        .document(profileId)
        .collection("items")
        .document(currentUserId)
        .setData({
      "ownerId": profileId,
      "username": currentUserModel.username,
      "userId": currentUserId,
      "type": "follow",
      "userProfileImg": currentUserModel.photoUrl,
      "timestamp": new DateTime.now().toString()
    });
  }

  unfollowUser() {
    setState(() {
      isFollowing = false;
      followButtonClicked = true;
    });

    Firestore.instance.document("insta_users/$profileId").updateData({
      'followers.$currentUserId': false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance.document("insta_users/$currentUserId").updateData({
      'following.$profileId': false
      //firestore plugin doesnt support deleting, so it must be nulled / falsed
    });

    Firestore.instance
        .collection("insta_a_feed")
        .document(profileId)
        .collection("items")
        .document(currentUserId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    Column buildStatColumn(String label, int number) {
      return new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            number.toString(),
            style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          new Container(
              margin: const EdgeInsets.only(top: 4.0),
              child: new Text(
                label,
                style: new TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400),
              ))
        ],
      );
    }

    Container buildFollowButton(
        {String text,
        Color backgroundcolor,
        Color textColor,
        Color borderColor,
        Function function}) {
      return new Container(
        padding: const EdgeInsets.only(top: 2.0),
        child: new FlatButton(
            onPressed: function,
            child: new Container(
              decoration: new BoxDecoration(
                  color: backgroundcolor,
                  border: new Border.all(color: borderColor),
                  borderRadius: new BorderRadius.circular(5.0)),
              alignment: Alignment.center,
              child: new Text(text,
                  style: new TextStyle(
                      color: textColor, fontWeight: FontWeight.bold)),
              width: 250.0,
              height: 27.0,
            )),
      );
    }

    Container buildProfileFollowButton(User user) {
      // viewing your own profile - should show edit button
      if (currentUserId == profileId) {
        return buildFollowButton(
          text: "Edit Profile",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey,
          function: editProfile,
        );
      }

      // already following user - should show unfollow button
      if (isFollowing) {
        return buildFollowButton(
          text: "Unfollow",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey,
          function: unfollowUser,
        );
      }

      // does not follow user - should show follow button
      if (!isFollowing) {
        return buildFollowButton(
          text: "Follow",
          backgroundcolor: Colors.blue,
          textColor: Colors.white,
          borderColor: Colors.blue,
          function: followUser,
        );
      }

      return buildFollowButton(
          text: "loading...",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey);
    }

    Row buildImageViewButtonBar() {
      Color isActiveButtonColor(String viewName) {
        if (view == viewName) {
          return Colors.blueAccent;
        } else {
          return Colors.black26;
        }
      }

      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.grid_on, color: isActiveButtonColor("grid")),
            onPressed: () {
              changeView("grid");
            },
          ),
          new IconButton(
            icon: new Icon(Icons.list, color: isActiveButtonColor("feed")),
            onPressed: () {
              changeView("feed");
            },
          ),
        ],
      );
    }

    Container buildUserPosts() {
      Future<List<ImagePost>> getPosts() async {
        List<ImagePost> posts = [];
        var snap = await Firestore.instance
            .collection('insta_posts')
            .where('ownerId', isEqualTo: profileId)
            .orderBy("timestamp")
            .getDocuments();
        for (var doc in snap.documents) {
          posts.add(new ImagePost.fromDocument(doc));
        }
        setState(() {
          postCount = snap.documents.length;
        });

        return posts.reversed.toList();
      }

      return new Container(
          child: new FutureBuilder<List<ImagePost>>(
        future: getPosts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 10.0),
                child: new CircularProgressIndicator());
          else if (view == "grid") {
            // build the grid
            return new GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
//                    padding: const EdgeInsets.all(0.5),
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data.map((ImagePost imagePost) {
                  return new GridTile(child: new ImageTile(imagePost));
                }).toList());
          } else if (view == "feed") {
            return new Column(
                children: snapshot.data.map((ImagePost imagePost) {
              return imagePost;
            }).toList());
          }
        },
      ));
    }

    return new StreamBuilder(
        stream: Firestore.instance
            .collection('insta_users')
            .document(profileId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
                alignment: FractionalOffset.center,
                child: new CircularProgressIndicator());

          User user = new User.fromDocument(snapshot.data);

          if (user.followers.containsKey(currentUserId) &&
              user.followers[currentUserId] &&
              followButtonClicked == false) {
            isFollowing = true;
          }

          return new Scaffold(
              appBar: new AppBar(
                title: new Text(
                  user.username,
                  style: const TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
              ),
              body: new ListView(
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: new Column(
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            new CircleAvatar(
                              radius: 40.0,
                              backgroundColor: Colors.grey,
                              backgroundImage: new NetworkImage(user.photoUrl),
                            ),
                            new Expanded(
                              flex: 1,
                              child: new Column(
                                children: <Widget>[
                                  new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      buildStatColumn("posts", postCount),
                                      buildStatColumn("followers",
                                          _countFollowings(user.followers)),
                                      buildStatColumn("following",
                                          _countFollowings(user.following)),
                                    ],
                                  ),
                                  new Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        buildProfileFollowButton(user)
                                      ]),
                                ],
                              ),
                            )
                          ],
                        ),
                        new Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(top: 15.0),
                            child: new Text(
                              user.displayName,
                              style: new TextStyle(fontWeight: FontWeight.bold),
                            )),
                        new Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 1.0),
                          child: new Text(user.bio),
                        ),
                      ],
                    ),
                  ),
                  new Divider(),
                  buildImageViewButtonBar(),
                  new Divider(height: 0.0),
                  buildUserPosts(),
                ],
              ));
        });
  }

  changeView(String viewName) {
    setState(() {
      view = viewName;
    });
  }

  int _countFollowings(Map followings) {
    int count = 0;

    void countValues(key, value) {
      if (value) {
        count += 1;
      }
    }

    followings.forEach(countValues);

    return count;
  }
}

class ImageTile extends StatelessWidget {
  final ImagePost imagePost;

  ImageTile(this.imagePost);

  clickedImage(BuildContext context) {
    Navigator.of(context)
        .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
      return new Center(
        child: new Scaffold(
            appBar: new AppBar(
              title: new Text('Photo',
                  style: new TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
            ),
            body: new ListView(
              children: <Widget>[
                new Container(
                  child: imagePost,
                ),
              ],
            )),
      );
    }));
  }

  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () => clickedImage(context),
        child: new Image.network(imagePost.mediaUrl, fit: BoxFit.cover));
  }
}

class User {
  const User(
      {this.username,
      this.id,
      this.photoUrl,
      this.email,
      this.displayName,
      this.bio,
      this.followers,
      this.following});

  final String email;
  final String id;
  final String photoUrl;
  final String username;
  final String displayName;
  final String bio;
  final Map followers;
  final Map following;

  factory User.fromDocument(DocumentSnapshot document) {
    return new User(
      email: document['email'],
      username: document['username'],
      photoUrl: document['photoUrl'],
      id: document.documentID,
      displayName: document['displayName'],
      bio: document['bio'],
      followers: document['followers'],
      following: document['following'],
    );
  }
}

void openProfile(BuildContext context, String userId) {
  Navigator.of(context)
      .push(new MaterialPageRoute<bool>(builder: (BuildContext context) {
    return new ProfilePage(userId: userId);
  }));
}
