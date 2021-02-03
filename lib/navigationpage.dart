import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tinderclone/screens/authentication/authenticationscreen.dart';
import 'package:tinderclone/screens/bottomnavbarscreen.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  bool loggedin = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          loggedin = true;
        });
      } else {
        loggedin = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loggedin ? BottomNavigationBarScreen() : AuthenticationScreen(),
    );
  }
}
