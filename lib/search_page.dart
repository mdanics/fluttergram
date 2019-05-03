import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import "profile_page.dart"; // needed to import for openProfile function
import 'models/user.dart';

class SearchPage extends StatefulWidget {
  _SearchPage createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{
  Future<QuerySnapshot> userDocs;

  buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: Form(
        child: TextFormField(
          decoration: InputDecoration(labelText: 'Search for a user...'),
          onFieldSubmitted: submit,
        ),
      ),
    );
  }

  ListView buildSearchResults(List<DocumentSnapshot> docs) {
    List<UserSearchItem> userSearchItems = [];

    docs.forEach((DocumentSnapshot doc) {
      User user = User.fromDocument(doc);
      UserSearchItem searchItem = UserSearchItem(user);
      userSearchItems.add(searchItem);
    });

    return ListView(
      children: userSearchItems,
    );
  }

  void submit(String searchValue) async {
    Future<QuerySnapshot> users = Firestore.instance
        .collection("insta_users")
        .where('displayName', isGreaterThanOrEqualTo: searchValue)
        .getDocuments();

    setState(() {
      userDocs = users;
    });
  }

  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again

    return Scaffold(
      appBar: buildSearchField(),
      body: userDocs == null
          ? Text("")
          : FutureBuilder<QuerySnapshot>(
              future: userDocs,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return buildSearchResults(snapshot.data.documents);
                } else {
                  return Container(
                      alignment: FractionalOffset.center,
                      child: CircularProgressIndicator());
                }
              }),
    );
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}

class UserSearchItem extends StatelessWidget {
  final User user;

  const UserSearchItem(this.user);

  @override
  Widget build(BuildContext context) {
    TextStyle boldStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    );

    return GestureDetector(
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: Text(user.username, style: boldStyle),
          subtitle: Text(user.displayName),
        ),
        onTap: () {
          openProfile(context, user.id);
        });
  }
}
