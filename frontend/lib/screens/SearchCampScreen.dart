import 'package:collective/screens/CampScreen.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchCampScreen extends StatefulWidget {
  @override
  _SearchCampScreenState createState() => _SearchCampScreenState();
}

class _SearchCampScreenState extends State<SearchCampScreen> {
  String token;
  bool formSubmited = false;
  Future campList;

  final _formKey = GlobalKey<FormState>();

  TextEditingController searchBarController = new TextEditingController();

  final searchBarValidator = MultiValidator([
    RequiredValidator(errorText: 'Camp name is required'),
  ]);

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
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  searchForCampMethod(campName) {
    if (_formKey.currentState.validate()) {
      setState(() {
        formSubmited = true;
      });
    }

    campList = searchCamp(token, campName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 90,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 25),
              height: 50,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 230,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Search for camps',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        controller: searchBarController,
                        validator: searchBarValidator,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          _formKey.currentState.validate()
                              ? searchForCampMethod(searchBarController.text)
                              : ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                  padding: EdgeInsets.all(20),
                                  content: Text(
                                    "Please enter valid camp name",
                                    textAlign: TextAlign.center,
                                  ),
                                ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Icon(
                                Icons.search,
                              ),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(80, 50),
                          elevation: 0,
                          primary: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            formSubmited
                ? FutureBuilder(
                    future: campList,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 250),
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
                              top: 270,
                            ),
                            child: Text(
                              'No camp found',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }

                      return Container(
                        height: MediaQuery.of(context).size.height - 197,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(20),
                        child: ListView.builder(
                            itemCount: snapshot.data['camps'].length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(
                                  top: 10,
                                ),
                                height: 200,
                                width: 200,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(242, 242, 242, 1),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                          )),
                                      height: 50,
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            snapshot.data['camps'][index]
                                                ['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                              ' - ' +
                                                  snapshot.data['camps'][index]
                                                      ['category'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .primaryColor))
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(242, 242, 242, 1),
                                      ),
                                      height: 60,
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      child: Text(
                                        snapshot.data['camps'][index]
                                            ['camp_description'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Color.fromRGBO(242, 242, 242, 1),
                                      padding:
                                          EdgeInsets.only(left: 10, right: 10),
                                      height: 10,
                                      child: Divider(),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color:
                                              Color.fromRGBO(240, 240, 240, 1),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          )),
                                      height: 70,
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      padding: EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 10,
                                          bottom: 15),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          primary:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(60),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              CampScreen.routeName,
                                              arguments: {
                                                'campAddress':
                                                    snapshot.data['camps']
                                                        [index]['address']
                                              });
                                        },
                                        child: Text(
                                          'Checkout ' +
                                              snapshot.data['camps'][index]
                                                  ['name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                      );
                    },
                  )
                : Container(
                    height: 500,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                      top: 90,
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/search.png',
                          fit: BoxFit.cover,
                          height: 270,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 15.0,
                            left: 60,
                            right: 60,
                          ),
                          child: Text(
                            'Search for a camp by entering its name in the search bar above',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

Future<dynamic> searchCamp(String token, String campName) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request =
      http.Request('POST', Uri.parse('http://3.135.1.141/api/searchCamp'));
  request.body = json.encode({"camp_name": campName});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
