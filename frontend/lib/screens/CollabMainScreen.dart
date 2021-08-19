import 'package:collective/screens/CreateCampCollabJobScreen.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CollabMainScreen extends StatefulWidget {
  static String routeName = '/collabMainScreen';

  @override
  _CollabMainScreenState createState() => _CollabMainScreenState();
}

class _CollabMainScreenState extends State<CollabMainScreen>
    with TickerProviderStateMixin {
  Map selectedCamp = {};
  String token;
  String username;
  TabController _tabController;
  Future collabJobsList;

  @override
  void initState() {
    super.initState();
    setToken();
    _tabController = new TabController(length: 2, vsync: this);
  }

  Future setToken() async {
    SharedPreferences.getInstance().then((prefValue) {
      token = prefValue.getString('token');
      username = prefValue.getString('username');
      collabJobsList = getAllCollabJobs(token, selectedCamp['campId']);
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBarGoBack(),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Container(
              height: 50,
              child: TabBar(
                labelPadding: EdgeInsets.only(top: 5),
                indicatorPadding: EdgeInsets.only(left: 15, right: 15),
                indicatorColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black38,
                labelColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Avenir',
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                  fontFamily: 'Avenir',
                ),
                tabs: [
                  Tab(
                    child: Text(
                      "Opportunities",
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Collaborators",
                    ),
                  ),
                ],
                controller: _tabController,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 22),
            color: Colors.white,
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                88,
            width: MediaQuery.of(context).size.width,
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder(
                    future: collabJobsList,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 0),
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
                              top: 0,
                            ),
                            child: Text(
                              'No collab jobs found',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                          itemCount: snapshot.data['collabJobs'].length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 16, right: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15)),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      width: MediaQuery.of(context).size.width -
                                          32,
                                      height: 40,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, left: 8),
                                            child: Text(
                                              snapshot.data['collabJobs'][index]
                                                  ["collabTitle"],
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
                                      color: Color.fromRGBO(247, 247, 247, 1),
                                      height: 135,
                                      padding: EdgeInsets.only(
                                        top: 15,
                                        left: 8,
                                        right: 8,
                                      ),
                                      margin: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                      ),
                                      width: MediaQuery.of(context).size.width -
                                          32,
                                      child: ListView.builder(
                                        itemCount: snapshot
                                            .data['collabJobs'][index]
                                                ['collabDescription']
                                            .length,
                                        itemBuilder: (context, position) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15.0),
                                            child: Text((position + 1)
                                                    .toString() +
                                                ") " +
                                                snapshot.data['collabJobs']
                                                            [index]
                                                        ['collabDescription']
                                                    [position]),
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      color: Color.fromRGBO(247, 247, 247, 1),
                                      margin: const EdgeInsets.only(
                                          left: 16.0, right: 16),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Divider(),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 16, right: 16, bottom: 25),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15)),
                                        color: Color.fromRGBO(247, 247, 247, 1),
                                      ),
                                      width: MediaQuery.of(context).size.width -
                                          32,
                                      height: 55,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8),
                                                child: Image.asset(
                                                  'assets/images/Logo.png',
                                                  width: 27,
                                                  height: 27,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 5, top: 4),
                                                child: Text(
                                                  snapshot.data['collabJobs']
                                                          [index]
                                                          ['collabAmount']
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 21,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: snapshot.data[
                                                                      'collabJobs']
                                                                  [index][
                                                              'campOwnerUsername'] ==
                                                          this.username
                                                      ? ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              elevation: 0,
                                                              primary: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              60)),
                                                              minimumSize: Size(
                                                                  100, 35)),
                                                          onPressed: () {},
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 2),
                                                            child: Text(
                                                              'Collab Requests',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              elevation: 0,
                                                              primary: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              60)),
                                                              minimumSize: Size(
                                                                  100, 35)),
                                                          onPressed: () {},
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 2),
                                                            child: Text(
                                                              'Collab',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                          });
                    },
                  ),
                ),
                Container()
              ],
            ),
          )
        ],
      ),
      floatingActionButton: selectedCamp['campOwner'] == this.username
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(CreateCampCollabJobScreen.routeName, arguments: {
                  "campId": selectedCamp['campId'],
                  "campOwner": selectedCamp['campOwner']
                });
              },
              elevation: 4,
              child: const Icon(
                Icons.add,
                color: Color.fromRGBO(24, 119, 242, 1.0),
              ),
              backgroundColor: Color.fromRGBO(240, 240, 240, 1),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}

Future<dynamic> getAllCollabJobs(String token, String campID) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request('GET',
      Uri.parse('http://18.217.26.234/api/getAllCollabJobForACamp/' + campID));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
