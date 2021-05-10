import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Logo.png',
              height: 45,
            ),
            Text(
              'Collective',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 27),
            ),
          ],
        ),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 245,
              padding: const EdgeInsets.only(top: 50, left: 40, right: 40),
              child: Form(
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email / Username',
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 25),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          minimumSize: Size(double.infinity, 45),
                        ),
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'New User? Register here.',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              height: 330,
              margin: EdgeInsets.only(
                top: 40,
              ),
              child: Image.asset(
                'assets/images/LoginScreen.png',
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    );
  }
}
