import 'package:collective/screens/InvestInCamp.dart';
import 'package:flutter/material.dart';

class InvestWidget extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final String username;
  final Map selectedCamp;

  InvestWidget(this.snapshot, this.username, this.selectedCamp);

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
        snapshot.data['details']['targetReachedDB']
            ? snapshot.data['details']['owner'] == username
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 18,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3, top: 2),
                            child: Text(
                              'Funding raised!',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
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
                                'Withdraw amount',
                                style: TextStyle(
                                  fontSize: 15,
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
                          minimumSize: Size(100, 45),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 28,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3, top: 5),
                            child: Text(
                              'Funding raised!',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
            : ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 3,
                        bottom: 0,
                      ),
                      child: Text(
                        'Invest in ' + snapshot.data['details']['name'],
                        style: TextStyle(
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
                  minimumSize: Size(100, 45),
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(InvestInCamp.routeName, arguments: {
                    'campAddress': selectedCamp['campAddress'],
                    'campName': snapshot.data['details']['name'],
                    'target': snapshot.data['details']['target'],
                    'equity': snapshot.data['details']['equity'],
                    'raised': snapshot.data['details']['fundingRaised']
                  });
                },
              ),
      ],
    );
  }
}
