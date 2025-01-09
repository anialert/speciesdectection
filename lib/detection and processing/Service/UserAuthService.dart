import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';

class UserAuthService {
  final firebaseAuth = FirebaseAuth.instance;
  final firestoreDatabase = FirebaseFirestore.instance;

  // Register User
  Future<void> UserRegister({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final user = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await firestoreDatabase.collection("Users").doc(user.user?.uid).set({
        "name": name,
        "email": email,
        "mobile": mobile,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful")),
      );

      // Navigate to the LoginPage after successful sign-up
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: $e")),
      );
    }
  }

  // Login User
  Future<bool> userLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to sign in using Firebase Authentication
      final user = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final playerId = OneSignal.User.pushSubscription.id;

      await FirebaseFirestore.instance
          .collection('playerId')
          .doc(user.user!.uid)
          .set({'onId': playerId}); // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );

      return true; // Indicate login success
    } on FirebaseAuthException catch (e) {
      // Handle authentication errors
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return false; // Indicate login failure
    } catch (e) {
      // Handle any other errors that are not related to FirebaseAuth
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: $e')),
      );
      return false; // Indicate login failure
    }
  }
}
