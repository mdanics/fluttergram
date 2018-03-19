import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImagePost extends StatefulWidget {


  const ImagePost(
      {this.mediaUrl,
      this.username,
      this.location,
      this.description,
      this.likes,
      this.postId});

  factory ImagePost.fromDocument(DocumentSnapshot document){
    return new ImagePost(
      username: document['username'],
      location: document['location'],
      mediaUrl: document['mediaUrl'],
      likes: document['likes'],
      description: document['description'],
      postId: document.documentID,
    );
  }



    final String mediaUrl;
  final String username;
  final String location;
  final String description;
  final int likes;
  final String postId;


  _ImagePost createState() => new _ImagePost(this.mediaUrl, this.username,
      this.location, this.description, this.likes, this.postId);




}

class _ImagePost extends State<ImagePost> {
  final String mediaUrl;
  final String username;
  final String location;
  final String description;
  final int likes;
  final String postId;

  TextStyle boldStyle = new TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  var reference = Firestore.instance.collection('insta_posts');

  _ImagePost(this.mediaUrl, this.username, this.location, this.description,
      this.likes, this.postId);

  @override
  Widget build(BuildContext Context) {
    return new Container(
      child: new Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new ListTile(
            leading: const CircleAvatar(),
            title: new Text(this.username, style: boldStyle),
            subtitle: new Text(this.location),
            trailing: const Icon(Icons.more_vert),
          ),
          new Image.network(
            mediaUrl,
            height: 250.0,
          ),
          new ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              new FlatButton(
                  child: const Icon(Icons.thumb_up), onPressed: () {}),
              new FlatButton(
                  child: const Icon(Icons.comment),
                  onPressed: () {
                    _likePost(postId);
                  }),
            ],
          ),
          new Row(
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(left: 20.0),
                child: new Text(
                  "$likes likes",
                  style: boldStyle,
                ),
              )
            ],
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                  margin: const EdgeInsets.only(left: 20.0),
                  child: new Text(
                    "$username ",
                    style: boldStyle,
                  )),
              new Expanded(child: new Text(description)),
            ],
          )
        ],
      ),
    );
  }

  void _likePost(String postId) {
    reference.document(postId).updateData({
      'likes': likes + 1
    }); //make this more error proof maybe with cloud functions
  }
}

class ImagePostFromId extends StatelessWidget{

  final String id;
  const ImagePostFromId({this.id});

  getImagePost() async {
    var document = await Firestore.instance.collection('insta_posts').document(id).get();
    return new ImagePost.fromDocument(document);
  }

  @override
  Widget build (BuildContext context){
    return new FutureBuilder(
        future: getImagePost() ,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return new Container(
                alignment: FractionalOffset.center,
                padding: const EdgeInsets.only(top: 10.0),
                child: new CircularProgressIndicator());
          return snapshot.data;
        }
    );
  }
}