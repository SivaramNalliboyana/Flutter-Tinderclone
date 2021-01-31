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
  Widget build(BuildContext context) {
    return Scaffold(
      body: loggedin ? BottomNavigationBarScreen() : AuthenticationScreen(),
    );
  }
}
