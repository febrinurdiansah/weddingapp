import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'detailScreen.dart';
import 'historiScreen.dart';
import 'homeScreen.dart';
import 'loginScreen.dart';
import 'profilScreen.dart';
import 'registerScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen());
  }
}

class NavPage extends StatefulWidget {
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  State<NavPage> createState() => _HomeState();
}

class _HomeState extends State<NavPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: NavPage._widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            child: SafeArea(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  child: GNav(
                      rippleColor: Color.fromRGBO(218, 137, 100, 1),
                      hoverColor: Color.fromRGBO(211, 121, 79, 1),
                      gap: 8,
                      activeColor: Color.fromRGBO(196, 86, 35, 1),
                      iconSize: 24,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      duration: Duration(milliseconds: 400),
                      tabActiveBorder: Border.all(
                          color: Color.fromRGBO(165, 90, 57, 1), width: 1),
                      color: Color.fromRGBO(210, 177, 162, 1),
                      tabs: [
                        GButton(
                          icon: Icons.home,
                          text: 'Home',
                        ),
                        GButton(
                          icon: Icons.article_rounded,
                          text: 'Histori',
                        ),
                        GButton(
                          icon: Icons.person,
                          text: 'Profil',
                        ),
                      ],
                      selectedIndex: _selectedIndex,
                      onTabChange: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      })),
            ),
          ),
        ));
  }
}