import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CollabRequestsScreen extends StatefulWidget {
  static String routeName = '/collabRequestsScreen';
  final String collabId;
  final String campAddress;
  final String collabTitle;
  final String collabAmount;

  CollabRequestsScreen(
      {this.collabId, this.campAddress, this.collabTitle, this.collabAmount});

  @override
  _CollabRequestsScreenState createState() => _CollabRequestsScreenState();
}

class _CollabRequestsScreenState extends State<CollabRequestsScreen> {
  String token;
  Future collabRequests;

  @override
  void initState() {
    super.initState();

    setToken();
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      token = prefValue.getString('token');
      collabRequests = getAllCollabRequests(token, widget.collabId);
      setState(() {});
    });
  }

  // Method to reject a collab request

  rejectCollabRequestMethod(collabId, colUsername) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      duration: Duration(days: 1),
      padding: EdgeInsets.only(
        top: 350,
        bottom: 150,
        left: 30,
        right: 30,
      ),
      content: Column(
        children: [
          SpinKitThreeBounce(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          )
        ],
      ),
    ));

    rejectCollabRequest(token, collabId, colUsername).then((data) {
      if (data['result'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(20),
            content: Text(
              "Collab request rejected",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      } else if (data['result'] == false) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            padding: EdgeInsets.all(20),
            content: Text(
              data['msg'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }
    });
  }

  // Method to accept a collab request

  acceptCollabRequestMethod(
      {collabId, colUsername, colAddress, colTitle, colAmount, campAddress}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      duration: Duration(days: 1),
      padding: EdgeInsets.only(
        top: 350,
        bottom: 150,
        left: 30,
        right: 30,
      ),
      content: Column(
        children: [
          SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text('This might take some time'),
          )
        ],
      ),
    ));

    acceptCollabRequest(
            token: token,
            campAddress: campAddress,
            collabId: collabId,
            colAddress: colAddress,
            colUsername: colUsername,
            collabAmount: colAmount,
            collabTitle: colTitle)
        .then((data) {
      if (data['result'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(20),
            content: Text(
              "Collab request accepted",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      } else if (data['result'] == false) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            padding: EdgeInsets.all(30),
            content: Text(
              data['msg'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBarGoBack(),
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height -
            AppBar().preferredSize.height -
            39,
        child: FutureBuilder(
            future: collabRequests,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.connectionState == ConnectionState.none) {
                return Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: Column(
                    children: [
                      SpinKitThreeBounce(
                        color: Theme.of(context).primaryColor,
                        size: 35.0,
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.data['result'] == false) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 60.0,
                      right: 60.0,
                      top: 0,
                    ),
                    child: Text(
                      'No collab requests found',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }
              if (snapshot.data['data'].length == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 60.0,
                      right: 60.0,
                      top: 0,
                    ),
                    child: Text(
                      'No collab requests found',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data['data'].length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.only(top: 12, left: 13, right: 13),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(230, 230, 230, 1),
                          borderRadius: BorderRadius.circular(15)),
                      height: 105,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                snapshot.data['data'][index]['username'],
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " - " + widget.collabTitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  acceptCollabRequestMethod(
                                      campAddress: widget.campAddress,
                                      collabId: widget.collabId,
                                      colTitle: widget.collabTitle,
                                      colAmount: widget.collabAmount,
                                      colAddress: snapshot.data['data'][index]
                                          ['address'],
                                      colUsername: snapshot.data['data'][index]
                                          ['username']);
                                },
                                child: Icon(Icons.done),
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    primary: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(60)),
                                    minimumSize: Size(140, 35)),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    rejectCollabRequestMethod(
                                        widget.collabId,
                                        snapshot.data['data'][index]
                                            ['username']);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      primary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(60)),
                                      minimumSize: Size(140, 35)))
                            ],
                          )
                        ],
                      ),
                    );
                  });
            }),
      ),
    );
  }
}

Future<dynamic> getAllCollabRequests(String token, String collabId) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'GET',
      Uri.parse(
          'http://3.135.1.141/api/getAllCollabRequestForACampJob/' + collabId));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}

Future<dynamic> rejectCollabRequest(
    String token, String collabId, String colUsername) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request('PUT',
      Uri.parse('http://3.135.1.141/api/rejectCollabRequestForACampJob'));
  request.body =
      json.encode({"collab_job_id": collabId, "col_req_username": colUsername});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}

Future<dynamic> acceptCollabRequest({
  String token,
  String collabId,
  String colUsername,
  String colAddress,
  String campAddress,
  String collabTitle,
  String collabAmount,
}) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'POST', Uri.parse('http://3.135.1.141/api/acceptUsersRequest'));
  request.body = json.encode({
    "collab_job_id": collabId,
    "camp_address": campAddress,
    "col_username": colUsername,
    "col_address": colAddress,
    "collab_title": collabTitle,
    "collab_amount": collabAmount
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
