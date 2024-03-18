import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final name = TextEditingController();


  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context2) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 25.0),
        child: Center(
          child: Text(
            "Create a username",
            style: TextStyle(fontSize: 25.0),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.black26),
              borderRadius: BorderRadius.circular(7.0)),
          child: TextField(
            controller: name,
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(10.0),
                labelText: "Username",
                labelStyle: TextStyle(fontSize: 15.0)),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          if (name.text == null || name.text.length == 0){
            return;
          }
          Navigator.pop(context, name.text);
        },


          child: Container(
        width: 350.0,
        height: 50.0,
        child: Center(
            child: Text(
          "Next",
          style: TextStyle(
              color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
        )),
        decoration: BoxDecoration(
            color: Colors.blue, borderRadius: BorderRadius.circular(7.0)),
      ))
    ]);
  }
}
