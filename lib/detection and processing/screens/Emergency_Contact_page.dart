import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  const EmergencyContactPage({super.key});

  // Fetch emergency contacts from Firestore
  Future<List<Map<String, String>>> _getEmergencyContacts() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('EmergencyContacts').get();
      return snapshot.docs
          .map((doc) => {
                'name': doc['name'] as String,
                'phone': doc['mobile']
                    as String, // Assuming 'mobile' is stored as the phone number
              })
          .toList();
    } catch (e) {
      print('Error fetching contacts: $e');
      return [];
    }
  }

  /// Function to open the phone dialer
  Future<void> _openDialer(String phoneNumber) async {
    final Uri dialerUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(dialerUri)) {
      await launchUrl(dialerUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.redAccent.withOpacity(0.1),
              Colors.white.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<Map<String, String>>>(
          future: _getEmergencyContacts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching contacts.'));
            }

            List<Map<String, String>> contacts = snapshot.data ?? [];

            return contacts.isEmpty
                ? const Center(child: Text('No emergency contacts available.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.phone, color: Colors.green),
                          title: Text(
                            contacts[index]['name']!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Phone: ${contacts[index]['phone']}'),
                          trailing: const Icon(Icons.call, color: Colors.blue),
                          onTap: () {
                            _openDialer(contacts[index]['phone']!);
                          },
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}
