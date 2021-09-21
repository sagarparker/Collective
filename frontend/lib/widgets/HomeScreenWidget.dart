import 'package:collective/screens/BuyCtvScreen.dart';
import 'package:collective/widgets/CampListViewWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreenWidget extends StatefulWidget {
  @override
  _HomeScreenWidgetState createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  String token;
  Future usersAccountBalance;
  Future campList;

  @override
  void initState() {
    super.initState();
    setToken();
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      token = prefValue.getString('token');
      usersAccountBalance = getUserBalance(token);
      campList = getCamps(token);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
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
                            Row(
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    minimumSize: Size(0, 0),
                                    padding: EdgeInsets.only(left: 10),
                                  ),
                                  child: Icon(
                                    Icons.restart_alt,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    usersAccountBalance = getUserBalance(token);
                                    setState(() {});
                                  },
                                ),
                              ],
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
                          future: usersAccountBalance,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.none ||
                                snapshot.connectionState ==
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
                                            primary:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(60)),
                                            minimumSize: Size(90, 35)),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              BuyCtvScreen.routeName);
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            'Buy',
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
                  Container(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size(0, 0),
                        padding: EdgeInsets.only(
                          left: 30,
                        ),
                      ),
                      child: Icon(
                        Icons.restart_alt,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                      onPressed: () {
                        campList = getCamps(token);
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 600,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 10, right: 10, top: 5),
              child: FutureBuilder<dynamic>(
                  future: campList,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
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
                            child: Padding(
                          padding: const EdgeInsets.only(bottom: 150.0),
                          child: Text(snapshot.data['msg']),
                        ));
                      } else {
                        return CampListViewWidget(snapshot);
                      }
                    }
                  }),
            ),
          ],
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

Future<dynamic> getCamps(String token) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request =
      http.Request('POST', Uri.parse('http://3.135.1.141/api/getCampList'));
  request.body = json.encode({"sort_by": "High target"});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
