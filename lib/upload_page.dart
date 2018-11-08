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
import 'location.dart';
import 'package:geocoder/geocoder.dart';

class Uploader extends StatefulWidget {
  _Uploader createState() => new _Uploader();
}

class _Uploader extends State<Uploader> {
  File file;
  //Strings required to save address
  Address address;

  Map<String, double> currentLocation = new Map();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController locationController = new TextEditingController();

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
    //variables with location assigned as 0.0
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    initPlatformState(); //method to call location
    super.initState();
  }

  //method to get Location and save into variables
  initPlatformState() async {
    Address first = await getUserLocation();
    setState(() {
      address = first;
    });
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
            body: new ListView(
              children: <Widget>[
                new PostForm(
                  imageFile: file,
                  descriptionController: descriptionController,
                  locationController: locationController,
                  loading: uploading,
                ),
                new Divider(), //scroll view where we will show location to users
                (address == null)
                    ? Container()
                    : new SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.only(right: 5.0, left: 5.0),
                        child: Row(
                          children: <Widget>[
                            buildLocationButton(address.featureName),
                            buildLocationButton(address.subLocality),
                            buildLocationButton(address.locality),
                            buildLocationButton(address.subAdminArea),
                            buildLocationButton(address.adminArea),
                            buildLocationButton(address.countryName),
                          ],
                        ),
                      ),
                (address == null) ? Container() : Divider(),
              ],
            ));
  }

  //method to build buttons with location.
  buildLocationButton(String locationName) {
    if (locationName != null ?? locationName.isNotEmpty) {
      return InkWell(
        onTap: () {
          locationController.text = locationName;
        },
        child: Center(
          child: new Container(
            //width: 100.0,
            height: 30.0,
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            margin: EdgeInsets.only(right: 3.0, left: 3.0),
            decoration: new BoxDecoration(
              color: Colors.grey[200],
              borderRadius: new BorderRadius.circular(5.0),
            ),
            child: new Center(
              child: new Text(
                locationName,
                style: new TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _selectImage() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return new SimpleDialog(
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
        );
      },
    );
  }

  void compressImage() async {
    print('starting compression');
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int rand = new Math.Random().nextInt(10000);

    Im.Image image = Im.decodeImage(file.readAsBytesSync());
    Im.copyResize(image, 500);

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
    uploadImage(file).then((String data) {
      postToFireStore(
          mediaUrl: data,
          description: descriptionController.text,
          location: locationController.text);
    }).then((_) {
      setState(() {
        file = null;
        uploading = false;
      });
    });
  }
}

class PostForm extends StatelessWidget {
  final imageFile;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final bool loading;
  PostForm(
      {this.imageFile,
      this.descriptionController,
      this.loading,
      this.locationController});

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        loading
            ? new LinearProgressIndicator()
            : new Padding(padding: new EdgeInsets.only(top: 0.0)),
        new Divider(),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new CircleAvatar(
              backgroundImage: new NetworkImage(currentUserModel.photoUrl),
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
              height: 45.0,
              width: 45.0,
              child: new AspectRatio(
                aspectRatio: 487 / 451,
                child: new Container(
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                    fit: BoxFit.fill,
                    alignment: FractionalOffset.topCenter,
                    image: new FileImage(imageFile),
                  )),
                ),
              ),
            ),
          ],
        ),
        new Divider(),
        new ListTile(
          leading: new Icon(Icons.pin_drop),
          title: new Container(
            width: 250.0,
            child: new TextField(
              controller: locationController,
              decoration: new InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }
}

Future<String> uploadImage(var imageFile) async {
  var uuid = new Uuid().v1();
  StorageReference ref = FirebaseStorage.instance.ref().child("post_$uuid.jpg");
  StorageUploadTask uploadTask = ref.putFile(imageFile);

  String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
  return downloadUrl;
}

void postToFireStore(
    {String mediaUrl, String location, String description}) async {
  var reference = Firestore.instance.collection('insta_posts');

  reference.add({
    "username": currentUserModel.username,
    "location": location,
    "likes": {},
    "mediaUrl": mediaUrl,
    "description": description,
    "ownerId": googleSignIn.currentUser.id,
    "timestamp": new DateTime.now().toString(),
  }).then((DocumentReference doc) {
    String docId = doc.documentID;
    reference.document(docId).updateData({"postId": docId});
  });
}
