import 'package:flutter/material.dart';
import 'RemoveUser.dart'; // Assuming you have this file

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  // Set to false so only the Remove User section is visible
  bool _isAddingUser = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // You can remove the Row with toggle buttons entirely since we're only showing the Remove User page
              const SizedBox(height: 20),
              // AnimatedSwitcher is still used, but it will only display RemoveUserPage now
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: const RemoveUserPage(), // Only show Remove User page
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
