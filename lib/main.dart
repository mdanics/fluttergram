import 'package:flutter/material.dart';
import 'feed.dart';
import 'upload_page.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final auth = FirebaseAuth.instance;
final googleSignIn = new GoogleSignIn();
final ref = Firestore.instance.collection('insta_users');

Future<Null> _ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signInSilently();
  }
  if (user == null) {
    print('waiting');
    await googleSignIn.signIn();
    print('done');
    ref.add({
      "id": "test",
      "username": user.displayName,
      "photoUrl": user.photoUrl,
      "email": user.email
    });
  }

  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
        idToken: credentials.idToken, accessToken: credentials.accessToken);
  }
}

Future<Null> _silentLogin() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null) {
    user = await googleSignIn.signInSilently();
    print('cmon');
    ref.document(user.id).setData({
      "id": user.id,
      "username": user.displayName,
      "photoUrl": user.photoUrl,
      "email": user.email
    });
  }

  if (await auth.currentUser() == null && user != null) {
    GoogleSignInAuthentication credentials =
        await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
        idToken: credentials.idToken, accessToken: credentials.accessToken);
  }
}

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Instagram',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(title: 'Fluttergram'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController;

  int _page = 0;
  bool triedSilentLogin = false;

  @override
  Widget build(BuildContext context) {
    if (triedSilentLogin == false) {
      silentLogin();
    } // might cause performance issues?
    return googleSignIn.currentUser == null
        ? new Container(
            alignment: FractionalOffset.center,
            width: 20.0,
            child: new RaisedButton(
              onPressed: login,
              child: new Row(children: <Widget>[
                new Icon(Icons.business),
                new Text("Sign in with Google")
              ]),
            ),
          )
        : new Scaffold(
            body: new PageView(
              children: [
                new Container(
                  color: Colors.white,
                  child: new Feed(),
                ),
                new Container(
                  color: Colors.green,
                ),
                new Container(color: Colors.white, child: new Uploader()),
                new Container(color: Colors.amber),
                new Container(color: Colors.white, child: new Text('Test')),
              ],
              controller: _pageController,
              physics: new NeverScrollableScrollPhysics(),
              onPageChanged: onPageChanged,
            ),
            bottomNavigationBar: new BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.home, color: Colors.grey),
                    title: new Text(""),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.search, color: Colors.grey),
                    title: new Text(""),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.add_circle, color: Colors.grey),
                    title: new Text(""),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.star, color: Colors.grey),
                    title: new Text(""),
                    backgroundColor: Colors.white),
                new BottomNavigationBarItem(
                    icon: new Icon(Icons.person_outline, color: Colors.grey),
                    title: new Text(""),
                    backgroundColor: Colors.white),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),

          );
  }

  void login() async {
    await _ensureLoggedIn();
    setState(() {
      triedSilentLogin = true;
    });
  }

  void silentLogin() async {
    await _silentLogin();
    setState(() {});
  }

  void navigationTapped(int page) {
    //Animating Page
    _pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }
}
