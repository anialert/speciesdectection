import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speciesdectection/Admin/Screen/Admin_home.dart';
import 'package:speciesdectection/detection%20and%20processing/Service/UserAuthService.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Forgotpassword.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Homepage.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Registration_screen.dart';

class LoginPage extends  StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool showPassword = true;

  bool isLoading = false; 
 // Flag for loading state
  final _formKey = GlobalKey<FormState>();


  void loginHandler() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (_formKey.currentState?.validate() ?? false) {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      // Get the phone number entered by the user
      String phone = phoneController.text.trim();

      // First, check if the phone number exists in the Admin or Users collections
      bool isAdmin = await checkAdminCollection(phone);
      bool isUser = await checkUserCollection(phone);

      print(isUser);
      print(isAdmin);

      if (isAdmin) {
        // User is an admin
        prefs.setString('user_role', 'admin');
        
        // Get the user's email from Firestore
        String adminEmail = await getEmailForPhone(phone, 'Admin');
        
        // Authenticate user with email and password
        bool loginSuccess = await UserAuthService().userLogin(
          email: adminEmail, // Use the email of the admin to log in
          password: passwordController.text,
          context: context,
        );
        print(loginSuccess);

        if (loginSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminHome(),
            ),
          );
        }
      } else if (isUser) {
        // User is a regular user
        prefs.setString('user_role', 'user');
        
        // Get the user's email from Firestore
        String userEmail = await getEmailForPhone(phone, 'Users',true);
        print(userEmail);
        
        // Authenticate user with email and password
        bool loginSuccess = await UserAuthService().userLogin(
          email: userEmail, // Use the email of the user to log in
          password: passwordController.text,
          context: context,
        );

        if (loginSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Homepage(),
            ),
          );
        }
      } else {
        // User does not exist in either collection
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not found in any collection."),
          ),
        );
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

// Check if phone number exists in Admin collection
Future<bool> checkAdminCollection(String phone) async {
  try {
    final adminSnapshot = await FirebaseFirestore.instance
        .collection('Admin')
        .where('phone', isEqualTo: phone)
        .get();

    return adminSnapshot.docs.isNotEmpty;
  } catch (e) {
    debugPrint("Error checking Admin collection: $e");
    return false;
  }
}

// Check if phone number exists in Users collection
Future<bool> checkUserCollection(String phone) async {
  try {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('mobile', isEqualTo: phone)
        .get();

    return userSnapshot.docs.isNotEmpty;
  } catch (e) {
    debugPrint("Error checking Users collection: $e");
    return false;
  }
}

// Fetch the email associated with the phone number from Firestore (for Admin or Users)
Future<String> getEmailForPhone(String phone, String collection,[bool isUser=false]) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where( isUser ? 'mobile' :'phone', isEqualTo: phone)
        .get();
        print(snapshot.docs.first['email']);

    if (snapshot.docs.isNotEmpty) {
      // Assuming each document has an 'email' field
      return snapshot.docs.first['email'] ?? '';
    }
    return '';
  } catch (e) {
    debugPrint("Error fetching email: $e");
    return '';
  }
}



  @override
  void dispose() {
    phoneController.dispose();
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

                  // Phone Number TextField
                  customTextField(
                    phoneController,
                    'Phone Number',
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length != 10) {
                        return 'Please enter a valid phone number';
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
