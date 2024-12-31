import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Information'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching user data'));
          }

          final userData = snapshot.data?.docs;

          if (userData == null || userData.isEmpty) {
            return Center(child: Text('No admin user data found'));
          }

          return ListView.builder(
            itemCount: userData.length,
            itemBuilder: (context, index) {
              final userDoc = userData[index];
              final user = userDoc.data() as Map<String, dynamic>;

              final String userName = user['name'] ?? 'Unknown';
              final String userEmail = user['email'] ?? 'Unknown';
              final String userNumber = user['number'] ?? 'Unknown';
              final String userRole = user['role'] ?? 'Unknown';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(userName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: $userEmail'),
                      Text('Number: $userNumber'),
                      Text('Role: $userRole'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
