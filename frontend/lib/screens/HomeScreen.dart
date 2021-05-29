import 'package:collective/screens/BuyCtvScreen.dart';
import 'package:collective/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:progressive_image/progressive_image.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          iconSize: 25,
          onPressed: () {
            print("XD");
          },
        ),
        elevation: 2,
        centerTitle: true,
        title: Container(
          width: 150,
          child: Row(
            children: [
              Image.asset(
                'assets/images/Logo.png',
                width: 32,
                height: 32,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
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
                                    child: Text('Fetching balance ....'));
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
                                              width: 35,
                                              height: 35,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 3, top: 5),
                                            child: Text(
                                              snapshot.data['CTV_balance'],
                                              style: TextStyle(
                                                fontSize: 25,
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
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
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
                padding: EdgeInsets.only(left: 16, right: 16, top: 19),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Popular camps",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text('- Filter')
                  ],
                ),
              ),
              Container(
                height: 500,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(16),
                child: FutureBuilder<dynamic>(
                    future: getCamps(token),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: Text('Fetching Camps'));
                      } else {
                        if (snapshot.data['result'] == false) {
                          return Center(
                              child:
                                  Text('There was a problem fetching balance'));
                        } else {
                          return ListView.builder(
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromRGBO(245, 245, 245, 1),
                                ),
                                height: 360,
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 180,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32,
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight:
                                                      Radius.circular(15)),
                                              child: ProgressiveImage(
                                                placeholder: AssetImage(
                                                    'assets/images/placeholder.jpg'),
                                                thumbnail: AssetImage(
                                                    'assets/images/placeholder.jpg'),
                                                image: NetworkImage(
                                                    snapshot.data['details']
                                                        [index]['camp_image']),
                                                fit: BoxFit.fill,
                                                height: 180,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    32,
                                              )),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(15),
                                          height: 180,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              32,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15),
                                            ),
                                            color: Color.fromRGBO(
                                                245, 245, 245, 1),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 30,
                                                width: 326,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      snapshot.data['details']
                                                          [index]['name'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 3),
                                                      child: Text(
                                                        '- Tech',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: 80,
                                                width: 326,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 5.0),
                                                  child: Text(
                                                    snapshot.data['details']
                                                            [index]
                                                        ['camp_description'],
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black54),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 40,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/LogoNoPadding.png',
                                                          width: 35,
                                                          height: 35,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 4,
                                                                  left: 3),
                                                          child: Text(
                                                            snapshot
                                                                .data['details']
                                                                    [index]
                                                                    ['target']
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          elevation: 0,
                                                          primary:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          60)),
                                                          minimumSize:
                                                              Size(100, 45)),
                                                      onPressed: () {},
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 2),
                                                        child: Text(
                                                          'Checkout',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: snapshot.data['details'].length,
                          );
                        }
                      }
                    }),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.remove('email');
                        prefs.remove('username');
                        prefs.remove('id');
                        prefs.remove('token');
                        Navigator.of(context)
                            .pushReplacementNamed(LoginScreen.routeName);
                      },
                      child: Text('Logout'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        print(token);
                      },
                      child: Text('Account Data'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
      'GET', Uri.parse('http://3.15.217.59:8080/api/getUsersAccountBalance'));
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
  var request = http.Request(
      'POST', Uri.parse('http://3.15.217.59:8080/api/getCampList'));
  request.body = json.encode({"sort_by": "High target"});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
