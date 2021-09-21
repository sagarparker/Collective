import 'package:collective/screens/LoginScreen.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserDetailsScreen extends StatefulWidget {
  static String routeName = '/userDetailsScreen';

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  String token;

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: AppBarGoBack(),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 16, right: 16, top: 20),
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(245, 245, 245, 1),
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
                                  padding:
                                      const EdgeInsets.only(top: 4, left: 3),
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
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                                top: 5,
                                              ),
                                              child: Text(
                                                'CTV Balance ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: Image.asset(
                                                'assets/images/Logo.png',
                                                width: 23,
                                                height: 23,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 3, top: 5, right: 10),
                                              child: Text(
                                                snapshot.data['CTV_balance']
                                                    .replaceAllMapped(
                                                        new RegExp(
                                                            r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                                        (Match m) =>
                                                            '${m[1]},'),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
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
                  height: 545,
                  width: MediaQuery.of(context).size.width - 20,
                  child: FutureBuilder<dynamic>(
                      future: getUserDetails(token),
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
                            return Container(
                              margin: EdgeInsets.only(top: 25),
                              height: 545,
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      bottom: 30,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Username',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                            snapshot.data['userAuthData']
                                                ['username'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 30,
                                      bottom: 30,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Email-ID',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                            snapshot.data['userAuthData']
                                                ['email'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 30,
                                      bottom: 30,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Camps owned',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          snapshot
                                                  .data['userData']
                                                      ['camps_owned']
                                                  .length
                                                  .toString() +
                                              " camps",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 30,
                                      bottom: 30,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Investments',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          snapshot
                                                  .data['userData']
                                                      ['camps_invested']
                                                  .length
                                                  .toString() +
                                              " investments",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 30,
                                      bottom: 30,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Collaborations',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          snapshot
                                                  .data['userData']
                                                      ['camps_collaborated']
                                                  .length
                                                  .toString() +
                                              " collabs",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.remove('email');
                                        prefs.remove('username');
                                        prefs.remove('id');
                                        prefs.remove('token');
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                LoginScreen.routeName);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.logout),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 3,
                                              bottom: 0,
                                              left: 5,
                                            ),
                                            child: Text(
                                              'Logout',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          primary:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          minimumSize: Size(100, 45)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
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
      'GET', Uri.parse('http://3.135.1.141/api/getUsersAccountBalance'));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}

Future<dynamic> getUserDetails(String token) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request =
      http.Request('POST', Uri.parse('http://3.135.1.141/api/getUserDetails'));

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
