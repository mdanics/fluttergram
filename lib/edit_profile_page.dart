import 'dart:io';

import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'main.dart'; //for currentuser & google signin instance
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? imageFile;
  ImagePicker imagePicker = ImagePicker();
  String profilePicURL = '';

  final TextEditingController nameController =
      TextEditingController(text: currentUserModel!.displayName);
  final TextEditingController bioController =
      TextEditingController(text: currentUserModel!.bio);

  Future<String> uploadImage() async {
    var uuid = Uuid().v1();
    Reference ref =
        FirebaseStorage.instance.ref().child("profilePic_$uuid.jpg");
    UploadTask uploadTask = ref.putFile(imageFile!);

    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    setState(() {
      imageFile = null;
    });
    print('BBBBBBBBBBB');
    print(downloadUrl);
    return downloadUrl;
  }

  changeProfilePhoto(BuildContext parentContext) {
    return showDialog<Null>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Change Photo'),
          children: <Widget>[
            SimpleDialogOption(
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  // ignore: deprecated_member_use
                  PickedFile? pickerFile = await imagePicker.getImage(
                      source: ImageSource.camera,
                      maxWidth: 1920,
                      maxHeight: 1200,
                      imageQuality: 80);
                  setState(() {
                    imageFile = File(pickerFile!.path);
                  });

                  print('AAAAAAAAAAA');
                }),
            SimpleDialogOption(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  // ignore: deprecated_member_use
                  PickedFile? pickerFile = await imagePicker.getImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      maxHeight: 1200,
                      imageQuality: 80);
                  setState(() {
                    imageFile = File(pickerFile!.path);
                  });

                  print('AAAAAAAAAAA');
                }),
            SimpleDialogOption(
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

  applyChanges() async {
    print('CCCCCCCc');
    print(profilePicURL);

    FirebaseFirestore.instance
        .collection('insta_users')
        .doc(currentUserModel!.id)
        .update({
      "displayName": nameController.text,
      "bio": bioController.text,
      "photoUrl": profilePicURL,
    });
  }

  Widget buildTextField(
      {required String name, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
            name,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: name,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
          title: Text('Edit Profile',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.check,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  uploadImage().then((value) async {
                    setState(() {
                      profilePicURL = value;
                    });
                    try {
                      await FirebaseStorage.instance
                          .refFromURL(currentUserModel!.photoUrl!)
                          .delete();
                      applyChanges();
                    } on Exception catch (_) {}

                    Navigator.maybePop(context);
                  });
                })
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: CircleAvatar(
                backgroundImage: (imageFile == null
                    ? NetworkImage(currentUserModel!.photoUrl!)
                    : FileImage(
                        imageFile!,
                      )) as ImageProvider<Object>?,
                radius: 50.0,
              ),
            ),
            TextButton(
                onPressed: () {
                  changeProfilePhoto(context);
                },
                child: Text(
                  "Change Photo",
                  style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  buildTextField(name: "Name", controller: nameController),
                  buildTextField(name: "Bio", controller: bioController),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: MaterialButton(
                    onPressed: () => {_logout(context)}, child: Text("Logout")))
          ],
        ));
  }

  void _logout(BuildContext context) async {
    print("logout");
    await auth.signOut();
    await googleSignIn.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    currentUserModel = null;

    Navigator.pop(context);
  }
}
