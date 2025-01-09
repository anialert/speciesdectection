import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminChatPage extends StatefulWidget {
  const AdminChatPage({super.key});

  @override
  _AdminChatPageState createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Chat'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('chats')
            .where('adminId', isEqualTo: 'admin') // Filter for chats involving the admin
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          var chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index];

              // Fetch the user's name using userId from the Users collection
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('Users').doc(chat['userId']).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading user data...'),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('User not found'),
                    );
                  }

                  var user = userSnapshot.data!;
                  var userName = user['name'] ?? 'Unknown User';

                  return ListTile(
                    title: Text('User: $userName'),
                    onTap: () {
                      // Navigate to individual chat with this user
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IndividualChatPage(
                            chatId: chat.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class IndividualChatPage extends StatefulWidget {
  final String chatId;  // The chat ID passed from the AdminChatPage

  const IndividualChatPage({super.key, required this.chatId});

  @override
  _IndividualChatPageState createState() => _IndividualChatPageState();
}

class _IndividualChatPageState extends State<IndividualChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to send a message
  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore.collection('chats').doc(widget.chatId).collection('messages').add({
        'sender': 'admin',  // admin is sending the message
        'senderId': 'admin',  // admin's ID
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  // Function to clear all messages in the chat
  Future<void> _clearChat() async {
    // Get all messages in the chat and delete them
    var messagesSnapshot = await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .get();

    // Delete each message
    for (var message in messagesSnapshot.docs) {
      await message.reference.delete();
    }

    // Optionally, you can show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat has been cleared!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with User'),
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
            child: StreamBuilder(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
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

                    return ListTile(
                      title: Text(
                          message['sender'] == 'admin'
                              ? 'Admin: ${message['message']}'
                              : 'User: ${message['message']}'),
                      subtitle: Text(message['timestamp']?.toDate().toString() ?? 'No Time'),
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
