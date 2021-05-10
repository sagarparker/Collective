import 'package:collective/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashScreenWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: LoginScreen(),
      image: Image.asset('assets/images/Logo.png'),
      backgroundColor: Theme.of(context).backgroundColor,
      photoSize: 60.0,
      useLoader: false,
    );
  }
}
