import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreenWidget extends StatefulWidget {
  @override
  _SplashScreenWidgetState createState() => _SplashScreenWidgetState();
}

class _SplashScreenWidgetState extends State<SplashScreenWidget> {
  bool _isLogedIn = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefValue) => {
          setState(() {
            if (prefValue.containsKey('token')) {
              _isLogedIn = true;
            }
          })
        });
  }

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
          navigateAfterSeconds: _isLogedIn ? HomeScreen() : LoginScreen(),
          image: Image.asset('assets/images/Logo.png'),
          backgroundColor: Theme.of(context).backgroundColor,
          photoSize: 50.0,
          useLoader: false,
        ),
      ),
    );
  }
}
