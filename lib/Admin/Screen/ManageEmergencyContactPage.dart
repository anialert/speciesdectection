import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageEmergencyContactPage extends StatefulWidget {
  const ManageEmergencyContactPage({super.key});

  @override
  _ManageEmergencyContactPageState createState() =>
      _ManageEmergencyContactPageState();
}

class _ManageEmergencyContactPageState
    extends State<ManageEmergencyContactPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  // Fetch contacts from Firestore
  Future<List<Map<String, String>>> _getContacts() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('EmergencyContacts').get();
      return snapshot.docs
          .map((doc) => {
                'name': doc['name'] as String,
                'mobile': doc['mobile'] as String,
              })
          .toList();
    } catch (e) {
      print('Error fetching contacts: $e');
      return [];
    }
  }

  // Add a new contact to Firestore
  void _addContact(String name, String mobile) async {
    try {
      await _firestore.collection('EmergencyContacts').add({
        'name': name,
        'mobile': mobile,
      });
      setState(() {}); // Trigger a UI update
    } catch (e) {
      print('Error adding contact: $e');
    }
  }

  // Remove a contact from Firestore
  void _removeContact(String name, String mobile) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('EmergencyContacts')
          .where('name', isEqualTo: name)
          .where('mobile', isEqualTo: mobile)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {}); // Trigger a UI update
    } catch (e) {
      print('Error removing contact: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Emergency Contacts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
              ),
            ),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact Mobile',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = _nameController.text.trim();
                String mobile = _mobileController.text.trim();
                if (name.isNotEmpty && mobile.isNotEmpty) {
                  _addContact(name, mobile);
                  _nameController.clear();
                  _mobileController.clear();
                }
              },
              child: const Text('Add Contact'),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Map<String, String>>>(
              future: _getContacts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error fetching contacts.'));
                }

                List<Map<String, String>> contacts = snapshot.data ?? [];

                return contacts.isEmpty
                    ? const Center(child: Text('No emergency contacts available'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(contacts[index]['name'] ?? ''),
                              subtitle: Text(contacts[index]['mobile'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeContact(
                                  contacts[index]['name']!,
                                  contacts[index]['mobile']!,
                                ),
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
    );
  }
}
