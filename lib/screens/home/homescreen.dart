import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:tinderclone/utils/fonts.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SwiperController swipercontroller = SwiperController();
  bool autoplay = false;

  getusers() async {
    print("Getting users");
    String userurl = "https://fluttertinderclone.000webhostapp.com/getdata.php";
    Map sql = {
      'sql':
          'SELECT * FROM users WHERE uid="${FirebaseAuth.instance.currentUser.uid}"'
    };
    http.Response response = await http.post(userurl, body: sql);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDF0F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.person,
            color: Colors.black,
          ),
          iconSize: 32,
          onPressed: () {},
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
                              fit: BoxFit.cover,
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
                                    onPressed: () {},
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
