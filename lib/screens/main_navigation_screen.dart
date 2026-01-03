import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_item_screen.dart';
import 'my_posts_screen.dart';
import 'my_claims_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // 1. Updated list to match Web Design (Profile added, Report removed from here)
  final List<Widget> _pages = [
    const HomeScreen(),      // Index 0
    const MyPostsScreen(),    // Index 1
    const MyClaimsScreen(),   // Index 2
    const AboutScreen(),      // Index 3
    const ProfileScreen(),    // Index 4 (Make sure to import your profile screen file!)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // 2. Add the "Report" button as a Floating Action Button (Web style)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF64FFDA),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1E1E1E) 
            : Colors.white,
        selectedItemColor: const Color(0xFF64FFDA),
        unselectedItemColor: Colors.grey,
        // 3. Updated items to match your Web Screenshot exactly
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "My Posts"),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check), label: "My Claims"),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: "About"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}