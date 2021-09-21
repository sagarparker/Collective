import 'package:collective/widgets/CampScreenWidgets/CampsAngelListWidget.dart';
import 'package:collective/widgets/CampScreenWidgets/CollabWidget.dart';
import 'package:collective/widgets/CampScreenWidgets/MoreCampDataWidget.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:collective/widgets/CampScreenWidgets/InvestWidget.dart';
import 'package:collective/widgets/keepAlivePage.dart';
import 'package:flutter/material.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class CampScreen extends StatefulWidget {
  static String routeName = '/campScreen';

  @override
  _CampScreenState createState() => _CampScreenState();
}

class _CampScreenState extends State<CampScreen> with TickerProviderStateMixin {
  Map selectedCamp = {};
  String token;
  String username;
  Future campDetails;

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    setToken();
    _tabController = new TabController(length: 4, vsync: this);
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      token = prefValue.getString('token');
      username = prefValue.getString('username');
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.none) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 300.0),
                    child: Column(
                      children: [
                        SpinKitThreeBounce(
                          color: Theme.of(context).primaryColor,
                          size: 35.0,
                        ),
                      ],
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "- " + snapshot.data['details']['category'],
                                    style: TextStyle(
                                      fontSize: 15,
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
                                      snapshot.data['details']['fundingRaised']
                                              .replaceAllMapped(
                                                  new RegExp(
                                                      r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                                  (Match m) => '${m[1]},') +
                                          " CTV",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      snapshot.data['details']['target']
                                              .replaceAllMapped(
                                                  new RegExp(
                                                      r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                                  (Match m) => '${m[1]},') +
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
                                  percent: ((double.parse(
                                              snapshot.data['details']
                                                  ['fundingRaised']) *
                                          100 /
                                          double.parse(snapshot.data['details']
                                              ['target'])) /
                                      100),
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
                                      ((double.parse(snapshot.data['details']
                                                          ['fundingRaised']) *
                                                      100 /
                                                      double.parse(snapshot
                                                              .data['details']
                                                          ['target'])) /
                                                  1)
                                              .toStringAsFixed(2) +
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
                              Container(
                                height: 30,
                                margin: EdgeInsets.only(bottom: 10, top: 5),
                                width: MediaQuery.of(context).size.width - 40,
                                child: TabBar(
                                  indicatorColor:
                                      Theme.of(context).primaryColor,
                                  unselectedLabelColor: Colors.black38,
                                  labelColor: Theme.of(context).primaryColor,
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'Avenir',
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                    fontFamily: 'Avenir',
                                  ),
                                  tabs: [
                                    Tab(
                                      child: Text(
                                        "Invest",
                                      ),
                                    ),
                                    Tab(
                                      child: Text(
                                        "Collab",
                                      ),
                                    ),
                                    Tab(
                                      child: Text(
                                        "Angels",
                                      ),
                                    ),
                                    Tab(
                                      child: Text(
                                        "More",
                                      ),
                                    ),
                                  ],
                                  controller: _tabController,
                                ),
                              ),
                              Container(
                                height: 190,
                                width: MediaQuery.of(context).size.width - 40,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    InvestWidget(
                                        snapshot, username, selectedCamp),
                                    CollabWidget(
                                        snapshot,
                                        username,
                                        selectedCamp,
                                        snapshot.data['details']['_id']),
                                    KeepAlivePage(
                                        child: CampsAngelListWidget(
                                      selectedCamp,
                                      snapshot.data['details']['target'],
                                      snapshot.data['details']['equity'],
                                    )),
                                    MoreCampDataWidget(snapshot),
                                  ],
                                ),
                              ),
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

// Get camps

Future<dynamic> getCamps(String token, String campAddress) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'POST', Uri.parse('http://3.135.1.141/api/getCampMasterDetails'));
  request.body = json.encode({"camp_address": campAddress});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
