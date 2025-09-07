import 'package:apmc/screens/AnimalHusbandryDataScreen.dart';
import 'package:apmc/screens/add_admin.dart';
import 'package:apmc/screens/admin_info.dart';
import 'package:apmc/screens/login_screen.dart';
import 'package:apmc/screens/settings_page.dart';
import 'package:apmc/screens/users_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:apmc/screens/Product_info.dart';
import 'package:apmc/screens/dashboard_page.dart';
import 'package:apmc/screens/order_info.dart';
import 'package:apmc/screens/sales_info.dart';
import 'package:apmc/screens/shop_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final List<Map<String, dynamic>> cards = [
    {'title': 'All details', 'icon': FontAwesomeIcons.seedling, 'screen': MergedFarmerDataScreen()},
    {'title': 'No of farmers', 'icon':FontAwesomeIcons.personDigging, 'screen': FarmerDetailsOnlyScreen()},
    {'title': 'farmers increase income', 'icon': Icons.trending_up, 'screen': PositiveNetIncomeScreen()},
    {'title': 'farmers decrease input cost', 'icon': Icons.trending_down, 'screen': NegativeNetIncomeScreen()},
        {'title': 'farmers Cow increase Milk', 'icon': FontAwesomeIcons.cow, 'screen': AnimalHusbandryDataScreen()},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    title: const Text(
      'Welcome to Admin',
      style: TextStyle(color: Colors.white), // 👈 Title text white
    ),
    backgroundColor: Colors.teal,
    iconTheme: const IconThemeData(color: Colors.white), // 👈 Drawer icon white
  ),
      drawer: NavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Every step matters – Walk towards a better future.',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, // Max width of each card (controls size!)
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final item = cards[index];
                  return LoginBlock(
                    title: item['title'],
                    icon: item['icon'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => item['screen']),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class LoginBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const LoginBlock({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.teal),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Drawer(
        child: Center(child: Text('No user is currently signed in.')),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Drawer(
            child: Center(child: Text('Error fetching user data')),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;

        if (userData == null) {
          return Drawer(
            child: Center(child: Text('User data not found')),
          );
        }

        final String userRole = userData['role'] ?? 'user';
        final String userName = userData['name'] ?? 'Unknown';
        final String userEmail = userData['email'] ?? 'Unknown';

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0] : '',
                    style: TextStyle(fontSize: 24.0, color: Colors.teal),
                  ),
                ),
              ),
              if (userRole == 'admin')
                _createDrawerItem(
                  icon: Icons.admin_panel_settings_rounded,
                  text: 'Add Users and Admins',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => addAdmin()),
                    );
                  },
                ),
              _createDrawerItem(
                icon: Icons.home,
                text: 'Home',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => addAdmin()),
                  );
                },
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.seedling,
                text: 'All details',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MergedFarmerDataScreen()),
                  );
                },
              ),
              _createDrawerItem(
                icon: FontAwesomeIcons.personDigging,
                text: 'No of farmers',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => FarmerDetailsOnlyScreen()),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.trending_up,
                text: 'farmers increase income',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PositiveNetIncomeScreen()),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.trending_down,
                text: 'farmers decrease input cost',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => NegativeNetIncomeScreen()),
                  );
                },
              ),
              if (userRole == 'admin')
                _createDrawerItem(
                  icon: Icons.logout_rounded,
                  text: 'Log out',
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _createDrawerItem(
      {required IconData icon,
      required String text,
      required GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon, color: Colors.teal),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text, style: TextStyle(color: Colors.teal)),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
