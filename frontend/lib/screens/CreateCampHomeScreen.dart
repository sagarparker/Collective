import 'package:collective/screens/CreateCampScreen.dart';
import 'package:flutter/material.dart';

class CreateCampHomeScreen extends StatelessWidget {
  static String routeName = '/createCampHomeScreen';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                'assets/images/CreateCamp.png',
                height: 355,
                width: MediaQuery.of(context).size.width,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 33.0),
                child: Text(
                  'Find fundings for your dreams',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 65,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(top: 8.0, left: 57, right: 57),
                child: Text(
                  'Collective will help you find people who are as passionate about your idea as you are',
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                      color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 28),
                child: ElevatedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 3,
                            bottom: 0,
                          ),
                          child: Text(
                            'Create a new camp',
                            style: TextStyle(
                              fontSize: 18,
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
                      minimumSize: Size(252, 42),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(CreateCampScreen.routeName);
                    }),
              )
            ],
          )
        ],
      ),
    );
  }
}
