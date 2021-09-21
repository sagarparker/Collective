import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CampCollaboratorsWidget extends StatefulWidget {
  final Map selectedCamp;

  CampCollaboratorsWidget(this.selectedCamp);
  @override
  _CampCollaboratorsWidgetState createState() =>
      _CampCollaboratorsWidgetState();
}

class _CampCollaboratorsWidgetState extends State<CampCollaboratorsWidget> {
  String token;
  String username;
  Future collabJobsList;

  @override
  void initState() {
    super.initState();

    setToken();
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      token = prefValue.getString('token');
      username = prefValue.getString('username');
      collabJobsList = getAllAcceptedCollabJobs(
          token, widget.selectedCamp['selectedCamp']['campAddress']);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: FutureBuilder(
          future: collabJobsList,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return Padding(
                padding: const EdgeInsets.only(top: 270),
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
                    'No collaborators found',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }
            if (snapshot.data['result'] == true &&
                snapshot.data['curatedCollabJobDetails'].length == 0) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 60.0,
                    right: 60.0,
                    top: 0,
                  ),
                  child: Text(
                    'No collaborators found',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            return ListView.builder(
                itemCount: snapshot.data['curatedCollabJobDetails'].length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 25, left: 16, right: 16),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color.fromRGBO(240, 240, 240, 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Username',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                snapshot.data['curatedCollabJobDetails'][index]
                                    ['username'],
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor))
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Email',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                snapshot.data['curatedCollabJobDetails'][index]
                                    ['email'],
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor))
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Role',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                snapshot.data['curatedCollabJobDetails'][index]
                                    ['position'],
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor))
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Budget',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                snapshot.data['curatedCollabJobDetails'][index]
                                    ['amount'],
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor))
                          ],
                        ),
                      ],
                    ),
                  );
                });
          }),
    );
  }
}

Future<dynamic> getAllAcceptedCollabJobs(
    String token, String campAddress) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'GET',
      Uri.parse(
          'http://3.135.1.141/api/getCollabAcceptedRequest/' + campAddress));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
