import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Color.fromRGBO(240, 240, 240, 1),
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    });
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
      padding: EdgeInsets.only(top: 290, left: 20, right: 20),
      content: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Column(
          children: [
            SpinKitFadingCube(
              color: Theme.of(context).primaryColor,
              size: 30.0,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 40,
                ),
                child: Text(
                  'Transaction in progress',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));

    buyCTV(token, int.parse(amountController.text)).then((data) {
      if (data['result'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(20),
            content: Text(
              "CTV added to your wallet",
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBarGoBack(),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              39,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 35, right: 35, bottom: 10),
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
                height: 42,
                width: MediaQuery.of(context).size.width - 70,
                child: ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/LogoNoPadding.png',
                        width: 30,
                        height: 30,
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
                      height: 70,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
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
                            margin: const EdgeInsets.only(top: 30.0),
                            onPaymentResult: onGooglePayResult,
                            loadingIndicator: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: 70,
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
      'POST', Uri.parse('http://3.135.1.141/api/transferCTVToUser'));
  request.body = json.encode({"amount": amount});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
