import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Import the intl package for DateFormat

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  String? chatId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  // Initialize chat (create or get existing chat)
  Future<void> _initializeChat() async {
    User? user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;
      // Create a chatId based on userId and predefined adminId
      chatId = '$userId' '_admin'; // You can modify this to customize chatId

      var chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        // Create a new chat document if none exists
        await _firestore.collection('chats').doc(chatId).set({
          'userId': userId,
          'adminId': 'admin',  // admin ID can be predefined or dynamic
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Send a message
  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'sender': 'user',
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  // Function to clear chat
  Future<void> _clearChat() async {
    // Get all messages in the chat and delete them
    var messagesSnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    // Delete each message
    for (var message in messagesSnapshot.docs) {
      await message.reference.delete();
    }

    // Optionally, show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat has been cleared!')));
  }

  // Format timestamp, handle null case
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp != null) {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate());
    } else {
      return 'No Time';  // Return a default message if timestamp is null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Admin'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearChat,
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                var messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    String sender = message['sender'] == 'user' ? 'You' : 'Admin';
                    return ListTile(
                      title: Text('$sender: ${message['message']}'),
                      subtitle: Text(formatTimestamp(message['timestamp']) ?? 'No Time'),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
