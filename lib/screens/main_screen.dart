import 'package:flutter/material.dart';
import 'package:mkgo/screens/home_screen.dart';
import 'package:mkgo/screens/my_saved_bathrooms_screen.dart';
import 'package:mkgo/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We need to pass the callback to the HomeScreen.
    // We can do this by rebuilding the list of widgets every time.
    final List<Widget> widgetOptions = <Widget>[
      HomeScreen(onProfileTap: () => _onItemTapped(2)),
      const MySavedBathroomsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Mis Baños',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
