import 'package:flutter/material.dart';

class AppBarGoBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.navigate_before),
        color: Colors.black,
        iconSize: 25,
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      elevation: 2,
      centerTitle: true,
      title: Container(
        width: 155,
        child: Row(
          children: [
            Image.asset(
              'assets/images/Logo.png',
              width: 32,
              height: 32,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.5, left: 3),
              child: Text(
                'Collective',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
