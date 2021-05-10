import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:http/http.dart';
import 'package:tinderclone/screens/profilescreen.dart';
import 'package:tinderclone/utils/fonts.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SwiperController swipercontroller = SwiperController();
  bool autoplay = false;
  String username;
  String bio;
  String profilepic;
  GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();

  initState() {
    super.initState();
    getcurrentuserdata();
  }

  getusers() async {
    print("Getting users");
    String userurl = "<Your api url>";
    Map sql = {
      'sql':
          'SELECT * FROM users WHERE uid="${FirebaseAuth.instance.currentUser.uid}"'
    };
    http.Response response = await http.post(userurl, body: sql);
    print(response);
    var result = jsonDecode(response.body);

    if (result[0]['gender'] == "Male") {
      http.Response response = await http.post(userurl,
          body: {'sql': 'SELECT * FROM users WHERE gender="Female"'});
      return jsonDecode(response.body);
    } else {
      http.Response response = await http.post(userurl,
          body: {'sql': 'SELECT * FROM users WHERE gender="Male"'});
      return jsonDecode(response.body);
    }
  }

  getcurrentuserdata() async {
    print("Getting currengt user");
    String userurl = "<Your api url>";
    Map sql = {
      'sql':
          'SELECT * FROM users WHERE uid="${FirebaseAuth.instance.currentUser.uid}"'
    };
    http.Response response = await http.post(userurl, body: sql);
    print(response);
    var result = jsonDecode(response.body);
    setState(() {
      username = result[0]["name"];
      bio = result[0]["bio"];
      profilepic = result[0]["profilepic"];
    });
  }

  congratsdialog(String name, String recieverprofilepic) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.pink, Colors.purple])),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "It is a MATCH",
                    style: mystyle(20, Colors.white, FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image(
                          width: 127,
                          height: 150,
                          image: NetworkImage(recieverprofilepic),
                        ),
                      ),
                      Image(
                        width: 45,
                        height: 45,
                        image: AssetImage('images/love.png'),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image(
                          width: 127,
                          height: 150,
                          image: NetworkImage(profilepic),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "You both have liked each other",
                    textAlign: TextAlign.center,
                    style: mystyle(16, Colors.white, FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        });
  }

  likeuser(String uid, String name, String recieverprofilepic) async {
    print("Getting likes");
    String currentuserid = FirebaseAuth.instance.currentUser.uid;
    String api = "<Your api url>";
    Map getlikessql = {
      'sql':
          'SELECT * FROM likes WHERE liker="$currentuserid" AND reciever="$uid"'
    };
    http.Response response = await http.post(api, body: getlikessql);
    List getlikeslist = jsonDecode(response.body);
    if (getlikeslist.length == 0) {
      Map likesql = {
        'sql':
            'INSERT INTO likes (id,liker,reciever,name,profilepic,bio) VALUES (NULL,"$currentuserid", "$uid","$username","$profilepic","$bio")'
      };
      http.Response response = await http.post(api, body: likesql);
      SnackBar snackBar = SnackBar(
          content: Text(
        "Your like was added",
        style: mystyle(20, Colors.white, FontWeight.w700),
      ));
      scaffoldkey.currentState.showSnackBar(snackBar);
    } else {
      print("Already Liked");
      SnackBar snackBar = SnackBar(
          content: Text(
        "Already Liked",
        style: mystyle(20, Colors.white, FontWeight.w700),
      ));
      scaffoldkey.currentState.showSnackBar(snackBar);
    }

    // Check if both have liked
    print("Checking if both have liked");
    Map checkbothsql = {
      'sql':
          'SELECT * FROM likes WHERE (liker="$currentuserid" AND reciever ="$uid") OR (liker="$uid" AND reciever ="$currentuserid")'
    };
    Response checkbothresponse = await http.post(api, body: checkbothsql);
    List checkbothresponse_result = jsonDecode(checkbothresponse.body);
    if (checkbothresponse_result.length == 2) {
      congratsdialog(name, recieverprofilepic);
    } else {
      print("No did not like eachother");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      backgroundColor: Color(0xFFEDF0F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.person,
            color: Colors.black,
          ),
          iconSize: 32,
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => ProfileScreen())),
        ),
        title: Image(
          width: 45,
          height: 45,
          image: AssetImage('images/love.png'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.black,
              ),
              iconSize: 32,
              onPressed: () => FirebaseAuth.instance.signOut())
        ],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            FutureBuilder(
                future: getusers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Swiper(
                    itemCount: 3,
                    layout: SwiperLayout.TINDER,
                    itemWidth: 600,
                    itemHeight: 500,
                    controller: swipercontroller,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Stack(
                          children: [
                            Image(
                              width: 600,
                              height: 500,
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  snapshot.data[index]['profilepic']),
                            ),
                            Container(
                              width: 600,
                              height: 70,
                              decoration: BoxDecoration(color: Colors.white),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data[index]['name'],
                                          style: mystyle(
                                              25, Colors.pink, FontWeight.bold),
                                        ),
                                        Text(
                                          snapshot.data[index]['bio'],
                                          style: mystyle(
                                              20, Colors.pink, FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    ),
                                    iconSize: 32,
                                    onPressed: () => likeuser(
                                        snapshot.data[index]['uid'],
                                        snapshot.data[index]['name'],
                                        snapshot.data[index]['profilepic']),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => swipercontroller.previous(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                      child: Icon(Icons.replay, color: Colors.amber, size: 32),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => swipercontroller.next(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                      child: Icon(Icons.cancel, color: Colors.red, size: 32),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (autoplay) {
                      swipercontroller.stopAutoplay();
                      setState(() {
                        autoplay = false;
                      });
                    } else {
                      swipercontroller.startAutoplay();
                      setState(() {
                        autoplay = true;
                      });
                    }
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Center(
                      child: Icon(autoplay ? Icons.stop : Icons.play_arrow,
                          color: Colors.greenAccent, size: 32),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
