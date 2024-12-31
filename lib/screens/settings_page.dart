import 'package:apmc/screens/add_admin.dart';
import 'package:apmc/screens/admin_info.dart';
import 'package:apmc/screens/login_screen.dart';
import 'package:apmc/screens/users_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:apmc/screens/add_Product_info.dart';
import 'package:apmc/screens/add_order_info.dart';
import 'package:apmc/screens/add_sales_info.dart';
import 'package:apmc/screens/add_shop_info.dart';
import 'package:apmc/screens/sales_info.dart';
import 'package:apmc/screens/dashboard_page.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.green,
      ),
      drawer: NavigationDrawer(),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.02), // Responsive padding
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: screenWidth > 600 ? 4 / 3 : 3 / 2, // Adjust aspect ratio based on screen width
          crossAxisSpacing: screenWidth * 0.02, // Responsive spacing
          mainAxisSpacing: screenWidth * 0.02, // Responsive spacing
          children: <Widget>[
            LoginBlock(
              title: 'Add Shop Info',
              icon: Icons.shop_2_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddShopInfoScreen()),
                );
              },
            ),
            LoginBlock(
              title: 'Add Product Info',
              icon: Icons.production_quantity_limits_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddProductInfoScreen()),
                );
              },
            ),
            LoginBlock(
              title: 'Add Order Info',
              icon: Icons.shopping_cart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddOrderInfoScreen()),
                );
              },
            ),
            LoginBlock(
              title: 'Add Sales Info',
              icon: Icons.trending_up,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddSalesInfoScreen()),
                );
              },
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

  LoginBlock({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get screen dimensions for better sizing
        final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5.0,
        margin: EdgeInsets.all(screenWidth * 0.02), // Responsive margin
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: screenWidth * 0.08, color: Colors.green), // Responsive icon size
              SizedBox(height: screenWidth * 0.02), // Responsive space between icon and text
              Text(title,
                  style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.green)), // Responsive text size
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
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get(),
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
                    style: TextStyle(
                        fontSize: 24.0,
                        color: Colors.green),
                  ),
                ),
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
                icon: Icons.person,
                text: 'Add Admin',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => addAdmin()),
                  );
                },
              ),
              _createDrawerItem(
                icon: Icons.person,
                text: 'User Info',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UsersInfo()),
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
          Icon(icon, color: Colors.green),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text,
                style: TextStyle(color: Colors.green)),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}

