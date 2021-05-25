import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  static const routeName = '/loginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailUsernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  @override
  void dispose() {
    emailUsernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).primaryColor,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 80,
                padding: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/LogoCrop.png',
                      fit: BoxFit.cover,
                      height: 40,
                      width: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        'Collective',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                height: 290,
                child: Image.asset(
                  'assets/images/SignUpScreen.png',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: 250,
                padding: const EdgeInsets.only(top: 35, left: 40, right: 40),
                child: Form(
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email / Username',
                        ),
                        controller: emailUsernameController,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                        controller: passwordController,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25),
                        child: ElevatedButton(
                          onPressed: () {
                            userLogin(emailUsernameController.text,
                                    passwordController.text)
                                .then(
                              (data) async {
                                if (data['result'] == false) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      "Invalid credentials",
                                      textAlign: TextAlign.center,
                                    ),
                                  ));
                                } else {
                                  Navigator.of(context).pushReplacementNamed(
                                      HomeScreen.routeName);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      "Login successfull",
                                      textAlign: TextAlign.center,
                                    ),
                                  ));
                                }
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            primary: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60)),
                            minimumSize: Size(double.infinity, 45),
                          ),
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RegisterScreen.routeName);
                  },
                  child: Text(
                    'New User ? register here',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> userLogin(String emailusername, String password) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json'
  };
  var request =
      http.Request('POST', Uri.parse('http://3.15.217.59:8080/api/userLogin'));
  request.body =
      json.encode({"email_username": emailusername, "password": password});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return jsonDecode(await response.stream.bytesToString());
}
