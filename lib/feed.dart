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
        title: const Text('Instagram', style: const TextStyle(fontFamily: "Billabong", color: Colors.black, fontSize: 35.0) ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
    return new FutureBuilder(
      future: Firestore.instance.collection('insta_posts').getDocuments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return new Container(
              alignment: FractionalOffset.center,
              child: new CircularProgressIndicator());
        return new ListView(
          children: snapshot.data.documents.map((document) {
            return new ImagePost.fromDocument(document);
          }).toList(),
        );
      },
    );
  }
}
