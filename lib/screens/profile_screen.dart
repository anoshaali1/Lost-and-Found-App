import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _regController = TextEditingController();
  final _bioController = TextEditingController();
  final _deptController = TextEditingController();
  final _semController = TextEditingController();

  void _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirestoreService().updateUserProfile(uid, {
        'name': _nameController.text,
        'regNo': _regController.text,
        'bio': _bioController.text,
        'department': _deptController.text,
        'semester': _semController.text,
      });
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated!"), backgroundColor: Color(0xFF64FFDA)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Manage Profile"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: const Color(0xFF64FFDA)),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirestoreService().getUserData(user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            // Sync controllers with cloud data only when not typing
            if (!_isEditing) {
              _nameController.text = data['name'] ?? '';
              _regController.text = data['regNo'] ?? '';
              _bioController.text = data['bio'] ?? '';
              _deptController.text = data['department'] ?? '';
              _semController.text = data['semester'] ?? '';
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF64FFDA),
                  child: Icon(Icons.person, size: 50, color: Colors.black),
                ),
                const SizedBox(height: 25),
                
                // Theme Toggle
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: themeProvider.isDark,
                  activeColor: const Color(0xFF64FFDA),
                  onChanged: (val) => themeProvider.toggleTheme(),
                ),
                const Divider(color: Colors.white10),

                // Editable Fields
                _buildEditableField("Full Name", _nameController, Icons.person),
                _buildEditableField("Registration No", _regController, Icons.badge),
                _buildEditableField("Department", _deptController, Icons.school),
                _buildEditableField("Semester/Section", _semController, Icons.class_),
                _buildEditableField("Bio", _bioController, Icons.edit_note, maxLines: 3),

                const SizedBox(height: 30),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context, rootNavigator: true).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen())
                    );
                  },
                  child: const Text("LOGOUT", style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        style: TextStyle(color: _isEditing ? const Color(0xFF64FFDA) : Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: _isEditing ? Colors.white.withOpacity(0.05) : Colors.transparent,
          border: _isEditing ? OutlineInputBorder(borderRadius: BorderRadius.circular(10)) : InputBorder.none,
        ),
      ),
    );
  }
}