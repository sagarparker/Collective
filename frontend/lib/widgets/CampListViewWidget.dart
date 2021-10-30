import 'package:collective/screens/CampScreen.dart';
import 'package:flutter/material.dart';
import 'package:progressive_image/progressive_image.dart';

class CampListViewWidget extends StatelessWidget {
  final AsyncSnapshot snapshot;

  CampListViewWidget(this.snapshot);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10, left: 6, right: 6, bottom: 200),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Color.fromRGBO(240, 240, 240, 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 0.0,
              ),
            ],
          ),
          height: 360,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width - 32,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      child: ProgressiveImage(
                        placeholder:
                            AssetImage('assets/images/placeholder.jpg'),
                        thumbnail: AssetImage('assets/images/placeholder.jpg'),
                        image: NetworkImage(
                            snapshot.data['details'][index]['camp_image']),
                        fit: BoxFit.cover,
                        height: 180,
                        width: MediaQuery.of(context).size.width - 32,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    height: 180,
                    width: MediaQuery.of(context).size.width - 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      color: Color.fromRGBO(250, 250, 250, 1),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          width: 326,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                snapshot.data['details'][index]['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 0),
                                child: Text(
                                  '- ' +
                                      snapshot.data['details'][index]
                                          ['category'],
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 64,
                          width: 326,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              snapshot.data['details'][index]
                                  ['camp_description'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 15.5,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        Divider(),
                        Container(
                          padding: EdgeInsets.only(top: 6),
                          height: 40,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/LogoNoPadding.png',
                                    width: 27,
                                    height: 27,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 4, left: 3),
                                    child: Text(
                                      snapshot.data['details'][index]['target']
                                          .toString()
                                          .replaceAllMapped(
                                              new RegExp(
                                                  r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                              (Match m) => '${m[1]},'),
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    primary: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(60)),
                                    minimumSize: Size(100, 45)),
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                      CampScreen.routeName,
                                      arguments: {
                                        'campAddress': snapshot.data['details']
                                            [index]['address']
                                      });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Checkout',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      itemCount: snapshot.data['details'].length,
    );
  }
}
