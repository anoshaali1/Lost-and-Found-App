import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item_model.dart';
import '../widgets/item_card.dart';
import 'item_details_screen.dart';

// ... existing imports ...

class MyClaimsScreen extends StatelessWidget {
  const MyClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('My Claims', 
          style: TextStyle(color: Color(0xFF64FFDA), fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('claims')
            .where('claimantId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF64FFDA)));
          }
          
          if (snap.hasError) {
            // This print will show you the URL link to create the index!
            print("Firestore Error: ${snap.error}"); 
            return const Center(
              child: Text("Index needed. Check Debug Console for link.", 
                style: TextStyle(color: Colors.redAccent))
            );
          }

          final claimDocs = snap.data!.docs;
          if (claimDocs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No items claimed yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: claimDocs.length,
            itemBuilder: (context, index) {
              final claimData = claimDocs[index].data() as Map<String, dynamic>;
              
              // Fallback to parent path if itemId field is missing
              final String itemId = claimData['itemId'] ?? claimDocs[index].reference.parent.parent?.id ?? '';
              final itemRef = FirebaseFirestore.instance.collection('items').doc(itemId);

              return FutureBuilder<DocumentSnapshot>(
                future: itemRef.get(),
                builder: (context, itemSnap) {
                  if (!itemSnap.hasData || !itemSnap.data!.exists) return const SizedBox();

                  final item = ItemModel.fromFirestore(itemSnap.data!);
                  final claimStatus = claimData['status'] ?? 'pending';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Stack(
                      children: [
                        ItemCard(
                          item: item,
                          isAdmin: false,
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(claimStatus),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              claimStatus.toUpperCase(),
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.greenAccent;
      case 'returned': return Colors.greenAccent;
      case 'rejected': return Colors.redAccent;
      default: return const Color(0xFF64FFDA);
    }
  }
}