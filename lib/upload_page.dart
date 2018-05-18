import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'main.dart';
import 'dart:io';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;

class Uploader extends StatefulWidget {
  _Uploader createState() => new _Uploader();
}

class _Uploader extends State<Uploader> {
  File file;
  TextEditingController descriptionController = new TextEditingController();

  bool uploading = false;
  bool promted = false;

  @override
  initState() {
    if (file == null && promted == false && pageController.page == 2) {
      _selectImage();
      setState(() {
        promted = true;
      });
    }

    super.initState();
  }

  Widget build(BuildContext context) {
    return file == null
        ? new IconButton(
            icon: new Icon(Icons.file_upload), onPressed: _selectImage)
        : new Scaffold(
            resizeToAvoidBottomPadding: false,
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
            body: new Column(
              children: <Widget>[
                new PostForm(
                  imageFile: file,
                  descriptionController: descriptionController,
                  loading: uploading,
                ),
              ],
            ));
  }

  _selectImage() async {
    return showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!

        child: new SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            new SimpleDialogOption(
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.camera);
                  setState(() {
                    file = imageFile;
                  });
                }),
            new SimpleDialogOption(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    file = imageFile;
                  });
                }),
            new SimpleDialogOption(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ));
  }

  void compressImage() async {
    print('startin');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(10000);

    Im.Image image = Im.decodeImage(file.readAsBytesSync());
    Im.Image s = Im.copyResize(image, 500);

//    image.format = Im.Image.RGBA;
//    Im.Image newim = Im.remapColors(image, alpha: Im.LUMINANCE);

    var newim2 = new File('$path/img_$rand.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      file = newim2;
    });
    print('done');
  }

  void clearImage() {
    setState(() {
      file = null;
    });
  }

  void postImage() {
    setState(() {
      uploading = true;
    });
    compressImage();
    Future<String> upload = uploadImage(file).then((String data) {
      postToFireStore(mediaUrl: data, description: descriptionController.text);
    }).then((_) {
      setState(() {
        file = null;
        uploading = false;
      });
    });
  }
}

class PostForm extends StatelessWidget {
  var imageFile;
  TextEditingController descriptionController;
  bool loading;
  PostForm({this.imageFile, this.descriptionController, this.loading});

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        loading
            ? new LinearProgressIndicator()
            : new Padding(padding: new EdgeInsets.only(top: 0.0)),
        new Container(
            child: new Image.file(
          imageFile,
          fit: BoxFit.fitWidth,
        )),
        new Divider(),
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

void postToFireStore(
    {String mediaUrl, String location, String description}) async {
  var reference = Firestore.instance.collection('insta_posts');

  reference.add({
    "username": "testeronslice",
    "location": "nice location",
    "likes": {},
    "mediaUrl": mediaUrl,
    "description": description,
    "ownerId": googleSignIn.currentUser.id,
    "timestamp": new DateTime.now().toString(),
  }).then((DocumentReference doc){
    String docId = doc.documentID;
    reference.document(docId).updateData({"postId" : docId});
  });
}
