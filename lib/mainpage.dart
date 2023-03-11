import 'package:flutter/material.dart';
import 'homepage.dart';
import 'landpage.dart';
import 'accountpage.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
  }


class _MainPageState extends State<MainPage> {

  static List pages = [
    HomePage(),
    LandPage(),
    AccountPage(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body:pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label:"Ana Sayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.landscape), label:"Parsellerim"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label:"Hesabım"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        selectedFontSize: 18,
        unselectedFontSize: 15,
        iconSize: 25,
        onTap: _onItemTapped,
      ),
    );
  }
}