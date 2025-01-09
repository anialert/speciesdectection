import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:speciesdectection/Admin/Screen/Admin_home.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Homepage.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'package:speciesdectection/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OneSignal.initialize("834afd74-b2fa-476f-8f4a-bb2ee9e3ce0a");
  await OneSignal.Notifications.requestPermission(true);

  // Determine the initial screen dynamically
  final homeScreen = await determineHomeScreen();

  runApp(MyApp(home: homeScreen));
}

// Function to determine the home screen dynamically
Future<Widget> determineHomeScreen() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    try {
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('email', isEqualTo: user.email)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        return const AdminHome(); // Admin home screen
      } else {
        return const Homepage(); // User home screen
      }
    } catch (e) {
      print('Error checking admin role: $e');
      return const LoginPage(); // Fallback to login on error
    }
  } else {
    return const LoginPage(); // Login screen for unauthenticated users
  }
}

class MyApp extends StatelessWidget {
  final Widget home;

  const MyApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}
