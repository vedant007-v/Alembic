import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProductInfo extends StatelessWidget {
  final firestore = FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Information'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: firestore.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data?.docs;

                  if (data == null || data.isEmpty) {
                    return Center(
                      child: Text(
                        'No products available.',
                        style: TextStyle(color: Colors.blue),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Enable scrolling inside SingleChildScrollView
                    physics: NeverScrollableScrollPhysics(), // Disable ListView scrolling
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final doc = data[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 5.0,
                        child: ListTile(
                          title: Text(doc['productName']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description: ${doc['productDescription']}'),
                              Text('Specifications: ${doc['productSpecifications']}'),
                              Text('Pricing: ${doc['productPricing']}'),
                            ],
                          ),
                        ),
                      );
                    },
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
