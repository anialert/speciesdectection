import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewFeedbackPage extends StatelessWidget {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

   ViewFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Feedback'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          // Fetch feedback data from Firestore's Feedbacks collection
          stream: _firestore
              .collection('Feedbacks')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No feedback available.'));
            }

            // Get the list of feedback documents
            var feedbacks = snapshot.data!.docs;

            return ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                var feedback = feedbacks[index];
                var userEmail = feedback['user_email'] ?? 'Unknown User';
                var rating = feedback['rating'] ?? 0;
                var feedbackText =
                    feedback['feedback'] ?? 'No feedback provided';
                var timestamp =
                    feedback['timestamp']?.toDate() ?? DateTime.now();

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(userEmail),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rating: $rating stars'),
                        const SizedBox(height: 4),
                        Text(feedbackText),
                        const SizedBox(height: 4),
                        Text('Submitted on: ${timestamp.toLocal()}'),
                      ],
                    ),
                    isThreeLine: true,
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
