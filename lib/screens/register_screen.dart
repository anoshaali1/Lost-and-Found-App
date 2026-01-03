import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers to capture user input
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  
  bool _isLoading = false;

  /// Handles the Firebase Registration Process
  void _handleRegister() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passController.text.trim();

    // 1. Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    if (password.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. IMPORTANT: Update the user's profile with the Full Name
      // This is what allows 'item.ownerName' to show the real name later.
      await userCredential.user?.updateDisplayName(name);

      if (mounted) {
        setState(() => _isLoading = false);
        
        // 4. Success feedback and navigation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account Created! You can now login."), 
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to Login Screen
        Navigator.pop(context); 
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      _showError(e.message ?? "Registration failed");
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("An unexpected error occurred");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is destroyed
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF64FFDA),
              child: Icon(Icons.person_add, size: 50, color: Colors.black),
            ),
            const SizedBox(height: 20),
            const Text(
              "Join the Community", 
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Lost & Found", 
              style: TextStyle(color: Color(0xFF64FFDA), fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 30),
            
            // Input Fields
            CustomField(
              controller: nameController, 
              hint: "Full Name", 
              icon: Icons.person,
            ),
            const SizedBox(height: 15),
            CustomField(
              controller: emailController, 
              hint: "Email Address", 
              icon: Icons.email,
            ),
            const SizedBox(height: 15),
            CustomField(
              controller: passController, 
              hint: "Password", 
              icon: Icons.lock, 
              isPassword: true,
            ),
            
            const SizedBox(height: 40),
            
            // Registration Button / Loading Indicator
            _isLoading 
            ? const CircularProgressIndicator(color: Color(0xFF64FFDA))
            : SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64FFDA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  onPressed: _handleRegister, 
                  child: const Text(
                    "REGISTER", 
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}