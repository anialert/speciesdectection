import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  int _selectedStars = 0;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to send feedback to Firestore
  Future<void> _submitFeedback() async {
    final feedback = _feedbackController.text;

    if (feedback.isNotEmpty && _selectedStars > 0) {
      try {
        // Ensure user is logged in
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // If the user is not authenticated, show an error and return
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to submit feedback.')),
          );
          return;
        }

        // Get the current user's email
        String userEmail = user.email ?? 'Anonymous';

        // Creating a new feedback document in Firestore
        await _firestore.collection('Feedbacks').add({
          'rating': _selectedStars,
          'feedback': feedback,
          'user_email': userEmail, // Store the user's email in Firestore
          'timestamp':
              FieldValue.serverTimestamp(), // Automatically sets the timestamp
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );

        // Clear the feedback form after submission
        _feedbackController.clear();
        setState(() {
          _selectedStars = 0;
        });
      } catch (e) {
        // Show error message if submitting feedback fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    } else {
      // Show validation error message if feedback or rating is missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide both a star rating and feedback')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlueAccent.withOpacity(0.5),
              Colors.white.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We value your feedback!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _selectedStars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedStars = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Your Feedback',
                  hintText: 'Write your feedback here...',
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
