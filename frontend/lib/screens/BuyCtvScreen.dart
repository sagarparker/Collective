import 'package:collective/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'package:pay/pay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BuyCtvScreen extends StatefulWidget {
  static const routeName = '/buyCtvScreen';

  @override
  _BuyCtvScreenState createState() => _BuyCtvScreenState();
}

class _BuyCtvScreenState extends State<BuyCtvScreen> {
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

  TextEditingController amountController = new TextEditingController();

  static bool isFormValid = false;

  final _formKey = GlobalKey<FormState>();

  checkLength() {
    if (amountController.text.length == 0) {
      isFormValid = false;
    }
  }

  void addToPayment() {
    _paymentItems.add(PaymentItem(
      amount: amountController.text,
      label: 'CTV',
      status: PaymentItemStatus.final_price,
    ));
    isFormValid = true;
    setState(() {});
  }

  void hidePaymentBox() {
    isFormValid = false;
    setState(() {});
  }

  final _paymentItems = <PaymentItem>[];

  void onGooglePayResult(paymentResult) {
    print(paymentResult);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(days: 1),
      padding: EdgeInsets.all(20),
      content: Text(
        "Transaction in progress ...",
        style: TextStyle(
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    ));
    buyCTV(token, int.parse(amountController.text)).then((data) {
      if (data['result'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          padding: EdgeInsets.all(20),
          content: Text(
            "CTV added to your wallet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ));
      } else if (data['result'] == false) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          padding: EdgeInsets.all(20),
          content: Text(
            "There was a problem buying CTV",
            textAlign: TextAlign.center,
          ),
        ));
      }
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.navigate_before),
          color: Colors.black,
          iconSize: 25,
          onPressed: () {
            Navigator.of(context).pop(BuyCtvScreen.routeName);
          },
        ),
        elevation: 2,
        centerTitle: true,
        title: Container(
          width: 150,
          child: Row(
            children: [
              Image.asset(
                'assets/images/Logo.png',
                width: 32,
                height: 32,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Collective',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                // height: 165,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Image.asset(
                        'assets/images/LogoNoPadding.png',
                        height: 100,
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5, right: 20),
                          child: Text(
                            '1CTV',
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 58.0),
                          child: Text(
                            '1 INR',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                height: 90,
                padding: EdgeInsets.only(right: 35, left: 35),
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
                height: 45,
                width: MediaQuery.of(context).size.width - 70,
                child: ElevatedButton(
                  // child: Text('Buy CTV'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/LogoCrop.png',
                        width: 30,
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 3),
                        child: Text(
                          'Buy CTV',
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
                  ),
                  onPressed: () {
                    _formKey.currentState.validate()
                        ? addToPayment()
                        : hidePaymentBox();
                  },
                ),
              ),
              Container(
                height: 270,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/images/payment.png',
                  fit: BoxFit.contain,
                ),
              ),
              isFormValid
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                              amountController.text + ' INR',
                              style: TextStyle(
                                fontSize: 22,
                                // color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          GooglePayButton(
                            paymentConfigurationAsset: 'gpay.json',
                            paymentItems: _paymentItems,
                            style: GooglePayButtonStyle.flat,
                            width: 145,
                            height: 50,
                            type: GooglePayButtonType.pay,
                            margin: const EdgeInsets.only(top: 15.0),
                            onPaymentResult: onGooglePayResult,
                            loadingIndicator: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 50, right: 50),
                      child: Text(
                        'Please enter the amount of CTV you want to buy above.',
                        textAlign: TextAlign.center,
                      ),
                    ),
            ],
          ),
        ),
      ),
    ));
  }
}

Future<dynamic> buyCTV(String token, int amount) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Authorization': token,
    'Content-Type': 'application/json'
  };
  var request = http.Request(
      'POST', Uri.parse('http://3.15.217.59:8080/api/transferCTVToUser'));
  request.body = json.encode({"amount": amount});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
