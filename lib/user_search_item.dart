import 'package:flutter/material.dart';
import 'models/user.dart';
import "profile_page.dart"; // needed to import for openProfile function

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