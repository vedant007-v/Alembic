import 'package:apmc/screens/user_home_screen.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_page.dart';
import '../screens/settings_page.dart';



class NavigationsDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Admin Dashboard',
                style: TextStyle(color: Colors.white, fontSize: 24)),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
            
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Users'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserHomeScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AdminDashboard()));
            },
          ),
        ],
      ),
    );
  }
}
