import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  _ApiScreenState createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  String apiValue = "";
  final TextEditingController _controller = TextEditingController();
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  @override
  void initState() {
    super.initState();
    fetchApiValue();
  }

  Future<void> fetchApiValue() async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('Admin').doc(uid).get();
      setState(() {
        apiValue = doc['api'] ?? '';
        _controller.text = apiValue;
      });
    } catch (e) {
      print('Error fetching API value: $e');
    }
  }

  Future<void> updateApiValue() async {
    try {
      await FirebaseFirestore.instance
          .collection('Admin')
          .doc(uid)
          .update({'api': _controller.text});
      setState(() {
        apiValue = _controller.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API value updated successfully!')));
    } catch (e) {
      print('Error updating API value: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to update API value.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Current API Value:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(apiValue,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Edit API Value'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateApiValue,
              child: const Text('Update API'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context); // Pass context to the Navigator.pop method
              },
              child: const Text('Go Back'), // Add a child widget like Text or Icon
            )
          ],
        ),
      ),
    );
  }
}
