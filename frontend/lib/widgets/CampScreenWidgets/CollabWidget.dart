import 'package:collective/screens/CollabMainScreen.dart';
import 'package:flutter/material.dart';

class CollabWidget extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final String username;
  final Map selectedCamp;
  final String campId;

  CollabWidget(this.snapshot, this.username, this.selectedCamp, this.campId);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 8,
        ),
        Container(
          width: MediaQuery.of(context).size.width - 40,
          height: 60,
          margin: EdgeInsets.only(
            bottom: 7,
          ),
          child: Text(
            snapshot.data["details"]["camp_description"],
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
          ),
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total collabs',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              snapshot.data["details"]["campCollabCount"].toString(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        Divider(),
        SizedBox(
          height: 10,
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
                  'Collab with ' + snapshot.data['details']['name'],
                  style: TextStyle(
                      fontSize: 19, color: Theme.of(context).primaryColor),
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
            minimumSize: Size(100, 45),
          ),
          onPressed: () {
            Navigator.of(context)
                .pushNamed(CollabMainScreen.routeName, arguments: {
              "username": username,
              "selectedCamp": selectedCamp,
              "campId": campId,
              "campOwner": snapshot.data['details']['owner']
            });
          },
        )
      ],
    );
  }
}
