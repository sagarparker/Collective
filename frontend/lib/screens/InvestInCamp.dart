import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  Future balance;
  Map selectedCamp = {};
  String token;
  int accountBalance = 0;

  TextEditingController amountController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setToken().then((value) => balance = getUserBalance(token));
    super.initState();
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      setState(() {
        token = prefValue.getString('token');
      });
    });
  }

  static bool isFormValid = false;

  checkLength() {
    if (amountController.text.length == 0) {
      setState(() {
        isFormValid = false;
      });
    }
    if (amountController.text.length > 0) {
      setState(() {
        isFormValid = true;
      });
    }
  }

  void buyEquityMethod() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      duration: Duration(days: 1),
      padding: EdgeInsets.only(
        top: 180,
        left: 20,
        right: 20,
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: SpinKitFadingCube(
                color: Theme.of(context).primaryColor,
                size: 40.0,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 45,
                  right: 45,
                  bottom: 30,
                ),
                child: Text(
                  'Transaction in progress',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));

    buyEquity(token, selectedCamp['campAddress'],
            int.parse(amountController.text))
        .then(
      (data) {
        if (data['result'] == true) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 10),
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(30),
              content: Text(
                "Transaction in progress, this might take around 1-2 minutes ...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          );
        } else if (data['result'] == false) {
          print(data);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              padding: EdgeInsets.all(20),
              content: Text(
                "Investment failed",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    selectedCamp = ModalRoute.of(context).settings.arguments;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: AppBarGoBack(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 16, right: 16, top: 20),
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
                          width: MediaQuery.of(context).size.width - 32,
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
                          width: MediaQuery.of(context).size.width - 32,
                          height: 60,
                          child: FutureBuilder<dynamic>(
                            future: balance,
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: SpinKitThreeBounce(
                                    color: Theme.of(context).primaryColor,
                                    size: 20.0,
                                  ),
                                );
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.none) {
                                return Center(
                                  child: SpinKitThreeBounce(
                                    color: Theme.of(context).primaryColor,
                                    size: 20.0,
                                  ),
                                );
                              } else {
                                if (snapshot.data['result'] == false) {
                                  return Center(
                                      child: Text(
                                          'There was a problem fetching balance'));
                                } else {
                                  accountBalance = int.parse(snapshot
                                      .data['CTV_balance']
                                      .split(" ")[0]);
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          'CTV Balance : ',
                                          style: TextStyle(
                                            fontSize: 19,
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
                                              width: 25,
                                              height: 25,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                              top: 5,
                                            ),
                                            child: Text(
                                              snapshot.data['CTV_balance']
                                                  .replaceAllMapped(
                                                      new RegExp(
                                                          r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                                      (Match m) => '${m[1]},'),
                                              style: TextStyle(
                                                fontSize: 19,
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
                  top: 25,
                ),
                child: Image.asset(
                  'assets/images/InvestInCamp.png',
                  width: MediaQuery.of(context).size.width - 32,
                  height: 300,
                ),
              ),
              Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                ),
                child: Column(
                  children: [
                    Form(
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
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
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (int.parse(amountController.text) >
                                accountBalance) {
                              return ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: EdgeInsets.all(20),
                                  content: Text(
                                    "Insufficient balance in your wallet",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            if (int.parse(amountController.text) >
                                int.parse(selectedCamp['target'])) {
                              return ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: EdgeInsets.all(20),
                                  content: Text(
                                    "Amount cannot be greater than target",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            if (int.parse(amountController.text) == 0) {
                              return ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: EdgeInsets.all(20),
                                  content: Text(
                                    "Amount cannot be 0 CTV",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            if (int.parse(selectedCamp['target']) -
                                    int.parse(selectedCamp['raised']) <
                                int.parse(amountController.text)) {
                              return ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: EdgeInsets.all(20),
                                  content: Text(
                                    'Investment limit is upto ' +
                                        (int.parse(selectedCamp['target']) -
                                                int.parse(
                                                    selectedCamp['raised']))
                                            .toString() +
                                        ' CTV.',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                            buyEquityMethod();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 66,
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
                            ),
                          )
                        : Text(
                            'You can invest upto ' +
                                (int.parse(selectedCamp['target']) -
                                        int.parse(selectedCamp['raised']))
                                    .toString()
                                    .replaceAllMapped(
                                        new RegExp(
                                            r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => '${m[1]},') +
                                ' CTV.',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 15,
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
      'GET', Uri.parse('http://3.135.1.141/api/getUsersAccountBalance'));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}

Future<dynamic> buyEquity(String token, String address, int amount) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request =
      http.Request('POST', Uri.parse('http://3.135.1.141/api/buyEquity'));
  request.body = json.encode({"camp_address": address, "amount": amount});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
