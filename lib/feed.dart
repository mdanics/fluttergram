import 'package:flutter/material.dart';
import 'image_post.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'main.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Feed extends StatefulWidget {
  _Feed createState() => new _Feed();
}

class _Feed extends State<Feed> {
  var feedData;

  @override
  void initState(){
    super.initState();
    this._loadFeed();
  }

  buildFeed() {
    if (feedData != null){
      return new ListView(
        children: feedData,
      );
    } else {
      return new Container(
          alignment: FractionalOffset.center,
          child: new CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext Context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Fluttergram',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: new RefreshIndicator(
        onRefresh: _refresh,
        child: buildFeed(),
      ),
    );
  }

  Future<Null> _refresh() async {
    final Completer<Null> completer = new Completer<Null>();

    await _getFeed();
    completer.complete(null);

    return completer.future.then((_) {
      setState(() {});
    });
  }

  _loadFeed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var json = prefs.getString("feed");

    if (json != null){

      var data = JSON.decode(json);
      List<ImagePost> listOfPosts = _generateFeed(data);
      setState((){
        feedData = listOfPosts;
      });

    } else {
      _getFeed();
    }



  }

  _getFeed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    String userId = googleSignIn.currentUser.id.toString();
    var url =
        'https://us-central1-mp-rps.cloudfunctions.net/getFeed?uid=' + userId;
    var httpClient = new HttpClient();

    List<ImagePost> listOfPosts;
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var json = await response.transform(UTF8.decoder).join();
        prefs.setString("feed", json);
        var data = JSON.decode(json);
        listOfPosts = _generateFeed(data);
      } else {
        result =
        'Error getting a random quote:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result =
      'Failed invoking the getRandomQuote function. Exception: $exception';
    }

    setState(() {
      feedData = listOfPosts;
    });
  }

  _generateFeed(List<Map> feedData) {
    List<ImagePost> listOfPosts = [];

    for (Map postData in feedData) {
      listOfPosts.add(new ImagePost.fromJSON(postData));
    }

    return listOfPosts;
  }

}
