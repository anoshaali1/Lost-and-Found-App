import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';
import '../widgets/item_card.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("My Reported Items", 
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64FFDA))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .where('ownerId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF64FFDA)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("You haven't reported any items yet.", 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final myItems = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myItems.length,
            itemBuilder: (context, index) {
              final item = ItemModel.fromFirestore(myItems[index]);

              return Column(
                children: [
                  ItemCard(
                    item: item,
                    isAdmin: true,
                    onDelete: () => _deletePost(context, item.id!, item.imagePath),
                  ),
                  // Show the Review button only if someone has claimed it
                  if (item.status == 'claimed')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 5),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showClaimsReview(context, item.id!),
                        icon: const Icon(Icons.rate_review, color: Colors.black),
                        label: const Text("REVIEW CLAIM REQUESTS", 
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // --- LOGIC: REVIEWING CLAIMS ---
  void _showClaimsReview(BuildContext context, String itemId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('items').doc(itemId).collection('claims').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const LinearProgressIndicator();
          
          final claims = snap.data!.docs;
          if (claims.isEmpty) return const Center(child: Text("No claims found.", style: TextStyle(color: Colors.white)));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text("Claim Requests", style: TextStyle(color: Color(0xFF64FFDA), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ...claims.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(data['claimantName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("Proof: ${data['proof']}", style: const TextStyle(color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _updateClaim(context, itemId, doc.id, 'approved')),
                        IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => _updateClaim(context, itemId, doc.id, 'rejected')),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _updateClaim(BuildContext context, String itemId, String claimId, String status) async {
    final batch = FirebaseFirestore.instance.batch();
    
    // 1. Update the specific claim status
    batch.update(FirebaseFirestore.instance.collection('items').doc(itemId).collection('claims').doc(claimId), {'status': status});
    
    // 2. Update the main item status
    if (status == 'approved') {
      batch.update(FirebaseFirestore.instance.collection('items').doc(itemId), {'status': 'returned'});
    } else {
      batch.update(FirebaseFirestore.instance.collection('items').doc(itemId), {'status': 'active'});
    }
    
    await batch.commit();
    if (context.mounted) Navigator.pop(context);
  }

  // --- LOGIC: DELETING POSTS ---
  void _deletePost(BuildContext context, String docId, String localImagePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Remove Post?", style: TextStyle(color: Colors.white)),
        content: const Text("This will permanently remove your report from the campus feed.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('items').doc(docId).delete();
              try {
                final file = File(localImagePath);
                if (await file.exists()) await file.delete();
              } catch (e) {
                debugPrint("Local file cleanup skipped: $e");
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}