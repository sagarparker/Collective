import 'dart:ui';

import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/loginScreen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailUsernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailUsernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 90,
                padding: EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/LogoNoPadding.png',
                      height: 32,
                      width: 32,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 3, top: 5),
                      child: Text(
                        'Collective',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 300,
                padding: const EdgeInsets.only(
                  top: 35,
                  left: 35,
                  right: 35,
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Container(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email / Username',
                            filled: true,
                            fillColor: Colors.grey[50],
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.grey[300], width: 1),
                            ),
                          ),
                          controller: emailUsernameController,
                          validator: RequiredValidator(
                              errorText: 'Please provide a username or email'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.grey[50],
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.grey[300], width: 1),
                            ),
                          ),
                          obscureText: true,
                          controller: passwordController,
                          validator: RequiredValidator(
                              errorText: 'Please provide a password'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 25),
                        child: ElevatedButton(
                          onPressed: () {
                            _formKey.currentState.validate()
                                ? userLogin(emailUsernameController.text,
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
                                      } else if (data['result'] == true) {
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setString('email', data['email']);
                                        prefs.setString(
                                            'username', data['username']);
                                        prefs.setString('id', data['id']);
                                        prefs.setString('token', data['token']);
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                                HomeScreen.routeName);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          content: Text(
                                            "Welcome to Collective",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ));
                                      }
                                    },
                                  )
                                : print('Invalid credentials in from field');
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            primary: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60)),
                            minimumSize: Size(double.infinity, 52),
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
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(RegisterScreen.routeName);
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
              Container(
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                height: 270,
                child: Image.asset(
                  'assets/images/LoginScreen.png',
                  fit: BoxFit.cover,
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
      http.Request('POST', Uri.parse('http://3.135.1.141/api/userLogin'));
  request.body =
      json.encode({"email_username": emailusername, "password": password});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return jsonDecode(await response.stream.bytesToString());
}
