import 'package:flutter/material.dart';
import '../screens/user_home_screen.dart';
// Import other screens as needed

class UserNavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('User Dashboard', style: TextStyle(color: Colors.white, fontSize: 24)),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserHomeScreen()));
            },
          ),
          // Add more ListTiles for other navigation items
        ],
      ),
    );
  }
}
