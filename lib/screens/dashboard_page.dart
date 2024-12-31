import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final firestore = FirebaseFirestore.instance.collection('information');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.green, // Change app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green), // Change text color
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)), // Change border style
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final description = _descriptionController.text;

                String id = DateTime.now().millisecondsSinceEpoch.toString();

                if (title.isNotEmpty && description.isNotEmpty) {
                  firestore.doc(id).set({
                    'title': title,
                    'description': description,
                    'timestamp': FieldValue.serverTimestamp(),
                  }).then((value) {
                    _titleController.clear();
                    _descriptionController.clear();
                  }).onError((error, stackTrace) {
                    // Handle error
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Change button color
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Change button shape
              ),
              child: Text('Add Information', style: TextStyle(color: Colors.white)), // Change text color
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('information')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data?.docs;

                  if (data == null || data.isEmpty) {
                    return Center(child: Text('No information available.', style: TextStyle(color: Colors.green))); // Change text color
                  }

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final doc = data[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 5.0,
                        child: ListTile(
                          title: Text(doc['title']),
                          subtitle: Text(doc['description']),
                        ),
                      );
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
