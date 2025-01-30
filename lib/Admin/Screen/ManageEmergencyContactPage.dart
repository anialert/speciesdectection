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
      appBar: AppBar(
        title: const Text('Manage Emergency Contacts'),
        backgroundColor: Colors.teal, // Teal color for AppBar
        elevation: 4.0, // AppBar with subtle elevation
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  labelStyle: TextStyle(color: Colors.teal.shade700),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contact Mobile',
                  labelStyle: TextStyle(color: Colors.teal.shade700),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  
                  
                  onPressed: () {
                    String name = _nameController.text.trim();
                    String mobile = _mobileController.text.trim();
                    if (name.isNotEmpty && mobile.isNotEmpty) {
                      _addContact(name, mobile);
                      _nameController.clear();
                      _mobileController.clear();
                    }
                  },
                  child:  Text('Add Contact',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    
                    backgroundColor: Colors.teal, // Teal button color
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5, // Elevated button with shadow
                  ),
                ),
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
                      : Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    contacts[index]['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                  subtitle: Text(contacts[index]['mobile'] ?? ''),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeContact(
                                      contacts[index]['name']!,
                                      contacts[index]['mobile']!,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
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
