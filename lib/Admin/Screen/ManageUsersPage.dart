import 'package:flutter/material.dart';
import 'AddUser.dart';
import 'RemoveUser.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  bool _isAddingUser = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: Container(
        // Gradient background for the entire page
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 181, 202, 218),
              Color.fromARGB(255, 208, 215, 214)
            ], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle buttons to switch between Add and Remove User pages
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isAddingUser = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isAddingUser ? Colors.blue : Colors.grey,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                    child: const Text(
                      'Add User',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isAddingUser = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isAddingUser ? Colors.blue : Colors.grey,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    ),
                    child: const Text(
                      'Remove User',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // AnimatedSwitcher for smooth transition between sections
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isAddingUser ? const AddUserPage() : const RemoveUserPage(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
