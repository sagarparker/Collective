import 'package:collective/screens/InvestInCamp.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CampScreen extends StatefulWidget {
  static String routeName = '/campScreen';

  @override
  _CampScreenState createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> {
  Map selectedCamp = {};
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
          child: FutureBuilder<dynamic>(
              future: getCamps(
                token,
                selectedCamp['campAddress'],
              ),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 60.0,
                        right: 60.0,
                        top: 320,
                      ),
                      child: Text(
                        'Fetching camp details ...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }
                if (snapshot.data['result'] == false) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 60.0,
                        right: 60.0,
                        top: 310,
                      ),
                      child: Text(
                        'There was a problem fetching camp details, please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 95,
                  child: Stack(
                    children: [
                      Positioned(
                        height: 250,
                        child: ProgressiveImage(
                          placeholder:
                              AssetImage('assets/images/placeholder.jpg'),
                          thumbnail:
                              AssetImage('assets/images/placeholder.jpg'),
                          image: NetworkImage(
                            snapshot.data['details']['camp_image'],
                          ),
                          fit: BoxFit.cover,
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Positioned(
                        top: 230,
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    snapshot.data['details']['name'],
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "- " + snapshot.data['details']['category'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                              Divider(
                                color: Colors.grey,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 30,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      snapshot.data['details']
                                              ['fundingRaised'] +
                                          " CTV",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data['details']['target'] +
                                          " CTV",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                ),
                                child: LinearPercentIndicator(
                                  width: MediaQuery.of(context).size.width - 40,
                                  animation: true,
                                  lineHeight: 18.0,
                                  animationDuration: 1000,
                                  percent: 0.7,
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  progressColor: Theme.of(context).primaryColor,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      (int.parse(snapshot.data['details']
                                                      ['fundingRaised']) *
                                                  100 /
                                                  int.parse(
                                                      snapshot.data['details']
                                                          ['target']))
                                              .toString() +
                                          " %",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "Equity : " +
                                          snapshot.data['details']['equity'] +
                                          " %",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.grey,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Description",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width - 40,
                                height: 60,
                                child: Text(
                                  snapshot.data["details"]["camp_description"],
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
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero),
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
                                        'Invest in ' +
                                            snapshot.data['details']['name'],
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
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                      InvestInCamp.routeName,
                                      arguments: {
                                        'campAddress':
                                            selectedCamp['campAddress'],
                                        'campName': snapshot.data['details']
                                            ['name'],
                                        'target': snapshot.data['details']
                                            ['target'],
                                        'equity': snapshot.data['details']
                                            ['equity']
                                      });
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}

Future<dynamic> getCamps(String token, String campAddress) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'POST', Uri.parse('http://3.15.217.59:8080/api/getCampMasterDetails'));
  request.body = json.encode({"camp_address": campAddress});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
