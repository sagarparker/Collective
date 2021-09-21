import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateCampCollabJobScreen extends StatefulWidget {
  static String routeName = '/createCampCollabJob';

  @override
  _CreateCampCollabJobScreenState createState() =>
      _CreateCampCollabJobScreenState();
}

class _CreateCampCollabJobScreenState extends State<CreateCampCollabJobScreen> {
  Map campData = {};
  String token;
  List<String> descriptionList = [];

  final _descriptionformKey = GlobalKey<FormState>();
  final _newJobformKey = GlobalKey<FormState>();

  TextEditingController descriptionItem = new TextEditingController();
  TextEditingController collabTitle = new TextEditingController();
  TextEditingController collabAmount = new TextEditingController();

  final descriptionItemValidator = MultiValidator([
    RequiredValidator(errorText: 'A description item is required'),
  ]);

  final collabTitleValidator = MultiValidator([
    RequiredValidator(errorText: 'Collab title is required'),
  ]);

  final collabAmountValidator = MultiValidator([
    RequiredValidator(errorText: 'Collab amount item is required'),
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

  void addItemToDescriptionList() {
    setState(() {
      descriptionList.add(descriptionItem.text.toString());
      descriptionItem.clear();
    });
  }

  void createCampCollabJob() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      duration: Duration(days: 1),
      padding: EdgeInsets.only(
        top: 300,
        bottom: 150,
        left: 30,
        right: 30,
      ),
      content: Column(
        children: [
          SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          )
        ],
      ),
    ));

    newCollabJobForCamp(token, campData['campId'], campData['campOwner'],
            collabTitle.text, collabAmount.text, descriptionList)
        .then((data) {
      if (data['result'] == true) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            padding: EdgeInsets.all(20),
            content: Text(
              "New collab job added to the camp",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      } else if (data['result'] == false) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            padding: EdgeInsets.all(20),
            content: Text(
              "There was a problem adding a collab job to the camp",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    descriptionItem.dispose();
    collabTitle.dispose();
    collabAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    campData = ModalRoute.of(context).settings.arguments;
    print(campData);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: AppBarGoBack(),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                37,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Text(
                    'Create new collab job',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  width: MediaQuery.of(context).size.width,
                  height: 80,
                  child: Form(
                    key: _descriptionformKey,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Add the item here',
                        labelStyle: TextStyle(fontSize: 15),
                        filled: true,
                        fillColor: Colors.grey[50],
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              BorderSide(color: Colors.grey[300], width: 1),
                        ),
                      ),
                      controller: descriptionItem,
                      validator: descriptionItemValidator,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 16,
                  ),
                  padding: EdgeInsets.only(left: 16, right: 16),
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      _descriptionformKey.currentState.validate()
                          ? addItemToDescriptionList()
                          : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              padding: EdgeInsets.all(20),
                              content: Text(
                                "Please enter valid description item",
                                textAlign: TextAlign.center,
                              ),
                            ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Text(
                            'Add an item to the description list',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      primary: Color.fromRGBO(230, 230, 230, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 16, top: 20, right: 16),
                  height: 200,
                  child: descriptionList.length == 0
                      ? Container(
                          padding: EdgeInsets.only(top: 30),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/notfound.png',
                                width: MediaQuery.of(context).size.width,
                                height: 130,
                              ),
                              Text('No description added yet')
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Text(descriptionList[index]),
                                  ],
                                ),
                                Divider(),
                              ],
                            );
                          },
                          itemCount: descriptionList.length,
                        ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 190,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Form(
                    key: _newJobformKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Collab job title',
                            labelStyle: TextStyle(fontSize: 15),
                            filled: true,
                            fillColor: Colors.grey[50],
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  BorderSide(color: Colors.grey[300], width: 1),
                            ),
                          ),
                          controller: collabTitle,
                          validator: collabTitleValidator,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 15,
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Collab job CTV amount',
                              labelStyle: TextStyle(fontSize: 15),
                              filled: true,
                              fillColor: Colors.grey[50],
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                    color: Colors.grey[300], width: 1),
                              ),
                            ),
                            controller: collabAmount,
                            keyboardType: TextInputType.number,
                            validator: collabAmountValidator,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 10,
                  ),
                  padding: EdgeInsets.only(left: 16, right: 16),
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      _newJobformKey.currentState.validate()
                          ? createCampCollabJob()
                          : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              padding: EdgeInsets.all(20),
                              content: Text(
                                "Please enter valid collab job details",
                                textAlign: TextAlign.center,
                              ),
                            ));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Text(
                            'Create new collab job for the camp',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

Future<dynamic> newCollabJobForCamp(
    String token,
    String campID,
    String campOwner,
    String collabTitle,
    String collabAmount,
    List<String> collabDescription) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Content-Type': 'application/json',
    'Authorization': token
  };
  var request = http.Request(
      'POST', Uri.parse('http://3.135.1.141/api/newCollabJobForCamp'));
  request.body = json.encode({
    "camp_id": campID,
    "camp_owner_username": campOwner,
    "collab_title": collabTitle,
    "collab_amount": collabAmount,
    "collab_description": collabDescription
  });

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
