import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tinderclone/utils/fonts.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username;
  String profilepic;
  String bio;
  bool dataisThere = false;

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
                        Container(
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
                                style:
                                    mystyle(20, Colors.white, FontWeight.bold)),
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
