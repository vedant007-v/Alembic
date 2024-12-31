import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddOrderInfoScreen extends StatelessWidget {
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _orderStatusController = TextEditingController();
  final TextEditingController _totalPriceController = TextEditingController();

  final firestore = FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Information'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Order',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _customerIdController,
              decoration: InputDecoration(
                labelText: 'Customer ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _orderIdController,
              decoration: InputDecoration(
                labelText: 'Order ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _paymentController,
              decoration: InputDecoration(
                labelText: 'Payment',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _orderStatusController,
              decoration: InputDecoration(
                labelText: 'Order Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _totalPriceController,
              decoration: InputDecoration(
                labelText: 'Total Price',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final customerId = _customerIdController.text;
                final orderId = _orderIdController.text;
                final payment = _paymentController.text;
                final orderStatus = _orderStatusController.text;
                final totalPrice = _totalPriceController.text;
              
                String id = DateTime.now().millisecondsSinceEpoch.toString();
              
                if (customerId.isNotEmpty &&
                    orderId.isNotEmpty &&
                    payment.isNotEmpty &&
                    orderStatus.isNotEmpty &&
                    totalPrice.isNotEmpty) {
                  firestore.doc(id).set({
                    'customerId': customerId,
                    'orderId': orderId,
                    'payment': payment,
                    'orderStatus': orderStatus,
                    'totalPrice': totalPrice,
                    'timestamp': FieldValue.serverTimestamp(),
                  }).then((value) {
                    _customerIdController.clear();
                    _orderIdController.clear();
                    _paymentController.clear();
                    _orderStatusController.clear();
                    _totalPriceController.clear();
                  }).onError((error, stackTrace) {
                    // Handle error
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('Add Order', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 16),
            Expanded( // Wrap the StreamBuilder with Expanded
              child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                
                    final data = snapshot.data?.docs;
                
                    if (data == null || data.isEmpty) {
                      return Center(child: Text('No orders available.', style: TextStyle(color: Colors.blue)));
                    }
                
                    return ListView.builder(
                      shrinkWrap: true, // Added this to make ListView scrollable inside SingleChildScrollView
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final doc = data[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 5.0,
                          child: ListTile(
                            title: Text('Order ID: ${doc['orderId']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer ID: ${doc['customerId']}'),
                                Text('Payment: ${doc['payment']}'),
                                Text('Order Status: ${doc['orderStatus']}'),
                                Text('Total Price: ₹ ${doc['totalPrice']}'),
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
