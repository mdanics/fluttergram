import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart'; //for currentuser & google signin instance
import 'models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  File _image;
  String imagelink = "";


  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
    uploadPic();
  }

  Future uploadPic() async{
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("${widget.userid}/profile");
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot=await uploadTask.onComplete;
    String docUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      imagelink = docUrl;
    });
  }
  
  applyChanges() {
    Firestore.instance
        .collection('insta_users')
        .document(currentUserModel.id)
        .updateData({
      "displayName": nameController.text,
      "bio": bioController.text,
       "photourl": imagelink,
    });
  }

  Widget buildTextField({String name, TextEditingController controller}) {
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
    return FutureBuilder(
        future: Firestore.instance
            .collection('insta_users')
            .document(currentUserModel.id)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                child: CircularProgressIndicator());

          User user = User.fromDocument(snapshot.data);

          nameController.text = user.displayName;
          bioController.text = user.bio;

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(currentUserModel.photoUrl),
                  radius: 50.0,
                ),
              ),
              FlatButton(
                  onPressed: () {
                    getImage;
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
                    onPressed: () => {_logout(context)},
                    child: Text("Logout")

                )
              )
            ],
          );
        });
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
