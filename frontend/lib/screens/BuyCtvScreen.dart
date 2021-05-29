import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import 'package:pay/pay.dart';

class BuyCtvScreen extends StatefulWidget {
  static const routeName = '/buyCtvScreen';

  @override
  _BuyCtvScreenState createState() => _BuyCtvScreenState();
}

class _BuyCtvScreenState extends State<BuyCtvScreen> {
  TextEditingController amountController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // static const _paymentItems = [
  //   PaymentItem(
  //     label: 'CTV payment',
  //     amount: '99.99',
  //     status: PaymentItemStatus.final_price,
  //   )
  // ];

  final _paymentItems = <PaymentItem>[];

  void onGooglePayResult(paymentResult) {
    print(paymentResult);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 100),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              child: Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'CTV amount'),
                  controller: amountController,
                  validator: RequiredValidator(
                      errorText: 'Please provide a username or email'),
                ),
              ),
            ),
            Container(
              child: ElevatedButton(
                child: Text('Amount in INR'),
                onPressed: () {
                  _formKey.currentState.validate()
                      ? _paymentItems.add(PaymentItem(
                          amount: amountController.text,
                          label: 'CTV',
                          status: PaymentItemStatus.final_price,
                        ))
                      : print('F');
                },
              ),
            ),
            Container(
              child: GooglePayButton(
                paymentConfigurationAsset: 'gpay.json',
                paymentItems: _paymentItems,
                style: GooglePayButtonStyle.flat,
                width: 200,
                height: 50,
                type: GooglePayButtonType.pay,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: onGooglePayResult,
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
