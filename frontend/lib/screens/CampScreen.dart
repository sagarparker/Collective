import 'package:collective/screens/InvestInCamp.dart';
import 'package:collective/widgets/appBarGoBack.dart';
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

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    setToken();
    _tabController = new TabController(length: 3, vsync: this);
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
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                                        "Description",
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
                                    Column(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          height: 65,
                                          child: Text(
                                            snapshot.data["details"]
                                                ["camp_description"],
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 17),
                                              child: TextButton(
                                                onPressed: () {},
                                                style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero),
                                                child: Text(
                                                  'Read more',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        snapshot.data['details']
                                                ['targetReachedDB']
                                            ? snapshot.data['details']
                                                        ['owner'] ==
                                                    username
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .emoji_events_rounded,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            size: 18,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 3,
                                                                    top: 2),
                                                            child: Text(
                                                              'Funding raised!',
                                                              style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      ElevatedButton(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                top: 3,
                                                                bottom: 0,
                                                              ),
                                                              child: Text(
                                                                'Withdraw amount',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          elevation: 0,
                                                          primary:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                          ),
                                                          minimumSize:
                                                              Size(100, 45),
                                                        ),
                                                        onPressed: () {},
                                                      ),
                                                    ],
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .emoji_events_rounded,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            size: 28,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 3,
                                                                    top: 5),
                                                            child: Text(
                                                              'Funding raised!',
                                                              style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fontSize: 25,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  )
                                            : ElevatedButton(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 3,
                                                        bottom: 0,
                                                      ),
                                                      child: Text(
                                                        'Invest in ' +
                                                            snapshot.data[
                                                                    'details']
                                                                ['name'],
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  primary: Theme.of(context)
                                                      .primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  minimumSize: Size(100, 45),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          InvestInCamp
                                                              .routeName,
                                                          arguments: {
                                                        'campAddress':
                                                            selectedCamp[
                                                                'campAddress'],
                                                        'campName': snapshot
                                                                .data['details']
                                                            ['name'],
                                                        'target': snapshot
                                                                .data['details']
                                                            ['target'],
                                                        'equity': snapshot
                                                                .data['details']
                                                            ['equity'],
                                                        'raised': snapshot
                                                                .data['details']
                                                            ['fundingRaised']
                                                      });
                                                },
                                              ),
                                      ],
                                    ),
                                    Container(
                                      child: FutureBuilder<dynamic>(
                                        future: getCampsAngels(
                                          selectedCamp['campAddress'],
                                        ),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<dynamic> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 50.0),
                                              child: Column(
                                                children: [
                                                  SpinKitThreeBounce(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    size: 25.0,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          if (snapshot.connectionState ==
                                              ConnectionState.none) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 50.0),
                                              child: Column(
                                                children: [
                                                  SpinKitThreeBounce(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    size: 25.0,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          if (snapshot.data['result'] ==
                                              false) {
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
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            );
                                          }

                                          return ListView.builder(
                                            itemCount:
                                                snapshot.data['list'].length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                  top: 5,
                                                  bottom: 10,
                                                ),
                                                padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color: Color.fromRGBO(
                                                      245, 245, 245, 1),
                                                ),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    40,
                                                height: 53,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2.0),
                                                      child: Text(
                                                        snapshot.data['list']
                                                            [index]['username'],
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        getAngelsFunding(
                                                                selectedCamp[
                                                                    'campAddress'],
                                                                snapshot.data[
                                                                            'list']
                                                                        [index][
                                                                    'eth_address'])
                                                            .then(
                                                          (data) {
                                                            if (data[
                                                                    'result'] ==
                                                                true) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .hideCurrentSnackBar();

                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  elevation:
                                                                      20.0,
                                                                  backgroundColor:
                                                                      Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              35),
                                                                  content: Text(
                                                                    'Investment : ' +
                                                                        data[
                                                                            'details'] +
                                                                        ' CTV',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              );
                                                            } else if (data[
                                                                    'result'] ==
                                                                false) {
                                                              print(data);
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .hideCurrentSnackBar();

                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              20),
                                                                  content: Text(
                                                                    "Please try again later",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 2.0),
                                                        child: Text(
                                                            'Check investment'),
                                                      ),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 0,
                                                        primary:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            25,
                                                          ),
                                                        ),
                                                        minimumSize:
                                                            Size(100, 70),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    SingleChildScrollView(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                40,
                                        height: 190,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 44,
                                              margin: EdgeInsets.only(
                                                top: 5,
                                                bottom: 10,
                                              ),
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                color: Color.fromRGBO(
                                                    245, 245, 245, 1),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    snapshot.data["details"]
                                                        ["owner"],
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '- Camp Owner',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 44,
                                              margin: EdgeInsets.only(
                                                top: 5,
                                                bottom: 10,
                                              ),
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                color: Color.fromRGBO(
                                                    245, 245, 245, 1),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    snapshot.data["details"]
                                                        ["createdOn"],
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    '- Created On ',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              margin: EdgeInsets.only(
                                                top: 5,
                                                bottom: 10,
                                              ),
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                color: Color.fromRGBO(
                                                    245, 245, 245, 1),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2.0),
                                                    child: Text(
                                                      ((int.parse(snapshot.data[
                                                                              "details"]
                                                                          [
                                                                          "target"]) *
                                                                      100) /
                                                                  int.parse(snapshot
                                                                              .data[
                                                                          "details"]
                                                                      [
                                                                      "equity"]))
                                                              .toStringAsFixed(
                                                                  0) +
                                                          " CTV",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Text(
                                                    '- Valuation',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black54,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
      'POST', Uri.parse('http://3.15.217.59:8080/api/getCampMasterDetails'));
  request.body = json.encode({"camp_address": campAddress});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}

// Get all the investors of a camp

Future<dynamic> getCampsAngels(String campAddress) async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'POST', Uri.parse('http://3.15.217.59:8080/api/getCampsAngelInvestors'));
  request.body = json.encode({"camp_address": campAddress});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}

// Get investment done by a particular angel

Future<dynamic> getAngelsFunding(
    String campAddress, String angelAddress) async {
  var headers = {'Content-Type': 'application/json'};
  var request = http.Request(
      'POST', Uri.parse('http://3.15.217.59:8080/api/getFundingDetails'));
  request.body =
      json.encode({"camp_address": campAddress, "angel_address": angelAddress});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
