import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => new _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final name = new TextEditingController();


  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context2) {
    return new Column(children: [
      new Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: new Center(
          child: new Text(
            "What Is Your Name?",
            style: new TextStyle(fontSize: 25.0),
          ),
        ),
      ),
      new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Container(
          decoration: new BoxDecoration(
              border: new Border.all(width: 1.0, color: Colors.black26),
              borderRadius: new BorderRadius.circular(7.0)),
          child: new TextField(
            controller: name,
            decoration: new InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(10.0),
                labelText: "Full Name",
                labelStyle: new TextStyle(fontSize: 15.0)),
          ),
        ),
      ),
      new GestureDetector(
        onTap: () {
          if (name.text == null || name.text.length == 0){
            return;
          }
          Navigator.pop(context, name.text);
        },


          child: new Container(
        width: 350.0,
        height: 50.0,
        child: new Center(
            child: new Text(
          "Next",
          style: new TextStyle(
              color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
        )),
        decoration: new BoxDecoration(
            color: Colors.blue, borderRadius: new BorderRadius.circular(7.0)),
      ))
    ]);
  }
}
