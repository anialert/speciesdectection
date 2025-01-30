import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SafetyTipsListScreen extends StatelessWidget {
  const SafetyTipsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Tips List'),
        backgroundColor: const Color.fromARGB(255, 53, 185, 168), // Teal color
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('safety_tips')
            .orderBy('created_at', descending: true) // Optional: Sort by creation date
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final safetyTips = snapshot.data?.docs;

          if (safetyTips == null || safetyTips.isEmpty) {
            return const Center(
              child: Text('No safety tips available.'),
            );
          }

          return ListView.builder(
            itemCount: safetyTips.length,
            itemBuilder: (context, index) {
              var tip = safetyTips[index].data() as Map<String, dynamic>;
              return SafetyTipCard(
                title: tip['title'] ?? 'No title',
                description: tip['description'] ?? 'No description available.',
              );
            },
          );
        },
      ),
    );
  }
}

class SafetyTipCard extends StatelessWidget {
  final String title;
  final String description;

  const SafetyTipCard({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
