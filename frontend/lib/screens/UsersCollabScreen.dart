import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UsersCollabScreen extends StatefulWidget {
  static String routeName = '/userCollabScreen';

  @override
  _UsersCollabScreenState createState() => _UsersCollabScreenState();
}

class _UsersCollabScreenState extends State<UsersCollabScreen> {
  String token;
  String username;
  Future collabsList;

  @override
  void initState() {
    super.initState();

    setToken();
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      token = prefValue.getString('token');
      username = prefValue.getString('username');
      collabsList = getUsersCollaboration(token);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: AppBarGoBack(),
        ),
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              35,
          child: FutureBuilder(
            future: collabsList,
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
                      'No collaborations found',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }
              if (snapshot.data['result'] == true &&
                  snapshot.data['details'].length == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 60.0,
                      right: 60.0,
                      top: 0,
                    ),
                    child: Text(
                      'No collaborations found',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data['details'].length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 25),
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
                              Text('Role',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                  snapshot.data['details'][index]
                                      ['collabTitle'],
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor))
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Budget',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                  snapshot.data['details'][index]
                                              ['collabAmount']
                                          .toString() +
                                      " CTV",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor))
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            },
          ),
        ),
      ),
    );
  }
}

Future<dynamic> getUsersCollaboration(String token) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request =
      http.Request('GET', Uri.parse('http://3.135.1.141/api/getUsersCollabs'));

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
