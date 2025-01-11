import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Emergency_Contact_page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Feedbac_page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/Noticationpage.dart';
import 'package:speciesdectection/Admin/Screen/Upload_Video_Page.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/UserChat.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/login_screen.dart';
import 'package:speciesdectection/detection%20and%20processing/screens/profile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isAlertEnabled = false; // State to track alert toggle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
        backgroundColor: const Color.fromARGB(255, 201, 167, 105),
        actions: [
          // Alert Toggle Switch
          Row(
            children: [
              const Text(
                "Alert",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: isAlertEnabled,
                onChanged: (value) {
                  setState(() {
                    isAlertEnabled = value;
                  });
                  if (isAlertEnabled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alert Enabled')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alert Disabled')),
                    );
                  }
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
              ),
            ],
          ),
         
        ],
      ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong!'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User data not found.'));
            }

            var userData = snapshot.data!;
            String name = userData['name'] ?? 'Anonymous';
            String email = userData['email'] ?? 'No email available';

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade100, Colors.orange.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            AssetImage('asset/images/profile_image.png'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        email,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    try {
                      await FirebaseFirestore.instance
                          .collection('playerId')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .delete();
                      await FirebaseAuth.instance.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out')),
                      );
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                      );
                    } catch (e) {
                      print("Error logging out: $e");
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 105, 180, 185),
              Color.fromARGB(255, 106, 160, 161)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Image.asset(
              'asset/images/logo.jpeg',
              width: MediaQuery.of(context).size.width,
              height: 250,
              fit: BoxFit.fitWidth,
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return buildFeatureBox(
                        context,
                        'Safety Tips',
                        Icons.info_outline,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Scaffold())),
                      );
                    case 1:
                      return buildFeatureBox(
                        context,
                        'Emergency Contact',
                        Icons.phone_in_talk,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmergencyContactPage())),
                      );
                    case 2:
                      return buildFeatureBox(
                        context,
                        'Feedback',
                        Icons.feedback,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FeedbackPage())),
                      );
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeatureBox(
      BuildContext context, String title, IconData icon, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: const Color.fromARGB(255, 123, 206, 218), size: 45),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
