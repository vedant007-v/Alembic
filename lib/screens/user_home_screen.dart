import 'package:apmc/screens/admin_info.dart';
import 'package:apmc/screens/login_screen.dart';
import 'package:apmc/screens/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:apmc/screens/Product_info.dart';
import 'package:apmc/screens/dashboard_page.dart';
import 'package:apmc/screens/order_info.dart';
import 'package:apmc/screens/sales_info.dart';
import 'package:apmc/screens/shop_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHomeScreen extends StatefulWidget {
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Apmc'),
        backgroundColor: Colors.green,
      ),
      drawer: NavigationDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 3 / 2,
            children: <Widget>[
              LoginBlock(
                title: 'Shop Info',
                icon: Icons.shop_2_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserShopInfo()),
                  );
                },
              ),
              LoginBlock(
                title: 'Product Info',
                icon: Icons.production_quantity_limits_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProductInfo()),
                  );
                },
              ),
              LoginBlock(
                title: 'Order Info',
                icon: Icons.shopping_cart,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserOrderInfo()),
                  );
                },
              ),
              LoginBlock(
                title: 'Sales Info',
                icon: Icons.trending_up,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserSalesInfo()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginBlock extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  LoginBlock({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5.0,
        margin: EdgeInsets.all(4.0),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 30.0, color: Colors.green),
              SizedBox(height: 4.0),
              Text(title, style: TextStyle(fontSize: 14.0, color: Colors.green)),
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
                  color: Colors.green,
                ),
                accountName: Text(userName),
                accountEmail: Text(userEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    userName.isNotEmpty ? userName[0] : '',
                    style: TextStyle(fontSize: 24.0, color: Colors.green),
                  ),
                ),
              ),
              if (userRole == 'user')
                _createDrawerItem(
                  icon: Icons.admin_panel_settings_rounded,
                  text: 'Admin Info',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminInfo()),
                    );
                  },
                ),
              _createDrawerItem(
                icon: Icons.home,
                text: 'Home',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AdminDashboard()),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.shop_2_rounded,
                text: 'Shop info',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserShopInfo()),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.production_quantity_limits_rounded,
                text: 'Product_info',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserProductInfo()),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.shopping_cart,
                text: 'Order info',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserOrderInfo()),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.trending_up,
                text: 'Sales info',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UserSalesInfo()),
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
          Icon(icon, color: Colors.green),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text, style: TextStyle(color: Colors.green)),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
