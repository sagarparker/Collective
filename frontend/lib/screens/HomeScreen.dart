import 'package:collective/screens/BuyCtvScreen.dart';
import 'package:collective/screens/CreateCampScreen.dart';
import 'package:collective/screens/UserDetailsScreen.dart';
import 'package:collective/screens/UserInvestmentScreen.dart';
import 'package:collective/screens/UsersCampScreen.dart';
import 'package:collective/widgets/CampListViewWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  static const routeName = '/homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String token;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    setToken();
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      token = prefValue.getString('token');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      key: _scaffoldKey,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          iconSize: 25,
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        elevation: 2,
        centerTitle: true,
        title: Container(
          width: 155,
          child: Row(
            children: [
              Image.asset(
                'assets/images/Logo.png',
                width: 32,
                height: 32,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.5, left: 3),
                child: Text(
                  'Collective',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(
                Icons.person,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(UserDetailsScreen.routeName);
              })
        ],
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 64,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0, left: 0.0),
                        child: Text(
                          'Collective',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('Account'),
                onTap: () {
                  Navigator.of(context).pushNamed(UserDetailsScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.campaign,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('Camps owned'),
                onTap: () {
                  Navigator.of(context).pushNamed(UsersCampScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                  leading: Icon(
                    Icons.monetization_on,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('Investments'),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(UserInvestmentScreen.routeName);
                  }),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.group,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('Collaborations'),
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.help_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('Support'),
              ),
              Divider()
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 20),
                height: 100,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(248, 248, 248, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            color: Theme.of(context).primaryColor,
                          ),
                          width: MediaQuery.of(context).size.width - 32,
                          height: 40,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 7),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 3),
                                child: Text(
                                  "Wallet",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 19),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                          width: MediaQuery.of(context).size.width - 32,
                          height: 60,
                          child: FutureBuilder<dynamic>(
                            future: getUserBalance(token),
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: SpinKitThreeBounce(
                                    color: Theme.of(context).primaryColor,
                                    size: 20.0,
                                  ),
                                );
                              } else {
                                if (snapshot.data['result'] == false) {
                                  return Center(
                                      child: Text(
                                          'There was a problem fetching balance'));
                                } else {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Image.asset(
                                              'assets/images/Logo.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 3, top: 5),
                                            child: Text(
                                              snapshot.data['CTV_balance']
                                                  .replaceAllMapped(
                                                      new RegExp(
                                                          r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                                      (Match m) => '${m[1]},'),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              elevation: 0,
                                              primary: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          60)),
                                              minimumSize: Size(90, 35)),
                                          onPressed: () {
                                            Navigator.of(context).pushNamed(
                                                BuyCtvScreen.routeName);
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              'Buy CTV',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 60,
                padding: EdgeInsets.only(left: 18, right: 18, top: 19),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular camps",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text('- Filter',
                        style: TextStyle(
                          fontSize: 14,
                        ))
                  ],
                ),
              ),
              Container(
                height: 600,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                child: FutureBuilder<dynamic>(
                    future: getCamps(token),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 190.0),
                          child: Column(
                            children: [
                              SpinKitThreeBounce(
                                color: Theme.of(context).primaryColor,
                                size: 35.0,
                              ),
                            ],
                          ),
                        );
                      } else {
                        if (snapshot.data['result'] == false) {
                          return Center(
                              child:
                                  Text('There was a problem fetching balance'));
                        } else {
                          return CampListViewWidget(snapshot);
                        }
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(CreateCampScreen.routeName);
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}

Future<dynamic> getUserBalance(String token) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'GET', Uri.parse('http://18.217.26.234/api/getUsersAccountBalance'));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}

Future<dynamic> getCamps(String token) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request =
      http.Request('POST', Uri.parse('http://18.217.26.234/api/getCampList'));
  request.body = json.encode({"sort_by": "High target"});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
