import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'image_post.dart'; //needed to open image when clicked
import 'main.dart'; //needed for currentuser id

class ActivityFeedPage extends StatefulWidget {
  @override
  _ActivityFeedPageState createState() => new _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          "Activity Feed",
          style: new TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: buildActivityFeed(),
    );
  }

  buildActivityFeed() {
    return new Container(
      child: new FutureBuilder(
          future: getFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return new Container(
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 10.0),
                  child: new CircularProgressIndicator());
            else {
              return new ListView(children: snapshot.data);
            }
          }),
    );
  }

  getFeed() async {
    List<ActivityFeedItem> items = [];
    var snap = await Firestore.instance
        .collection('insta_a_feed')
        .document(currentUserModel.id)
        .collection("items")
        .orderBy("timestamp")
        .getDocuments();

    for (var doc in snap.documents) {
      items.add(new ActivityFeedItem.fromDocument(doc));
    }
    return items;
  }
}

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String
      type; // potetial types include liked photo, follow user, comment on photo
  final String mediaUrl;
  final String mediaId;
  final String userProfileImg;
  final String commentData;

  ActivityFeedItem(
      {this.username,
      this.userId,
      this.type,
      this.mediaUrl,
      this.mediaId,
      this.userProfileImg,
      this.commentData});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot document) {
    return new ActivityFeedItem(
      username: document['username'],
      userId: document['userId'],
      type: document['type'],
      mediaUrl: document['mediaUrl'],
      mediaId: document['postId'],
      userProfileImg: document['userProfileImg'],
      commentData: document["commentData"],
    );
  }

  Widget mediaPreview = new Container();
  String actionText;

  void configureItem(BuildContext context) {
    if (type == "like" || type == "comment") {
      mediaPreview = new GestureDetector(
        onTap: () {
          openImage(context, mediaId);
        },
        child: new Container(
          height: 45.0,
          width: 45.0,
          child: new AspectRatio(
            aspectRatio: 487 / 451,
            child: new Container(
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                fit: BoxFit.fill,
                alignment: FractionalOffset.topCenter,
                image: new NetworkImage(mediaUrl),
              )),
            ),
          ),
        ),
      );
    }

    if (type == "like") {
      actionText = "$username liked your post.";
    } else if (type == "follow") {
      actionText = "$username starting following you.";
    } else if (type == "comment") {
      actionText = "$username commented: $commentData";
    } else {
      actionText = "Error - invalid activityFeed type: $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureItem(context);
    return new Row(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 15.0),
          child: new CircleAvatar(
            radius: 23.0,
            backgroundImage: new NetworkImage(userProfileImg),
          ),
        ),
        new Text(actionText),
        new Expanded(
            child: new Align(
                child: new Padding(
                  child: mediaPreview,
                  padding: new EdgeInsets.all(15.0),
                ),
                alignment: AlignmentDirectional.bottomEnd))
      ],
    );
  }
}

openImage(BuildContext context, String imageId) {
  print("the image id is $imageId");
  Navigator
      .of(context)
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
                child: new ImagePostFromId(id: imageId),
              ),
            ],
          )),
    );
  }));
}
