import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSalesInfoScreen extends StatelessWidget {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  final firestore = FirebaseFirestore.instance.collection('sales');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Information'),
        backgroundColor: Colors.orange, // Change app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Sales Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange), // Change text color
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
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _totalController,
              decoration: InputDecoration(
                labelText: 'Total',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final productName = _productNameController.text;
                final quantity = _quantityController.text;
                final price = _priceController.text;
                final total = _totalController.text;
              
                String id = DateTime.now().millisecondsSinceEpoch.toString();
              
                if (productName.isNotEmpty && quantity.isNotEmpty && price.isNotEmpty && total.isNotEmpty) {
                  firestore.doc(id).set({
                    'productName': productName,
                    'quantity': quantity,
                    'price': price,
                    'total': total,
                    'timestamp': FieldValue.serverTimestamp(),
                  }).then((value) {
                    _productNameController.clear();
                    _quantityController.clear();
                    _priceController.clear();
                    _totalController.clear();
                  }).onError((error, stackTrace) {
                    // Handle error
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Change button color
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Change button shape
              ),
              child: Text('Add Sales Information', style: TextStyle(color: Colors.white)), // Change text color
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('sales')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                
                    final data = snapshot.data?.docs;
                
                    if (data == null || data.isEmpty) {
                      return Center(child: Text('No sales information available.', style: TextStyle(color: Colors.orange))); // Change text color
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
                                Text('Quantity: ${doc['quantity']}'),
                                Text('Price: ₹ ${doc['price']}'),
                                Text('Total: ₹ ${doc['total']}'),
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
