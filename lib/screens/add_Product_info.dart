import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductInfoScreen extends StatelessWidget {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productSpecificationsController = TextEditingController();
  final TextEditingController _productPricingController = TextEditingController();
  final firestore = FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Information'),
        backgroundColor: Colors.blue, // Change app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Product',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue), // Change text color
            ),
            SizedBox(height: 16),
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _productDescriptionController,
              decoration: InputDecoration(
                labelText: 'Product Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _productSpecificationsController,
              decoration: InputDecoration(
                labelText: 'Product Specifications',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _productPricingController,
              decoration: InputDecoration(
                labelText: 'Product Pricing',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final productName = _productNameController.text;
                final productDescription = _productDescriptionController.text;
                final productSpecifications = _productSpecificationsController.text;
                final productPricing = _productPricingController.text;
              
                String id = DateTime.now().millisecondsSinceEpoch.toString();
              
                if (productName.isNotEmpty &&
                    productDescription.isNotEmpty &&
                    productSpecifications.isNotEmpty &&
                    productPricing.isNotEmpty) {
                  firestore.doc(id).set({
                    'productName': productName,
                    'productDescription': productDescription,
                    'productSpecifications': productSpecifications,
                    'productPricing': productPricing,
                    'timestamp': FieldValue.serverTimestamp(),
                  }).then((value) {
                    _productNameController.clear();
                    _productDescriptionController.clear();
                    _productSpecificationsController.clear();
                    _productPricingController.clear();
                  }).onError((error, stackTrace) {
                    // Handle error
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Change button color
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Change button shape
              ),
              child: Text('Add Product', style: TextStyle(color: Colors.white)), // Change text color
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                
                    final data = snapshot.data?.docs;
                
                    if (data == null || data.isEmpty) {
                      return Center(child: Text('No products available.', style: TextStyle(color: Colors.blue))); // Change text color
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
