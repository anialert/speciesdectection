import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddNotify extends StatefulWidget {
  const AddNotify({super.key});

  @override
  State<AddNotify> createState() => _AddNotifyState();
}

class _AddNotifyState extends State<AddNotify> {


    Future<void> sendNotificationToDevice(String title, String body) async {
    const String oneSignalRestApiKey =
        'os_v2_app_qnfp25fs7jdw7d2kxmxoty6obib3wkxaka7ebg5od5ggnt43n5khuzh4rci2pgvwfxjhfeqdugox2mh4ermkwjsjzomwx2xzhjwlyzi';
    const String oneSignalAppId = '834afd74-b2fa-476f-8f4a-bb2ee9e3ce0a';

    var status = await FirebaseFirestore.instance.collection('playerId').get();

    var snapshot =
        await FirebaseFirestore.instance.collection('playerId').get();

    List<String> playerIds =
        []; // Loop through each document and extract the 'onId' field
    for (var doc in snapshot.docs) {
      if (doc.data().containsKey('onId')) {
        playerIds.add(doc['onId']);
      }
    }
    var url = Uri.parse('https://api.onesignal.com/notifications?c=push');
    var notificationData = {
      "app_id": oneSignalAppId,
      "headings": {"en": title},
      "contents": {"en": body},
      "target_channel": "push",
      "include_player_ids": playerIds
    };
    print('hhhh');
    var headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $oneSignalRestApiKey",
    };
    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(notificationData),
      );
      print(response.body);
      if (response.statusCode == 200) {
        print("Notification Sent Successfully!");
        print(response.body);
      } else {
        print("Failed to send notification: ${response.statusCode}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: ElevatedButton(onPressed: () {
        
        
      }, child: Text('notify') ),
    );
  }
}