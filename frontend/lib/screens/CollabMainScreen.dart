import 'package:collective/screens/CreateCampCollabJobScreen.dart';
import 'package:collective/widgets/CampScreenWidgets/CampCollaboratorsWidget.dart';
import 'package:collective/widgets/CampScreenWidgets/OpportunitiesListWidget.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:collective/widgets/keepAlivePage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class CollabMainScreen extends StatefulWidget {
  static String routeName = '/collabMainScreen';

  @override
  _CollabMainScreenState createState() => _CollabMainScreenState();
}

class _CollabMainScreenState extends State<CollabMainScreen>
    with TickerProviderStateMixin {
  Map selectedCamp = {};
  String token;
  String username;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    setToken();
    _tabController = new TabController(length: 2, vsync: this);
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      token = prefValue.getString('token');
      username = prefValue.getString('username');
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    selectedCamp = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBarGoBack(),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Container(
              height: 50,
              child: TabBar(
                labelPadding: EdgeInsets.only(top: 5),
                indicatorPadding: EdgeInsets.only(left: 15, right: 15),
                indicatorColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black38,
                labelColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Avenir',
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  fontFamily: 'Avenir',
                ),
                tabs: [
                  Tab(
                    child: Text(
                      "Opportunities",
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Collaborators",
                    ),
                  ),
                ],
                controller: _tabController,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 22),
            color: Colors.white,
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                88,
            width: MediaQuery.of(context).size.width,
            child: TabBarView(
              controller: _tabController,
              children: [
                KeepAlivePage(child: OpportunitiesListWidget(selectedCamp)),
                KeepAlivePage(child: CampCollaboratorsWidget(selectedCamp)),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: selectedCamp['campOwner'] == this.username
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(CreateCampCollabJobScreen.routeName, arguments: {
                  "campId": selectedCamp['campId'],
                  "campOwner": selectedCamp['campOwner']
                });
              },
              elevation: 4,
              child: const Icon(
                Icons.add,
                color: Color.fromRGBO(24, 119, 242, 1.0),
              ),
              backgroundColor: Color.fromRGBO(230, 230, 230, 1),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}
