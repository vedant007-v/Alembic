import 'package:apmc/screens/login_screen.dart';
import 'package:apmc/screens/settings_page.dart';
import 'package:apmc/screens/user_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // You can replace this with your logo or any other widget
                Text(
                  'Krishi',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoMono',
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
          // Image.asset(
          //   'assets/apmclogo.png',
          //   fit: BoxFit.cover,
          // ),
          // Show a progress indicator while loading
          FutureBuilder<User?>(
            future: _checkAuthenticationStatus(),
            builder: (context, AsyncSnapshot<User?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    // child: CircularProgressIndicator(
                    //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    // ),
                  ),
                );
              } else {
                if (snapshot.hasData) {
                  return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(snapshot.data!.uid) // Use the user's UID
                        .get(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          color: Colors.black.withOpacity(0.4),
                          // child: Center(
                          //   child: CircularProgressIndicator(
                          //     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          //   ),
                          // ),
                        );
                      } else {
                        if (userSnapshot.hasData) {
                          // Get user data from the document snapshot
                          Map<String, dynamic>? userData = userSnapshot.data!.data();

                          if (userData != null) {
                            // Check the user role
                            String role = userData['role'];
                            if (role == 'admin') {
                              // Navigate to the admin dashboard screen
                              return UserHomeScreen(); // Return admin dashboard
                            } else {
                              // Navigate to user dashboard or any other screen
                              // Replace UserHomeScreen with your desired screen for regular users
                              return AdminDashboard(); // Return user home screen
                            }
                          }
                        }
                      }
                      // If user data is not available or role is not determined yet, show nothing
                      return Container();
                    },
                  );
                } else {
                  // If user is not logged in, navigate to login screen
                  return LoginScreen(); // Navigate to login screen
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<User?> _checkAuthenticationStatus() async {
    // Wait for Firebase Authentication initialization
    await Future.delayed(Duration(seconds: 1));

    return FirebaseAuth.instance.currentUser;
  }
}
