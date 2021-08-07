import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';

class UserInvestmentScreen extends StatefulWidget {
  @override
  _UserInvestmentScreenState createState() => _UserInvestmentScreenState();

  static String routeName = "/UserInvestmentScreen";
}

class _UserInvestmentScreenState extends State<UserInvestmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBarGoBack(),
      ),
    );
  }
}
