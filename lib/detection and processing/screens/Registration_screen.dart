import 'package:flutter/material.dart';
import 'package:speciesdectection/detection%20and%20processing/Service/UserAuthService.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';  // Import LoginPage

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobilenumberController = TextEditingController();
  bool showPass = true;
  bool showConfirmPass = true;
  bool isLoading = false; // Flag for loading state
  final _formKey = GlobalKey<FormState>();

  void Signuphandler()async{
      {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() {
                                isLoading = true; // Start loading
                              });

                              // Call registration service
                              await UserAuthService().UserRegister(
                                name: nameController.text,
                                email: emailController.text,
                                mobile: mobilenumberController.text,
                                password: passwordController.text,
                                context: context,
                              );

                              setState(() {
                                isLoading = false; // Stop loading
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fix errors in the form'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    mobilenumberController.dispose();
    super.dispose();
  }

  Widget customTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      IconButton? suffixIcon,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
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
            colors: [Colors.lightBlue.shade50, Colors.blue.shade100],
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

                  // Name TextField
                  customTextField(
                    nameController,
                    'Enter your name',
                    Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

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

                  // Mobile Number TextField
                  customTextField(
                    mobilenumberController,
                    'Mobile',
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length != 10) {
                        return 'Enter a valid 10-digit number';
                      }
                      return null;
                    },
                  ),

                  // Password TextField
                  customTextField(
                    passwordController,
                    'Password',
                    Icons.lock,
                    obscureText: showPass,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showPass = !showPass;
                        });
                      },
                      icon: Icon(
                          showPass ? Icons.visibility : Icons.visibility_off),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),

                  // Confirm Password TextField
                  customTextField(
                    confirmPasswordController,
                    'Confirm Password',
                    Icons.lock,
                    obscureText: showConfirmPass,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          showConfirmPass = !showConfirmPass;
                        });
                      },
                      icon: Icon(showConfirmPass
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Sign Up Button or Loading Indicator
                  isLoading
                      ? const CircularProgressIndicator() // Show loading spinner
                      : OutlinedButton(
                          onPressed: Signuphandler,
                          child: const Text('Sign Up'),
                        ),

                  // Login Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the Login page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
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
