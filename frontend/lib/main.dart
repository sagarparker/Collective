import 'package:collective/screens/BuyCtvScreen.dart';
import 'package:collective/screens/CampScreen.dart';
import 'package:collective/screens/CollabMainScreen.dart';
import 'package:collective/screens/CreateCampCollabJobScreen.dart';
import 'package:collective/screens/CreateCampHomeScreen.dart';
import 'package:collective/screens/CreateCampScreen.dart';
import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/screens/InvestInCamp.dart';
import 'package:collective/screens/LoginScreen.dart';
import 'package:collective/screens/RegisterScreen.dart';
import 'package:collective/screens/SupportEmailScreen.dart';
import 'package:collective/screens/UserDetailsScreen.dart';
import 'package:collective/screens/UserInvestmentScreen.dart';
import 'package:collective/screens/UsersCampScreen.dart';
import 'package:collective/screens/UsersCollabScreen.dart';
import 'package:collective/widgets/SplashScreenWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    systemNavigationBarDividerColor: Color.fromRGBO(240, 240, 240, 1),
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
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
      home: SplashScreenWidget(),
      routes: {
        LoginScreen.routeName: (ctx) => LoginScreen(),
        RegisterScreen.routeName: (ctx) => RegisterScreen(),
        HomeScreen.routeName: (ctx) => HomeScreen(),
        BuyCtvScreen.routeName: (ctx) => BuyCtvScreen(),
        CreateCampScreen.routeName: (ctx) => CreateCampScreen(),
        CampScreen.routeName: (ctx) => CampScreen(),
        InvestInCamp.routeName: (ctx) => InvestInCamp(),
        UserDetailsScreen.routeName: (ctx) => UserDetailsScreen(),
        UserInvestmentScreen.routeName: (ctx) => UserInvestmentScreen(),
        UsersCollabScreen.routeName: (ctx) => UsersCollabScreen(),
        UsersCampScreen.routeName: (ctx) => UsersCampScreen(),
        SupportEmailScreen.routeName: (ctx) => SupportEmailScreen(),
        CreateCampHomeScreen.routeName: (ctx) => CreateCampHomeScreen(),
        CollabMainScreen.routeName: (ctx) => CollabMainScreen(),
        CreateCampCollabJobScreen.routeName: (ctx) =>
            CreateCampCollabJobScreen(),
      },
    );
  }
}
