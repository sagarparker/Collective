import 'package:collective/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/services.dart';

class SplashScreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.only(top: 230),
        child: SplashScreen(
          seconds: 1,
          navigateAfterSeconds: LoginScreen(),
          image: Image.asset('assets/images/Logo.png'),
          backgroundColor: Theme.of(context).backgroundColor,
          photoSize: 50.0,
          useLoader: false,
        ),
      ),
    );
  }
}
