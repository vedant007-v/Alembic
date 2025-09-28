import 'package:apmc/screens/add_Product_info.dart';
import 'package:apmc/screens/add_order_info.dart';
import 'package:apmc/screens/add_sales_info.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:apmc/screens/add_shop_info.dart';
import 'package:apmc/screens/animal_husbandry.dart';
import 'package:apmc/screens/login_screen.dart';
import 'package:apmc/screens/user_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apmc/screens/add_Product_info.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});

final List<Map<String, dynamic>> cards = [
  {
    'title': 'Add new Farmer',
    'icon': FontAwesomeIcons.personDigging,
    'isFontAwesome': true,
    'screen': AddShopInfoScreen(),
  },
  {
    'title': 'Add Farmer crops Details',
    'icon': FontAwesomeIcons.seedling,
    'isFontAwesome': true,
    'goThroughRationCard': true,
    'screenBuilder': (String rationCardNo) =>
    AddFarmExpenseScreen(rationCardNo: rationCardNo),

  },
  {
    'title': 'Add Intervention',
    'icon': FontAwesomeIcons.toolbox,
    'isFontAwesome': true,
    'goThroughRationCard': true,
    'screenBuilder': (String rationCardNo) =>
        AddInterventionScreen(rationCardNo: rationCardNo),
  },
  {
    'title': 'Animal Husbandry',
    'icon': FontAwesomeIcons.cow,
    'isFontAwesome': true,
    'goThroughRationCard': true,
    'screenBuilder': (String rationCardNo) =>
        AnimalHusbandryScreen(rationCardNo: rationCardNo),
  },
];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'User Dashboard',
    style: TextStyle(color: Colors.white), // 👈 Title text white
  ),
  backgroundColor: Colors.teal,
  iconTheme: const IconThemeData(color: Colors.white), // 👈 Drawer icon white
),
      drawer: const NavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Slogan
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

            // Grid view of features
            Expanded(
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final item = cards[index];
                  return LoginBlock(
                    title: item['title'],
                    icon: item['icon'],
                    isFontAwesome: item['isFontAwesome'] ?? false,
                    onTap: () {
                      if (item['goThroughRationCard'] == true) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RationCardScreen(
        nextScreen: (rationCardNumber) => item['screenBuilder'](rationCardNumber),
      ),
    ),
  );
} else {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => item['screen'],
    ),
  );
}

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
  final bool isFontAwesome;
  final VoidCallback onTap;

  const LoginBlock({
    super.key,
    required this.title,
    required this.icon,
    required this.isFontAwesome,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = isFontAwesome
        ? FaIcon(icon, color: Colors.teal, size: 30)
        : Icon(icon, color: Colors.teal, size: 30);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.teal[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Drawer(
        child: Center(child: Text('No user is currently signed in.')),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Drawer(
            child: Center(child: Text('Error fetching user data')),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;

        if (userData == null) {
          return const Drawer(
            child: Center(child: Text('User data not found')),
          );
        }

        final String userName = userData['name'] ?? 'Unknown';
        final String userEmail = userData['email'] ?? 'Unknown';

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.teal,
                ),
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0] : '',
                    style: const TextStyle(
                      fontSize: 24.0,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
              _createDrawerItem(
                icon: Icons.home,
                text: 'Home',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminDashboard()),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.logout_rounded,
                text: 'Log out',
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>  LoginScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.teal),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
