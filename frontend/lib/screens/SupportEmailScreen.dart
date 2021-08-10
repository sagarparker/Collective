import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SupportEmailScreen extends StatefulWidget {
  @override
  _SupportEmailScreenState createState() => _SupportEmailScreenState();

  static String routeName = '/supportEmailScreen';
}

class _SupportEmailScreenState extends State<SupportEmailScreen> {
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBarGoBack(),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Image.asset(
                'assets/images/SupportEmail.png',
                width: MediaQuery.of(context).size.width,
                height: 200,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 200,
                child: Column(
                  children: [],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> buyCTV(
    String token, String emailSubject, String emailMessage) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Authorization': token,
    'Content-Type': 'application/json'
  };
  var request =
      http.Request('POST', Uri.parse('http://18.217.26.234/api/supportEmail'));
  request.body = json
      .encode({"email_subject": emailSubject, "email_message": emailMessage});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
