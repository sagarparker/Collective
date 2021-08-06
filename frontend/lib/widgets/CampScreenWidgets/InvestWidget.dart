import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/screens/InvestInCamp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InvestWidget extends StatefulWidget {
  final AsyncSnapshot snapshot;
  final String username;
  final Map selectedCamp;

  InvestWidget(this.snapshot, this.username, this.selectedCamp);

  @override
  _InvestWidgetState createState() => _InvestWidgetState();
}

class _InvestWidgetState extends State<InvestWidget> {
  String token;

  @override
  void initState() {
    setToken();
    super.initState();
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      setState(() {
        token = prefValue.getString('token');
      });
    });
  }

  void withDrawAmountMethod() {
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
            Image.asset(
              'assets/images/loading.png',
              width: 300,
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 45,
                  right: 45,
                  bottom: 30,
                ),
                child: Text(
                  'Transaction in progress, this might take some time ...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SpinKitFadingCube(
              color: Theme.of(context).primaryColor,
              size: 30.0,
            )
          ],
        ),
      ),
    ));

    withDrawAmount(
            token,
            widget.snapshot.data['details']['address'],
            widget.snapshot.data['details']['privatekey'],
            int.parse(widget.snapshot.data['details']['target']))
        .then(
      (data) {
        if (data['result'] == true) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(20),
              content: Text(
                "CTV transferred to your account",
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
                "Transfer failed",
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
    print(widget.snapshot);
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 40,
          height: 65,
          child: Text(
            widget.snapshot.data["details"]["camp_description"],
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 17),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  'Read more',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
        widget.snapshot.data['details']['targetReachedDB']
            ? widget.snapshot.data['details']['owner'] == widget.username
                ? widget.snapshot.data['details']['amountWithdrawn']
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3, top: 5),
                            child: Text(
                              'Funding withdrawn!',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 18,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 3, top: 2),
                                child: Text(
                                  'Funding raised!',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            ],
                          ),
                          ElevatedButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 3,
                                    bottom: 0,
                                  ),
                                  child: Text(
                                    'Withdraw amount',
                                    style: TextStyle(
                                      fontSize: 15,
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
                              minimumSize: Size(100, 45),
                            ),
                            onPressed: () {
                              withDrawAmountMethod();
                            },
                          ),
                        ],
                      )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3, top: 5),
                            child: Text(
                              'Funding raised!',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
            : ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 3,
                        bottom: 0,
                      ),
                      child: Text(
                        'Invest in ' + widget.snapshot.data['details']['name'],
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
                  minimumSize: Size(100, 45),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(InvestInCamp.routeName, arguments: {
                    'campAddress': widget.selectedCamp['campAddress'],
                    'campName': widget.snapshot.data['details']['name'],
                    'target': widget.snapshot.data['details']['target'],
                    'equity': widget.snapshot.data['details']['equity'],
                    'raised': widget.snapshot.data['details']['fundingRaised']
                  });
                },
              ),
      ],
    );
  }
}

Future<dynamic> withDrawAmount(
    String token, String campAddress, String campPrivateKey, int amount) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };

  var request = http.Request(
      'POST', Uri.parse('http://18.217.26.234/api/withdrawAmount'));
  request.body = json.encode({
    "owner_address": campAddress,
    "owner_private_key": campPrivateKey,
    "amount": amount
  });

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
