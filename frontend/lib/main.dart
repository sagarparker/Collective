import 'package:collective/widgets/SplashScreenWidget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Color.fromRGBO(24, 119, 242, 1.0),
          backgroundColor: Colors.white,
          fontFamily: 'Avenir'),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: EdgeInsets.only(top: 220),
          child: SplashScreenWidget(),
        ),
      ),
    );
  }
}
