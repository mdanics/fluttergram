import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "dart:async";
import "main.dart"; //for current user

class CommentScreen extends StatefulWidget {
  final String postId;
  final String postOwner;
  final String postMediaUrl;

  const CommentScreen({this.postId, this.postOwner, this.postMediaUrl});
  @override
  _CommentScreenState createState() => _CommentScreenState(
      postId: this.postId,
      postOwner: this.postOwner,
      postMediaUrl: this.postMediaUrl);
}

class _CommentScreenState extends State<CommentScreen> {
  final String postId;
  final String postOwner;
  final String postMediaUrl;

  final TextEditingController _commentController = TextEditingController();

  _CommentScreenState({this.postId, this.postOwner, this.postMediaUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Comments",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: buildPage(),
    );
  }

  Widget buildPage() {
    return Column(
      children: [
        Expanded(
          child:
            buildComments(),
        ),
        Divider(),
        ListTile(
          title: TextFormField(
            controller: _commentController,
            decoration: InputDecoration(labelText: 'Write a comment...'),
            onFieldSubmitted: addComment,
          ),
          trailing: OutlineButton(onPressed: (){addComment(_commentController.text);}, borderSide: BorderSide.none, child: Text("Post"),),
        ),

      ],
    );

  }


  Widget buildComments() {
    return FutureBuilder<List<Comment>>(
        future: getComments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                child: CircularProgressIndicator());

          return ListView(
            children: snapshot.data,
          );
        });
  }

  Future<List<Comment>> getComments() async {
    List<Comment> comments = [];

    QuerySnapshot data = await Firestore.instance
        .collection("insta_comments")
        .document(postId)
        .collection("comments")
        .getDocuments();
    data.documents.forEach((DocumentSnapshot doc) {
      comments.add(Comment.fromDocument(doc));
    });

    return comments;
  }

  addComment(String comment) {
    _commentController.clear();
    Firestore.instance
        .collection("insta_comments")
        .document(postId)
        .collection("comments")
        .add({
      "username": currentUserModel.username,
      "comment": comment,
      "timestamp": DateTime.now().toString(),
      "avatarUrl": currentUserModel.photoUrl,
      "userId": currentUserModel.id
    });

    //adds to postOwner's activity feed
    Firestore.instance
        .collection("insta_a_feed")
        .document(postOwner)
        .collection("items")
        .add({
      "username": currentUserModel.username,
      "userId": currentUserModel.id,
      "type": "comment",
      "userProfileImg": currentUserModel.photoUrl,
      "commentData": comment,
      "timestamp": DateTime.now().toString(),
      "postId": postId,
      "mediaUrl": postMediaUrl,
    });
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final String timestamp;

  Comment(
      {this.username,
      this.userId,
      this.avatarUrl,
      this.comment,
      this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot document) {
    return Comment(
      username: document['username'],
      userId: document['userId'],
      comment: document["comment"],
      timestamp: document["timestamp"],
      avatarUrl: document["avatarUrl"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ),
        Divider(),
      ],
    );
  }
}
