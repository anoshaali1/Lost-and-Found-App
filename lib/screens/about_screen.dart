import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. STYLIZED HEADER
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF64FFDA), Color(0xFF1DE9B6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_sharp, size: 70, color: Colors.black),
                  SizedBox(height: 10),
                  Text(
                    "CAMPUS CONNECT",
                    style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  Text(
                    "Safety • Integrity • Community",
                    style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // 2. INFORMATION TILES
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _aboutTile(
                    Icons.info_outline, 
                    "Our Purpose", 
                    "To create a trustworthy ecosystem where students can help each other recover lost items through transparency and verification."
                  ),
                  _aboutTile(
                    Icons.account_balance_outlined, 
                    "Admin Block Policy", 
                    "Items not claimed within 48 hours should be deposited at the Student Affairs Office (Admin Block). This ensures safe custody and official handover."
                  ),
                  _aboutTile(
                    Icons.verified_user_outlined, 
                    "Claiming Rules", 
                    "Proof of ownership is mandatory. Be prepared to describe internal contents, serial numbers, or unique marks. False claims are strictly prohibited."
                  ),
                  _aboutTile(
                    Icons.gpp_good_outlined, 
                    "Safety Advice", 
                    "Always meet in high-traffic public areas (Cafeteria, Library, or Main Plaza). We recommend checking the student ID of the person you are meeting."
                  ),
                  
                  const Divider(height: 40, color: Colors.white12),

                  // 3. ACTIONS
                  Center(
                    child: Column(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Logic to open email or support link
                          },
                          icon: const Icon(Icons.mail_outline, color: Color(0xFF64FFDA)),
                          label: const Text("Contact App Support", style: TextStyle(color: Color(0xFF64FFDA))),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Version 1.0.0", 
                          style: TextStyle(color: Colors.grey, fontSize: 11)
                        ),
                        const SizedBox(height: 20),
                        
                        // LOGOUT BUTTON
                        SizedBox(
                          width: 150,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              // Navigate back to login
                            },
                            child: const Text("LOGOUT", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutTile(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF64FFDA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF64FFDA), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.grey, height: 1.4, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }
}