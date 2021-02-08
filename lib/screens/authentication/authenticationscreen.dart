import 'package:flutter/material.dart';
import 'package:tinderclone/screens/authentication/loginscreen.dart';
import 'package:tinderclone/screens/authentication/registerscreen.dart';
import 'package:tinderclone/utils/fonts.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  bool islogintab = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color(0xFFFB9245),
            Color(0xFFF54E68),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: [
                Image.asset(
                  'images/love.png',
                  width: 170,
                  height: 170,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                islogintab = !islogintab;
                              });
                            },
                            child: Container(
                              decoration: islogintab == true
                                  ? BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25))
                                  : BoxDecoration(),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Login",
                                    style: mystyle(
                                        18, Colors.black, FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                islogintab = !islogintab;
                              });
                            },
                            child: Container(
                              decoration: islogintab == false
                                  ? BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25))
                                  : BoxDecoration(),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Register",
                                    style: mystyle(
                                        18, Colors.black, FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: LoginScreen(),
                  secondChild: RegisterScreen(),
                  crossFadeState: islogintab
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 150),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
