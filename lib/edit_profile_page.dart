import "package:flutter/material.dart";
import 'main.dart'; //for currentuser model

class EditProfilePage extends StatelessWidget {
  changeProfilePhoto(BuildContext Context) {
    return showDialog(
      context: Context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Change Photo'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(
                    'Changing your profile photo has not been implemented yet'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTextField({String name, TextEditingController controller}) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            name,
            style: new TextStyle(color: Colors.grey),
          ),
        ),
        new TextField(
          controller: controller,
          decoration: new InputDecoration(
            hintText: name,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: new CircleAvatar(
            backgroundImage: NetworkImage(currentUserModel.photoUrl),
            radius: 50.0,
          ),
        ),
        new FlatButton(
            onPressed: () {
              changeProfilePhoto(context);
            },
            child: new Text(
              "Change Photo",
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            )),
        new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Column(
            children: <Widget>[
              buildTextField(name: "Name", controller: null),
              buildTextField(name: "Website", controller: null),
              buildTextField(name: "Bio", controller: null),
            ],
          ),
        )
      ],
    );
  }
}
