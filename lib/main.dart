import 'package:chip_pos/navbttnbar/menu.dart';
import 'package:chip_pos/navbttnbar/profile.dart';
import 'package:chip_pos/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:chip_pos/login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    return FirebaseAuth.instance.currentUser != null ? MainMenu() : Login();
  }
}

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 0;
  static List<Widget> _pages = <Widget>[
    Menu(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: CurvedNavigationBar(
          items: <Widget>[
            Icon(
              Icons.dashboard,
              size: 30,
              color: AppColors.putihCerah,
            ),
            Icon(
              Icons.menu_book,
              size: 30,
              color: AppColors.putihCerah,
            ),
          ],
          index: _selectedIndex,
          height: 60,
          color: AppColors.bg,
          buttonBackgroundColor: AppColors.appbar,
          backgroundColor: const Color.fromARGB(154, 203, 200, 185),
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 200),
          onTap: (index) => _onItemTapped(index),
        ),
      ),
    );
  }
}
