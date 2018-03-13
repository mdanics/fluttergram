import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'image_post.dart';
import 'dart:async';

class Feed extends StatefulWidget {
  _Feed createState() => new _Feed();
}

class _Feed extends State<Feed> {
  @override
  Widget build(BuildContext Context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Instagram'),
        centerTitle: true,
      ),
      body: new RefreshIndicator(
        onRefresh: _refresh,
        child: new CoreFeed(),
      ),
    );
  }

  Future<Null> _refresh() {
    final Completer<Null> completer = new Completer<Null>();
    new Timer(const Duration(seconds: 1), () { completer.complete(null); });
    return completer.future.then((_) {
      setState((){});
    });
  }
}

class CoreFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('insta_posts').snapshots,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return new Container(
              alignment: FractionalOffset.center,
              child: new CircularProgressIndicator());
        return new ListView(
          children: snapshot.data.documents.map((document) {
            return new ImagePost(
              username: document['username'],
              location: document['location'],
              mediaUrl: document['mediaUrl'],
              likes: document['likes'],
              description: document['description'],
              postId: document.documentID,
            );
          }).toList(),
        );
      },
    );
  }
}
