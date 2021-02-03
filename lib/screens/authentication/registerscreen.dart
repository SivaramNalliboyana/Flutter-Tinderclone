import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinderclone/utils/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:tinderclone/utils/variables.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool ismale = true;
  File imagepath;
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController biocontroller = TextEditingController();

  uploadimage() async {
    UploadTask storageUploadtask =
        imagesbucket.child(usernamecontroller.text).putFile(imagepath);
    TaskSnapshot storageUploadsnapshot =
        await storageUploadtask.whenComplete(() {});
    String downloadurl = await storageUploadsnapshot.ref.getDownloadURL();
    return downloadurl;
  }

  createuser() {
    try {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailcontroller.text, password: passwordcontroller.text)
          .then((signeduser) async {
        String downloadurl = await uploadimage();
        String url =
            "https://fluttertinderclone.000webhostapp.com/createuser.php";
        Map data = {
          "name": usernamecontroller.text,
          "email": emailcontroller.text,
          "gender": ismale == true ? "Male" : "Female",
          "bio": biocontroller.text,
          "password": passwordcontroller.text,
          "profilepic": downloadurl,
          "uid": signeduser.user.uid
        };
        var post = await http.post(url, body: data);
        print(post);
      });
    } catch (e) {}
  }

  pickimage(ImageSource source) async {
    Navigator.pop(context);
    final imagefile = await ImagePicker()
        .getImage(source: source, maxHeight: 680, maxWidth: 970);
    setState(
      () {
        imagepath = File(imagefile.path);
      },
    );
  }

  optionsdialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: () => pickimage(ImageSource.gallery),
                child: Text(
                  "Choose from gallery",
                  style: mystyle(20, Colors.pink, FontWeight.w700),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => pickimage(ImageSource.camera),
                child: Text(
                  "Choose from camera",
                  style: mystyle(20, Colors.pink, FontWeight.w700),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: mystyle(20, Colors.pink, FontWeight.w700),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Stack(
            overflow: Overflow.visible,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 15, right: 15, bottom: 15),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailcontroller,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Email",
                            labelStyle:
                                mystyle(15, Colors.black, FontWeight.w600),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            prefixIcon: Icon(Icons.email)),
                      ),
                      TextField(
                        controller: passwordcontroller,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Password",
                            labelStyle:
                                mystyle(15, Colors.black, FontWeight.w600),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            prefixIcon: Icon(Icons.lock)),
                      ),
                      TextField(
                        controller: usernamecontroller,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Username",
                            labelStyle:
                                mystyle(15, Colors.black, FontWeight.w600),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            prefixIcon: Icon(Icons.person)),
                      ),
                      TextField(
                        controller: biocontroller,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: "Your bio",
                            labelStyle:
                                mystyle(15, Colors.black, FontWeight.w600),
                            enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            prefixIcon: Icon(Icons.description)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RaisedButton(
                            color:
                                ismale ? Colors.deepOrange : Colors.grey[300],
                            child: Text("Male",
                                style:
                                    mystyle(20, Colors.black, FontWeight.w600)),
                            onPressed: () {
                              setState(() {
                                ismale = true;
                              });
                            },
                          ),
                          RaisedButton(
                            color:
                                !ismale ? Colors.deepOrange : Colors.grey[300],
                            child: Text("Female",
                                style:
                                    mystyle(20, Colors.black, FontWeight.w600)),
                            onPressed: () {
                              setState(() {
                                ismale = false;
                              });
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Your Image",
                            style: mystyle(20, Colors.pink, FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () => optionsdialog(),
                            child: imagepath == null
                                ? Icon(Icons.add_a_photo,
                                    color: Colors.pink, size: 45)
                                : CircleAvatar(
                                    radius: 32,
                                    backgroundImage: FileImage(imagepath),
                                  ),
                          )
                        ],
                      ),
                      Divider(color: Colors.transparent, height: 40)
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 380,
                child: InkWell(
                  onTap: () => createuser(),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [Color(0xFFFB9245), Color(0xFFF54E68)],
                        )),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          "Register",
                          style: mystyle(18, Colors.white, FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
