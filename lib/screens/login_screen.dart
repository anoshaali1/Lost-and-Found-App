import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_field.dart';
import 'register_screen.dart';
import 'main_screen.dart'; // Ensure this matches your actual navigation file name

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    if (email == "admin@campus.com" && password == "admin123") {
      setState(() => _isLoading = false);
      _navigateToMain(isAdmin: true);
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        _navigateToMain(isAdmin: false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      _showError(e.message ?? "Authentication failed");
    }
  }

  void _navigateToMain({required bool isAdmin}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(isAdmin: isAdmin),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFF64FFDA),
                child: Icon(Icons.search_sharp, size: 70, color: Colors.black),
              ),
            ),
            const SizedBox(height: 30),
            const Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text("Lost & Found", style: TextStyle(color: Color(0xFF64FFDA), fontSize: 26, fontWeight: FontWeight.w600)),
            const SizedBox(height: 40),
            CustomField(controller: _emailController, hint: "Email Address"),
            CustomField(controller: _passwordController, hint: "Password", isPassword: true),
            const SizedBox(height: 40), 
            _isLoading 
            ? const CircularProgressIndicator(color: Color(0xFF64FFDA))
            : SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64FFDA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: _handleLogin, 
                  child: const Text("LOGIN", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text("Don't have an account? Register", style: TextStyle(color: Color(0xFF64FFDA))),
            ),
          ],
        ),
      ),
    );
  }
}