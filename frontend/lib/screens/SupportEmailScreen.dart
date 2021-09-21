import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  final _fromKey = GlobalKey<FormState>();

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

  TextEditingController emailSubjectController = new TextEditingController();
  TextEditingController emailMessageController = new TextEditingController();

  final emailSubjectValidator =
      MultiValidator([RequiredValidator(errorText: 'Subject is required')]);

  final emailMessageValidator =
      MultiValidator([RequiredValidator(errorText: 'Description is required')]);

  void sendEmail() {
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

    supportEmail(
      token,
      emailSubjectController.text,
      emailMessageController.text,
    ).then(
      (data) {
        if (data['result'] == true) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(25),
              content: Text(
                "Ticket Raised, please wait for the response from our support team.",
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
              padding: EdgeInsets.all(18),
              content: Text(
                "There was a rasising a ticket",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBarGoBack(),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height -
            AppBar().preferredSize.height -
            39,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Call us at : ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      '(650) 555-2645',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width,
                height: 50,
                padding: EdgeInsets.only(left: 30, right: 30, top: 25),
              ),
              Container(
                padding: EdgeInsets.only(top: 25),
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: Image.asset(
                  'assets/images/SupportEmail.png',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    400 -
                    AppBar().preferredSize.height,
                child: Column(
                  children: [
                    Container(
                      height: 240,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                        left: 35,
                        right: 35,
                      ),
                      child: Form(
                        key: _fromKey,
                        child: ListView(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Subject',
                                labelStyle: TextStyle(fontSize: 16),
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
                                  borderSide: BorderSide(
                                      color: Colors.grey[300], width: 1),
                                ),
                              ),
                              controller: emailSubjectController,
                              validator: emailSubjectValidator,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 20,
                              ),
                              child: TextFormField(
                                maxLines: 4,
                                decoration: InputDecoration(
                                  labelText: 'Please describe your issue here',
                                  labelStyle: TextStyle(fontSize: 16),
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
                                    borderSide: BorderSide(
                                        color: Colors.grey[300], width: 1),
                                  ),
                                ),
                                controller: emailMessageController,
                                validator: emailMessageValidator,
                                keyboardType: TextInputType.text,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 35,
                        right: 35,
                        top: 10,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _fromKey.currentState.validate()
                              ? sendEmail()
                              : ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                  padding: EdgeInsets.all(20),
                                  content: Text(
                                    "Please enter valid details in the form above",
                                    textAlign: TextAlign.center,
                                  ),
                                ));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            'Raise your ticket',
                            style: TextStyle(fontSize: 19),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            minimumSize:
                                Size(MediaQuery.of(context).size.width, 50),
                            primary: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> supportEmail(
    String token, String emailSubject, String emailMessage) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Authorization': token,
    'Content-Type': 'application/json'
  };
  var request =
      http.Request('POST', Uri.parse('http://3.135.1.141/api/supportEmail'));
  request.body = json
      .encode({"email_subject": emailSubject, "email_message": emailMessage});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
