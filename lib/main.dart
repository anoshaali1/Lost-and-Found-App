import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation_screen.dart'; 
import 'screens/login_screen.dart'; 
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const LostAndFoundApp(),
    ),
  );
}

class LostAndFoundApp extends StatelessWidget {
  const LostAndFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Connect',
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      
      // Dark Theme Data...
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF64FFDA),
        useMaterial3: true,
      ),

      // Light Theme Data...
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.teal,
        useMaterial3: true,
      ),
      
      // --- THE LOGOUT ENGINE ---
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. If Firebase is still initializing the auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // 2. If user is logged in (snapshot has data)
          if (snapshot.hasData) {
            // This is where the user stays while using the app
            return const MainNavigationScreen();
          }

          // 3. If user is logged out (snapshot is null)
          // As soon as you call FirebaseAuth.instance.signOut() in HomeScreen,
          // this StreamBuilder detects it and instantly returns LoginScreen()
          return const LoginScreen();
        },
      ),
    );
  }
}