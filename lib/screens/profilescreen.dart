import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinderclone/utils/fonts.dart';
import 'package:http/http.dart' as http;
import 'package:tinderclone/utils/variables.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username;
  String profilepic;
  String bio;
  bool dataisThere = false;
  var imagepath;
  TextEditingController usernamecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getuserdata();
  }

  getuserdata() async {
    String apiurl = 'https://fluttertinderclone.000webhostapp.com/getdata.php';
    Map sql = {
      'sql':
          'SELECT * FROM users WHERE uid="${FirebaseAuth.instance.currentUser.uid}"'
    };
    var response = await http.post(apiurl, body: sql);
    var result = jsonDecode(response.body);
    print(result);
    setState(() {
      username = result[0]['name'];
      profilepic = result[0]['profilepic'];
      bio = result[0]['bio'];
      dataisThere = true;
    });
  }

  getlikes() async {
    String apiurl = 'https://fluttertinderclone.000webhostapp.com/getdata.php';
    Map sql = {
      'sql':
          'SELECT * FROM likes WHERE reciever="${FirebaseAuth.instance.currentUser.uid}"'
    };
    var response = await http.post(apiurl, body: sql);
    var result = jsonDecode(response.body);
    return result;
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

  uploadimage() async {
    UploadTask storageUploadtask =
        imagesbucket.child(username).putFile(imagepath);
    TaskSnapshot storageUploadsnapshot =
        await storageUploadtask.whenComplete(() {});
    String downloadurl = await storageUploadsnapshot.ref.getDownloadURL();
    return downloadurl;
  }

  updateprofile() async {
    String url = 'https://fluttertinderclone.000webhostapp.com/edituser.php';
    String userid = FirebaseAuth.instance.currentUser.uid;
    // only name
    if (usernamecontroller.text != '' && imagepath == null) {
      Map query = {
        'sql':
            'UPDATE users SET name="${usernamecontroller.text}" WHERE uid="$userid"'
      };
      var post = await http.post(url, body: query);
      setState(() {
        username = usernamecontroller.text;
      });
      usernamecontroller.clear();
      Navigator.pop(context);
    }

    // only image
    if (usernamecontroller.text == '' && imagepath != null) {
      String downloadurl = await uploadimage();
      Map query = {
        'sql': 'UPDATE users SET profilepic="$downloadurl" WHERE uid="$userid"'
      };
      var post = await http.post(url, body: query);
      setState(() {
        profilepic = downloadurl;
      });
      Navigator.pop(context);
    }

    // name and image
    if (usernamecontroller.text != '' && imagepath != null) {
      String downloadurl = await uploadimage();
      Map query = {
        'sql':
            'UPDATE users SET profilepic="$downloadurl", name="${usernamecontroller.text}" WHERE uid="$userid"'
      };
      var post = await http.post(url, body: query);
      setState(() {
        username = usernamecontroller.text;
        profilepic = downloadurl;
      });
      usernamecontroller.clear();
      Navigator.pop(context);
    }
  }

  openeditdialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            height: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imagepath == null
                    ? IconButton(
                        icon: Icon(Icons.add_a_photo,
                            color: Colors.pink, size: 55),
                        onPressed: () => optionsdialog(),
                      )
                    : InkWell(
                        onTap: () => optionsdialog(),
                        child: CircleAvatar(
                          backgroundImage: FileImage(imagepath),
                          radius: 32,
                        ),
                      ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                    controller: usernamecontroller,
                    decoration: InputDecoration(
                        hintText: "Edit name",
                        hintStyle: mystyle(20, Colors.black, FontWeight.w600)),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () => updateprofile(),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFB9245),
                          Color(0xFFF54E68),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text("Update",
                          style: mystyle(20, Colors.white, FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 32, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: Image(
          width: 45,
          height: 45,
          image: AssetImage('images/love.png'),
        ),
        centerTitle: true,
      ),
      body: dataisThere == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFB9245),
                          Color(0xFFF54E68),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 60),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          margin: EdgeInsets.only(left: 50, right: 50),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image(
                                fit: BoxFit.cover,
                                image: NetworkImage(profilepic)),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          username,
                          style: mystyle(30, Colors.black, FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          bio,
                          style: mystyle(25, Colors.black, FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () => openeditdialog(),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFFB9245),
                                  Color(0xFFF54E68),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text("Edit Profile",
                                  style: mystyle(
                                      20, Colors.white, FontWeight.bold)),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 20),
                          child: Text(
                            "Likes",
                            style: mystyle(20, Colors.pink, FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        FutureBuilder(
                            future: getlikes(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return Card(
                                    elevation: 8.0,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(snapshot
                                              .data[index]['profilepic'])),
                                      title: Text(
                                        snapshot.data[index]['name'],
                                        style: mystyle(
                                            25, Colors.black, FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        snapshot.data[index]['bio'],
                                        style: mystyle(
                                            18, Colors.black, FontWeight.w600),
                                      ),
                                    ),
                                  );
                                },
                              );
                            })
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
