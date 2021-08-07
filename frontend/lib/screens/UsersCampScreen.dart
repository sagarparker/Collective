import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';

class UsersCampScreen extends StatefulWidget {
  static String routeName = 'usersCampScreen';

  @override
  _UsersCampScreenState createState() => _UsersCampScreenState();
}

class _UsersCampScreenState extends State<UsersCampScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBarGoBack(),
      ),
    );
    ;
  }
}
