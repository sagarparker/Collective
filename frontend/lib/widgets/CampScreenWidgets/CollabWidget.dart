import 'package:flutter/material.dart';

class CollabWidget extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final String username;
  final Map selectedCamp;

  CollabWidget(this.snapshot, this.username, this.selectedCamp);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 40,
          height: 65,
          child: Text(
            snapshot.data["details"]["camp_description"],
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
                      fontSize: 20, color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            primary: Color.fromRGBO(225, 225, 225, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            minimumSize: Size(100, 45),
          ),
          onPressed: () {},
        )
      ],
    );
  }
}
