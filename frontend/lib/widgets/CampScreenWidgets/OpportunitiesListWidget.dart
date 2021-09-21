import 'package:collective/screens/CollabRequestsScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpportunitiesListWidget extends StatefulWidget {
  final Map selectedCamp;

  OpportunitiesListWidget(this.selectedCamp);

  @override
  _OpportunitiesListWidgetState createState() =>
      _OpportunitiesListWidgetState();
}

class _OpportunitiesListWidgetState extends State<OpportunitiesListWidget> {
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
      collabJobsList = getAllCollabJobs(token, widget.selectedCamp['campId']);
      setState(() {});
    });
  }

  // Method to send a collab request

  sendCollabRequestMethod(collabId) {
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

    sendCollabRequest(token, collabId).then((data) {
      if (data['result'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(20),
            content: Text(
              "Collab request sent",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      } else if (data['result'] == false) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pop();
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
                  'No collab jobs found',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data['collabJobs'].length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16, right: 16),
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
                                padding: const EdgeInsets.only(top: 4, left: 8),
                                child: Text(
                                  snapshot.data['collabJobs'][index]
                                      ["collabTitle"],
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
                          color: Color.fromRGBO(240, 240, 240, 1),
                          height: 135,
                          padding: EdgeInsets.only(
                            top: 15,
                            left: 8,
                            right: 8,
                          ),
                          margin: EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          width: MediaQuery.of(context).size.width - 32,
                          child: ListView.builder(
                            itemCount: snapshot
                                .data['collabJobs'][index]['collabDescription']
                                .length,
                            itemBuilder: (context, position) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Text((position + 1).toString() +
                                    ") " +
                                    snapshot.data['collabJobs'][index]
                                        ['collabDescription'][position]),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          color: Color.fromRGBO(240, 240, 240, 1),
                          margin: const EdgeInsets.only(left: 16.0, right: 16),
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Divider(),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin:
                              EdgeInsets.only(left: 16, right: 16, bottom: 25),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15)),
                            color: Color.fromRGBO(240, 240, 240, 1),
                          ),
                          width: MediaQuery.of(context).size.width - 32,
                          height: 55,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Image.asset(
                                      'assets/images/Logo.png',
                                      width: 27,
                                      height: 27,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5, top: 4),
                                    child: Text(
                                      snapshot.data['collabJobs'][index]
                                              ['collabAmount']
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 21,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: snapshot.data['collabJobs'][index]
                                                  ['campOwnerUsername'] ==
                                              this.username
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  primary: Theme.of(context)
                                                      .primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              60)),
                                                  minimumSize: Size(100, 35)),
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CollabRequestsScreen(
                                                              collabId: snapshot
                                                                          .data[
                                                                      'collabJobs']
                                                                  [
                                                                  index]['_id'],
                                                              campAddress: widget
                                                                          .selectedCamp[
                                                                      'selectedCamp']
                                                                  [
                                                                  'campAddress'],
                                                              collabTitle: snapshot
                                                                          .data[
                                                                      'collabJobs'][index]
                                                                  [
                                                                  "collabTitle"],
                                                              collabAmount: snapshot
                                                                  .data[
                                                                      'collabJobs']
                                                                      [index][
                                                                      'collabAmount']
                                                                  .toString(),
                                                            )));
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Text(
                                                  'Collab Requests',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  primary: Theme.of(context)
                                                      .primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              60)),
                                                  minimumSize: Size(100, 35)),
                                              onPressed: () {
                                                sendCollabRequestMethod(
                                                    snapshot.data['collabJobs']
                                                        [index]['_id']);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Text(
                                                  'Collab',
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ))
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                );
              });
        },
      ),
    );
  }
}

Future<dynamic> getAllCollabJobs(String token, String campID) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request('GET',
      Uri.parse('http://3.135.1.141/api/getAllCollabJobForACamp/' + campID));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}

Future<dynamic> sendCollabRequest(String token, String collabId) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'POST', Uri.parse('http://3.135.1.141/api/sendRequestToCollab'));
  request.body = json.encode({"collab_job_id": collabId});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();
  return await jsonDecode(await response.stream.bytesToString());
}
