import 'package:collective/widgets/CampListViewWidget.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserInvestmentScreen extends StatefulWidget {
  @override
  _UserInvestmentScreenState createState() => _UserInvestmentScreenState();

  static String routeName = "/UserInvestmentScreen";
}

class _UserInvestmentScreenState extends State<UserInvestmentScreen> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBarGoBack(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 17, top: 25, bottom: 5),
                  child: Text(
                    "Your camp investments",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.only(
                          left: 0,
                          top: 15,
                        ),
                        minimumSize: Size(0, 0)),
                    child: Icon(
                      Icons.restart_alt,
                      color: Theme.of(context).primaryColor,
                      size: 22,
                    ),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              padding: EdgeInsets.only(left: 10, right: 10, top: 5),
              child: FutureBuilder<dynamic>(
                  future: getCampsInvestedByUser(token),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                      }
                      if (snapshot.data['details'].length == 0) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 150,
                            ),
                            child: Text('No investments found'),
                          ),
                        );
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

Future<dynamic> getCampsInvestedByUser(String token) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };

  var request = http.Request(
      'GET', Uri.parse('http://3.135.1.141/api/getCampsInvestedByUser'));

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
