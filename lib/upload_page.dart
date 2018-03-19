import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // new
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'main.dart';


class Uploader extends StatefulWidget {
  _Uploader createState() => new _Uploader();
}

class _Uploader extends State<Uploader> {
  var file;
  TextEditingController descriptionController = new TextEditingController();

  Widget build(BuildContext context) {
    return file == null
        ? new IconButton(
            icon: new Icon(Icons.file_upload), onPressed: _selectImage)
        : new Scaffold(
            appBar: new AppBar(
              backgroundColor: Colors.white70,
              leading: new IconButton(
                  icon: new Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: clearImage),
              title: const Text(
                'Post to',
                style: const TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: postImage,
                    child: new Text(
                      "Post",
                      style: new TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ))
              ],
            ),
            body: new PostForm(
              imageFile: file,
              descriptionController: descriptionController,
            ));
  }

  Future<Null> _selectImage() async {
    var imageFile = await ImagePicker.pickImage();
    setState(() {
      file = imageFile;
    });
  }

  void clearImage() {
    setState(() {
      file = null;
    });
  }

  void postImage() {
    Future<String> upload = uploadImage(file).then((String data) {
      postToFireStore(
          mediaUrl: data, description: descriptionController.text);
    });
  }
}

class PostForm extends StatelessWidget {
  var imageFile;
  TextEditingController descriptionController;
  PostForm({this.imageFile, this.descriptionController});

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Padding(padding: new EdgeInsets.only(top: 10.0)),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new CircleAvatar(
              child: new Text("d"),
            ),
            new Container(
              width: 250.0,
              child: new TextField(
                controller: descriptionController,
                decoration: new InputDecoration(
                    hintText: "Write a caption...", border: InputBorder.none),
              ),
            ),
            new Container(
                height: 50.0,
                child: new Image.file(
                  imageFile,
                  fit: BoxFit.fitHeight,
                ))
          ],
        ),
        new Divider()
      ],
    );
  }
}

Future<String> uploadImage(var imageFile) async {
  var uuid = new Uuid().v1();
  StorageReference ref = FirebaseStorage.instance.ref().child("post_$uuid.jpg");
  StorageUploadTask uploadTask = ref.put(imageFile);
  Uri downloadUrl = (await uploadTask.future).downloadUrl;
  return downloadUrl.toString();
}

void postToFireStore({String mediaUrl, String location, String description}) async {
  var reference = Firestore.instance.collection('insta_posts');

  reference.add({
    "username": "testeronslice",
    "location": "nice location",
    "likes": 0,
    "mediaUrl": mediaUrl,
    "description": description,
    "ownerId": googleSignIn.currentUser.id
  });
}
