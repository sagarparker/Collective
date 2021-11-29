import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:collective/screens/CreateCampHomeScreen.dart';
import 'package:collective/screens/SearchCampScreen.dart';
import 'package:collective/screens/SupportEmailScreen.dart';
import 'package:collective/screens/UserDetailsScreen.dart';
import 'package:collective/screens/UserInvestmentScreen.dart';
import 'package:collective/screens/UsersCampScreen.dart';
import 'package:collective/screens/UsersCollabScreen.dart';
import 'package:collective/widgets/HomeScreenWidget.dart';
import 'package:collective/widgets/keepAlivePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/homeScreen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  PageController _pageController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      key: _scaffoldKey,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          color: Colors.black,
          iconSize: 25,
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
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
        actions: [
          IconButton(
              icon: Icon(
                Icons.person,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(UserDetailsScreen.routeName);
              })
        ],
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 64,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 240, 240, 1),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0, left: 0.0),
                        child: Text(
                          'Collective',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('Account'),
                onTap: () {
                  Navigator.of(context).pushNamed(UserDetailsScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.campaign,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('Camps owned'),
                onTap: () {
                  Navigator.of(context).pushNamed(UsersCampScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                  leading: Icon(
                    Icons.monetization_on,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('Investments'),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(UserInvestmentScreen.routeName);
                  }),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.group,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('Collaborations'),
                onTap: () {
                  Navigator.of(context).pushNamed(UsersCollabScreen.routeName);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.help_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('Support'),
                onTap: () {
                  Navigator.of(context).pushNamed(SupportEmailScreen.routeName);
                },
              ),
              Divider()
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: [
          KeepAlivePage(child: SearchCampScreen()),
          KeepAlivePage(child: HomeScreenWidget()),
          CreateCampHomeScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        containerHeight: 47,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        curve: Curves.easeIn,
        backgroundColor: Colors.white,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).primaryColor,
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Text(
                'Search',
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).primaryColor),
              ),
            ),
            inactiveColor: Colors.black26,
            activeColor: Colors.grey[400],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(
              Icons.campaign,
              color: Theme.of(context).primaryColor,
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Text(
                'Camps',
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).primaryColor),
              ),
            ),
            inactiveColor: Colors.black26,
            activeColor: Colors.grey[400],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(
              Icons.add_circle_rounded,
              color: Theme.of(context).primaryColor,
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 1.0),
              child: Text(
                'Create',
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).primaryColor),
              ),
            ),
            inactiveColor: Colors.black26,
            activeColor: Colors.grey[400],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
