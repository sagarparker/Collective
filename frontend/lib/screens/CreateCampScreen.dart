import 'package:collective/screens/HomeScreen.dart';
import 'package:collective/widgets/appBarGoBack.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CreateCampScreen extends StatefulWidget {
  static String routeName = '/createCampScreen';

  @override
  _CreateCampScreenState createState() => _CreateCampScreenState();
}

class _CreateCampScreenState extends State<CreateCampScreen> {
  String token;
  File _image;
  String _imagePath;
  final picker = ImagePicker();

  TextEditingController campNameController = new TextEditingController();
  TextEditingController campEquityController = new TextEditingController();
  TextEditingController campTargetController = new TextEditingController();
  TextEditingController campDescriptionController = new TextEditingController();
  TextEditingController longDescriptionController = new TextEditingController();
  TextEditingController campCategoryController = new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final campNameValidator = MultiValidator([
    RequiredValidator(errorText: 'Camp name is required'),
  ]);

  final campEquityValidator = MultiValidator([
    RequiredValidator(errorText: 'Equity is required'),
  ]);

  final campTargetValidator = MultiValidator([
    RequiredValidator(errorText: 'Target is required'),
  ]);

  final campCategoryValidator = MultiValidator([
    RequiredValidator(errorText: 'Category is required'),
  ]);

  final campDescriptionValidator = MultiValidator([
    RequiredValidator(errorText: 'Description is required'),
    MaxLengthValidator(116,
        errorText: 'Description cannot be longer than 116 characters.')
  ]);

  @override
  void dispose() {
    campNameController.dispose();
    campEquityController.dispose();
    campTargetController.dispose();
    campDescriptionController.dispose();
    campCategoryController.dispose();
    super.dispose();
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _imagePath = pickedFile.path;
        print(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void createCampMethod() {
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
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "Creating camp",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
            ),
          ),
          SpinKitFadingCube(
            color: Theme.of(context).primaryColor,
            size: 30.0,
          )
        ],
      ),
    ));

    createCamp(
      token,
      campNameController.text,
      int.parse(campEquityController.text),
      int.parse(campTargetController.text),
      campDescriptionController.text,
      campCategoryController.text,
      _imagePath,
    ).then(
      (data) {
        if (data['result'] == true) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(20),
              content: Text(
                "Camp created",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
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
                "There was a problem creating the camp",
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      },
    );
  }

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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: AppBarGoBack(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: _image == null
                    ? Image.asset(
                        'assets/images/Create.png',
                        height: 225,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        _image,
                        height: 225,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              Container(
                height: 452,
                margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 30),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Camp name',
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
                          controller: campNameController,
                          validator: campNameValidator,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Catergory',
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
                          controller: campCategoryController,
                          validator: campCategoryValidator,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Description',
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
                          controller: campDescriptionController,
                          validator: campDescriptionValidator,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Equity',
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
                          controller: campEquityController,
                          validator: campEquityValidator,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Target',
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
                          controller: campTargetController,
                          validator: campTargetValidator,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin:
                                EdgeInsets.only(top: 20, bottom: 20, left: 5),
                            child: _image == null
                                ? Text(
                                    'Please select a camp image',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Theme.of(context).primaryColor),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      _formKey.currentState.validate()
                                          ? createCampMethod()
                                          : ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                              padding: EdgeInsets.all(20),
                                              content: Text(
                                                "Please enter valid camp details",
                                                textAlign: TextAlign.center,
                                              ),
                                            ));
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                            'Create camp',
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size(210, 45),
                                      elevation: 0,
                                      primary: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20, bottom: 20),
                            child: ElevatedButton(
                              onPressed: getImage,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 0),
                                    child: Icon(
                                      Icons.image,
                                    ),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(90, 45),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> createCamp(
  String token,
  String campName,
  int equity,
  int target,
  String description,
  String category,
  String imagePath,
) async {
  var headers = {
    'x-api-key':
        '8\$dsfsfgreb6&4w5fsdjdjkje#\$54757jdskjrekrm@#\$@\$%&8fdddg*&*ffdsds',
    'Authorization': token
  };
  var request = http.MultipartRequest(
      'POST', Uri.parse('http://3.135.1.141/api/createCamp'));
  request.fields.addAll({
    'camp_name': campName,
    'camp_equity': equity.toString(),
    'camp_target': target.toString(),
    'camp_description': description,
    'long_description': 'Long description',
    'category': category,
  });
  request.files.add(await http.MultipartFile.fromPath('image', imagePath));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  return await jsonDecode(await response.stream.bytesToString());
}
