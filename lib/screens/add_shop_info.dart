import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddShopInfoScreen extends StatelessWidget {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopContactController = TextEditingController();
  final TextEditingController _shopEmailController = TextEditingController();

  final firestore = FirebaseFirestore.instance.collection('shops');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Information'),
        backgroundColor: Colors.green, // Change app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Shop Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green), // Change text color
            ),
            SizedBox(height: 16),
            TextField(
              controller: _shopNameController,
              decoration: InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _shopAddressController,
              decoration: InputDecoration(
                labelText: 'Shop Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _shopContactController,
              decoration: InputDecoration(
                labelText: 'Shop Contact',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _shopEmailController,
              decoration: InputDecoration(
                labelText: 'Shop Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final shopName = _shopNameController.text;
                final shopAddress = _shopAddressController.text;
                final shopContact = _shopContactController.text;
                final shopEmail = _shopEmailController.text;
              
                String id = DateTime.now().millisecondsSinceEpoch.toString();
              
                if (shopName.isNotEmpty &&
                    shopAddress.isNotEmpty &&
                    shopContact.isNotEmpty &&
                    shopEmail.isNotEmpty) {
                  firestore.doc(id).set({
                    'shopName': shopName,
                    'shopAddress': shopAddress,
                    'shopContact': shopContact,
                    'shopEmail': shopEmail,
                    'timestamp': FieldValue.serverTimestamp(),
                  }).then((value) {
                    _shopNameController.clear();
                    _shopAddressController.clear();
                    _shopContactController.clear();
                    _shopEmailController.clear();
                  }).onError((error, stackTrace) {
                    // Handle error
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Change button color
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Change button shape
              ),
              child: Text('Add Shop Information', style: TextStyle(color: Colors.white)), // Change text color
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('shops')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                
                    final data = snapshot.data?.docs;
                
                    if (data == null || data.isEmpty) {
                      return Center(child: Text('No shop information available.', style: TextStyle(color: Colors.green))); // Change text color
                    }
                
                    return ListView.builder(
                      shrinkWrap: true, 
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final doc = data[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 5.0,
                          child: ListTile(
                            title: Text(doc['shopName']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Shop Address: ${doc['shopAddress']}'),
                                Text('Shop Contact: ${doc['shopContact']}'),
                                Text('Shop Email: ${doc['shopEmail']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
