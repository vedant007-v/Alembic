import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RationCardScreen extends StatelessWidget {
  final Function(String) nextScreen;

  RationCardScreen({required this.nextScreen});

  final TextEditingController _rationCardController = TextEditingController();

  void _validateAndProceed(BuildContext context) async {
    final rationCardNo = _rationCardController.text.trim();

    if (rationCardNo.isEmpty) {
      _showMessage(context, 'કૃપા કરીને રેશન કાર્ડ નંબર દાખલ કરો');
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('farmer_details')
          .where('rationCard', isEqualTo: rationCardNo)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => nextScreen(rationCardNo),
          ),
        );
      } else {
        _showMessage(context, 'રેશન કાર્ડ મળ્યું નથી. કૃપા કરીને સાચો નંબર નાખો.');
      }
    } catch (e) {
      _showMessage(context, 'કંઈક ભૂલ થઈ. ફરી પ્રયાસ કરો.');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(fontSize: 16))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('રેશન કાર્ડ નંબર દાખલ કરો', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _rationCardController,
              decoration: InputDecoration(
                labelText: 'રેશન કાર્ડ નંબર',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _validateAndProceed(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('આગળ વધો', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
