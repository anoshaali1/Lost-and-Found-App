import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'main_screen.dart'; // Change this from home_screen.dart to main_screen.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    // 1. Wait for 2 seconds to show the logo
    await Future.delayed(const Duration(seconds: 2));
    
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      // 2. No user logged in -> Go to Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // 3. User is logged in -> Check if it's the Admin
      // Hardcoded check to match your requirements
      bool isAdmin = user.email == "admin@campus.com";

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // We go to MainScreen (which contains the bottom nav) NOT HomeScreen
          builder: (_) => MainScreen(isAdmin: isAdmin),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Match the background to your theme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF64FFDA),
              child: Icon(Icons.search_sharp, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text(
              'CAMPUS CONNECT',
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Text(
              'Lost & Found Portal',
              style: TextStyle(color: Color(0xFF64FFDA), letterSpacing: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}