import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speciesdectection/Admin/Screen/Admin_home.dart';
import 'package:speciesdectection/detection%20and%20processing/Service/UserAuthService.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Forgotpassword.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Homepage.dart'; // User home page
import 'package:speciesdectection/detection%20and%20processing/screens/Registration_screen.dart'; // Signup page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = true;
  bool isLoading = false; // Flag for loading state
  final _formKey = GlobalKey<FormState>();

  void loginHandler() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true; // Start loading
      });

      try {
        // Authenticate user
        bool loginSuccess = await UserAuthService().userLogin(
          email: emailController.text.trim(),
          password: passwordController.text,
          context: context,
        );

        if(emailController.text == 'admin@gmail.com' ){

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminHome(),
              ),
            );
          

          

        }

        if (loginSuccess) {
          // Get authenticated user's email
          String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

          // Check Firestore collections
          bool isAdmin = await checkAdminCollection(userEmail);
          bool isUser = await checkUserCollection(userEmail);

          if (isAdmin) {
            // Navigate to Admin Homepage
            prefs.setString('user_role', 'admin');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminHome(),
              ),
            );
          } else if (isUser) {
            prefs.setString('user_role', 'user'); // Navigate to User Homepage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Homepage(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("User not found in any collection."),
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
          ),
        );
      }

      setState(() {
        isLoading = false; // Stop loading
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix errors in the form'),
        ),
      );
    }
  }

  // Check if user exists in Admin collection
  Future<bool> checkAdminCollection(String email) async {
    try {
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('email', isEqualTo: email)
          .get();

      return adminSnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking Admin collection: $e");
      return false;
    }
  }

  // Check if user exists in Users collection
  Future<bool> checkUserCollection(String email) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      return userSnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint("Error checking Users collection: $e");
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Custom text field for the login form
  Widget customTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    IconButton? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              const Color.fromARGB(255, 249, 219, 144),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular logo image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('asset/images/logo.jpeg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email TextField
                  customTextField(
                    emailController,
                    'Email',
                    Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  // Password TextField with visibility toggle
                  customTextField(
                    passwordController,
                    'Password',
                    Icons.lock,
                    obscureText: showPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      icon: Icon(showPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPasswordPage()));
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                            color: Color.fromARGB(190, 119, 44, 126)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button or Loading Indicator
                  isLoading
                      ? const CircularProgressIndicator() // Show loading spinner
                      : OutlinedButton(
                          onPressed: loginHandler,
                          child: const Text('Login'),
                        ),
                  const SizedBox(height: 10),

                  // Sign Up Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the Signup page
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Signup(),
                            ),
                          );
                        },
                        child: const Text(
                          "Signup",
                          style: TextStyle(
                            color: Color.fromARGB(204, 24, 5, 78),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
