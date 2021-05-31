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
      backgroundColor: Colors.white,
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height / 3.1,
          bottom: MediaQuery.of(context).size.height / 3.1,
          left: 20,
          right: 20),
      content: Text(
        "Transaction in progress ...",
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).primaryColor,
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
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                margin:
                    EdgeInsets.only(left: 35, right: 35, top: 25, bottom: 10),
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
                          width: MediaQuery.of(context).size.width - 70,
                          height: 40,
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 7),
                                child: Icon(
                                  Icons.shop,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 5),
                                child: Text(
                                  "Collective store",
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
                          width: MediaQuery.of(context).size.width - 70,
                          height: 60,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  '1 Collective token ( CTV ) = 1 INR ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 270,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(
                  top: 10,
                ),
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  'assets/images/pay.png',
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                height: 100,
                padding: EdgeInsets.only(top: 10, right: 35, left: 35),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/LogoNoPadding.png',
                        width: 40,
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'BUY CTV',
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
              isFormValid
                  ? Container(
                      height: 100,
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
                  : Container(
                      height: 100,
                      padding:
                          const EdgeInsets.only(top: 40, left: 65, right: 65),
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
