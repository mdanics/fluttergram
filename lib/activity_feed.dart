import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'image_post.dart'; //needed to open image when clicked
import 'profile_page.dart'; // to open the profile page when username clicked
import 'main.dart'; //needed for currentuser id

class ActivityFeedPage extends StatefulWidget {
  @override
  _ActivityFeedPageState createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage> with AutomaticKeepAliveClientMixin<ActivityFeedPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Activity Feed",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: buildActivityFeed(),
    );
  }

  buildActivityFeed() {
    return Container(
      child: FutureBuilder(
          future: getFeed(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Container(
                  alignment: FractionalOffset.center,
                  padding: const EdgeInsets.only(top: 10.0),
                  child: CircularProgressIndicator());
            else {
              return ListView(children: snapshot.data);
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
      items.add(ActivityFeedItem.fromDocument(doc));
    }
    return items;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;

}

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String
      type; // types include liked photo, follow user, comment on photo
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
    return ActivityFeedItem(
      username: document['username'],
      userId: document['userId'],
      type: document['type'],
      mediaUrl: document['mediaUrl'],
      mediaId: document['postId'],
      userProfileImg: document['userProfileImg'],
      commentData: document["commentData"],
    );
  }

  Widget mediaPreview = Container();
  String actionText;

  void configureItem(BuildContext context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () {
          openImage(context, mediaId);
        },
        child: Container(
          height: 45.0,
          width: 45.0,
          child: AspectRatio(
            aspectRatio: 487 / 451,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.fill,
                alignment: FractionalOffset.topCenter,
                image: NetworkImage(mediaUrl),
              )),
            ),
          ),
        ),
      );
    }

    if (type == "like") {
      actionText = " liked your post.";
    } else if (type == "follow") {
      actionText = " starting following you.";
    } else if (type == "comment") {
      actionText = " commented: $commentData";
    } else {
      actionText = "Error - invalid activityFeed type: $type";
    }
  }

  @override
  Widget build(BuildContext context) {
    configureItem(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 15.0),
          child: CircleAvatar(
            radius: 23.0,
            backgroundImage: NetworkImage(userProfileImg),
          ),
        ),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                child: Text(
                  username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  openProfile(context, userId);
                },
              ),
              Flexible(
                child: Container(
                  child: Text(
                    actionText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
            child: Align(
                child: Padding(
                  child: mediaPreview,
                  padding: EdgeInsets.all(15.0),
                ),
                alignment: AlignmentDirectional.bottomEnd))
      ],
    );
  }
}

openImage(BuildContext context, String imageId) {
  print("the image id is $imageId");
  Navigator.of(context)
      .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
    return Center(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Photo',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
          ),
          body: ListView(
            children: <Widget>[
              Container(
                child: ImagePostFromId(id: imageId),
              ),
            ],
          )),
    );
  }));
}
