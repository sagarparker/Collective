import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CampScreen extends StatefulWidget {
  static String routeName = '/campScreen';

  @override
  _CampScreenState createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  Map selectedCamp = {};
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
    selectedCamp = ModalRoute.of(context).settings.arguments;

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: AppBarGoBack(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                selectedCamp['campAddress'],
              ),
              ElevatedButton(
                onPressed: () {
                  getCamps(
                    token,
                    selectedCamp['campAddress'],
                  ).then(
                    (value) => print(value),
                  );
                },
                child: Text('Get camp details'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> getCamps(String token, String campAddress) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'POST', Uri.parse('http://3.15.217.59:8080/api/getCampMasterDetails'));
  request.body = json.encode({"camp_address": campAddress});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
