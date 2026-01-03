import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'my_posts_screen.dart';
import 'my_claims_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';
import 'add_item_screen.dart';

class MainScreen extends StatefulWidget {
  final bool isAdmin; // Added to distinguish between Admin and User

  const MainScreen({super.key, required this.isAdmin});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Use a getter to pass the isAdmin state to the HomeScreen
  List<Widget> get _screens => [
        HomeScreen(isAdmin: widget.isAdmin), // Pass the role here
        const MyPostsScreen(),
        const MyClaimsScreen(),
        const AboutScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: const Color(0xFF64FFDA), 
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.post_add_outlined),
              activeIcon: Icon(Icons.post_add),
              label: 'My Posts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_outlined),
              activeIcon: Icon(Icons.assignment_turned_in),
              label: 'My Claims',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline),
              activeIcon: Icon(Icons.info),
              label: 'About',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      // FAB only appears for Users on the Home Tab. 
      // Admins usually manage via the list, but you can keep it if admins also post.
      floatingActionButton: _currentIndex == 0 
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF64FFDA),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.add, color: Colors.black, size: 32),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddItemScreen()),
                );
              },
            )
          : null,
    );
  }
}