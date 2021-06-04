import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';

import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InvestInCamp extends StatefulWidget {
  static String routeName = 'investInCamp';

  @override
  _InvestInCampState createState() => _InvestInCampState();
}

class _InvestInCampState extends State<InvestInCamp> {
  Map selectedCamp = {};
  String token;

  TextEditingController amountController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

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

  static bool isFormValid = false;

  checkLength() {
    if (amountController.text.length == 0) {
      isFormValid = false;
    }
    if (amountController.text.length > 0) {
      isFormValid = true;
    }
    setState(() {});
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
              Container(
                margin: EdgeInsets.only(left: 32, right: 32, top: 20),
                height: 100,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(245, 245, 245, 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            color: Theme.of(context).primaryColor,
                          ),
                          width: MediaQuery.of(context).size.width - 64,
                          height: 40,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 7),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 3),
                                child: Text(
                                  "Wallet",
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
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15))),
                          width: MediaQuery.of(context).size.width - 64,
                          height: 60,
                          child: FutureBuilder<dynamic>(
                            future: getUserBalance(token),
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: Text('Fetching balance ....'));
                              } else {
                                if (snapshot.data['result'] == false) {
                                  return Center(
                                      child: Text(
                                          'There was a problem fetching balance'));
                                } else {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          'Current balance : ',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 3),
                                            child: Image.asset(
                                              'assets/images/Logo.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                              top: 5,
                                            ),
                                            child: Text(
                                              snapshot.data['CTV_balance'],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: 15,
                ),
                child: Image.asset(
                  'assets/images/InvestInCamp.png',
                  width: MediaQuery.of(context).size.width - 32,
                  height: 300,
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: 15,
                ),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'CTV amount'),
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    onChanged: checkLength(),
                    validator: RequiredValidator(
                        errorText: 'Please enter a valid CTV amount'),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 20,
                  left: 30,
                  right: 30,
                ),
                child: ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3,
                          bottom: 0,
                        ),
                        child: Text(
                          'Invest in ' + selectedCamp['campName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      minimumSize: Size(100, 45)),
                  onPressed: () {},
                ),
              ),
              Container(
                height: 82,
                margin: EdgeInsets.only(
                  top: 20,
                ),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: Color.fromRGBO(245, 245, 245, 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isFormValid
                        ? Text(
                            'You will own ' +
                                (int.parse(amountController.text) *
                                        100 /
                                        (int.parse(selectedCamp['target']) *
                                            100 /
                                            int.parse(selectedCamp['equity'])))
                                    .toStringAsFixed(2) +
                                "% of " +
                                selectedCamp['campName'],
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                              left: 80,
                              right: 80,
                            ),
                            child: Text(
                              'Please enter the amount you want to invest above',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> getUserBalance(String token) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'GET', Uri.parse('http://3.15.217.59:8080/api/getUsersAccountBalance'));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
