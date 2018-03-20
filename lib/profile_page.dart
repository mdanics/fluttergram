import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'dart:async';
import 'image_post.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({this.userId});

  final String userId;

  _ProfilePage createState() => new _ProfilePage(this.userId);
}

class _ProfilePage extends State<ProfilePage> {
  final String userId;

  _ProfilePage(this.userId);

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

    Container buildFollowButton() {
      return new Container(
        padding: const EdgeInsets.only(top: 2.0),
        child: new FlatButton(
            onPressed: null,
            child: new Container(
              decoration: new BoxDecoration(
                  color: Colors.blue,
                  borderRadius: new BorderRadius.circular(5.0)),
              alignment: Alignment.center,
              child:
                  new Text("Follow", style: new TextStyle(color: Colors.white)),
              width: 250.0,
              height: 27.0,
            )),
      );
    }

    Row buildImageViewButtonBar() {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.grid_on),
            onPressed: null,
          ),
          new IconButton(
            icon: new Icon(Icons.list),
            onPressed: null,
          ),
          new IconButton(
            icon: new Icon(Icons.person_outline),
            onPressed: null,
          ),
          new IconButton(
            icon: new Icon(Icons.bookmark_border),
            onPressed: null,
          ),
        ],
      );
    }

    Container buildImageGrid() {
      getPosts() async {
        List<ImagePost> posts = [];
        var snap = await Firestore.instance.collection('insta_posts').where('ownerId', isEqualTo: googleSignIn.currentUser.id).getDocuments();
        for (var doc in snap.documents){
          posts.add(
              new ImagePost.fromDocument(doc)
          );
        }
        return posts;
      }

      return new Container(
          child: new FutureBuilder(
              future: getPosts(),
              builder: (context, snapshot){
                if (!snapshot.hasData)
                  return new Container(
                      alignment: FractionalOffset.center,
                      padding: const EdgeInsets.only(top: 10.0),
                      child: new CircularProgressIndicator());

                return new GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
//                    padding: const EdgeInsets.all(0.5),
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 3.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: snapshot.data.map((ImagePost imagePost ) {
                      return new GridTile(
                          child: new ImageTile(imagePost));
                    }).toList());

              },
          )
      );

    }

    return new StreamBuilder(
        stream: Firestore.instance
            .collection('insta_users')
            .document(userId)
            .snapshots,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
                alignment: FractionalOffset.center,
                child: new CircularProgressIndicator());

          User user = new User.fromDocument(snapshot.data);

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
                                    buildStatColumn("posts", 234),
                                    buildStatColumn("followers", 2630),
                                    buildStatColumn("following", 47),
                                  ],
                                ),
                                new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[buildFollowButton()],
                                ),
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
                        child: new Text(
                            user.bio),
                      ),
                    ],
                  ),
                ),
                new Divider(),
                buildImageViewButtonBar(),
                new Divider(height: 0.0),
                buildImageGrid(),
              ],
            ),
          );
        });
  }
}

class ImageTile extends StatelessWidget {

  final ImagePost imagePost;

  ImageTile(this.imagePost);

  clickedImage(BuildContext context) {
    Navigator.of(context).push(new MaterialPageRoute<bool>(
        builder: (BuildContext context) {
          return new Center(
            child: new GestureDetector(
                child: new Scaffold(
                  appBar: new AppBar(
                    title: new Text('Photo'),
                  ),
                  body: new Container(
                    child: imagePost,
                  ),
                ),
            ),
          );
        }
    ));

  }

  Widget build(BuildContext context){
    return new GestureDetector(
        onTap: () => clickedImage(context),
        child: new Image.network(imagePost.mediaUrl, fit: BoxFit.cover));
  }
}

class User {

  const User({this.username, this.id, this.photoUrl, this.email, this.displayName, this.bio});

  final String email;
  final String id;
  final String photoUrl;
  final String username;
  final String displayName;
  final String bio;

  factory User.fromDocument(DocumentSnapshot document){
    return new User(
      email: document['email'],
      username: document['username'],
      photoUrl: document['photoUrl'],
      id: document.documentID,
      displayName: document['displayName'],
      bio: document['bio'],
    );

  }

}