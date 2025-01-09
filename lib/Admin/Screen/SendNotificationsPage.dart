import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendNotificationsPage extends StatefulWidget {
  const SendNotificationsPage({super.key});

  @override
  _SendNotificationsPageState createState() => _SendNotificationsPageState();
}

class _SendNotificationsPageState extends State<SendNotificationsPage> {
  final TextEditingController _notificationController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  /// Send notification to all users
  Future<void> _sendNotification() async {
    final notificationContent = _notificationController.text.trim();
    if (notificationContent.isEmpty) {
      _showErrorDialog('Please enter notification content');
      return;
    }

    try {
      // Send notification to all users
      await _firestore.collection('Notifications').add({
        'content': notificationContent,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': null, // Null indicates notification for all users
      });

      // Show success dialog
      _showSuccessDialog('Notification sent to all users!');
    } catch (e) {
      _showErrorDialog('Error sending notification: $e');
    }
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _notificationController.clear(); // Clear text field
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _notificationController,
              decoration: const InputDecoration(
                labelText: 'Enter Notification Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: const Text('Send Notification to All Users'),
            ),
          ],
        ),
      ),
    );
  }
}
