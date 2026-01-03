import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';

class ItemDetailsScreen extends StatelessWidget {
  final ItemModel item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isOwner = item.ownerId == FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Item Details", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF64FFDA)),
              onPressed: () {
                debugPrint("Edit pressed for item: ${item.id}");
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE DISPLAY
            Hero(
              tag: item.id ?? 'item_image',
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[900],
                ),
                child: item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(File(item.imagePath), fit: BoxFit.cover),
                      )
                    : const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 25),

            // 2. MAIN INFO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("${item.type.toUpperCase()} • ${item.category}", 
                        style: const TextStyle(color: Color(0xFF64FFDA), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                _buildStatusBadge(item.status),
              ],
            ),
            const Divider(height: 40, color: Colors.white12),

            // 3. DETAILED METADATA
            _buildDetailRow(Icons.branding_watermark, "Brand/Color", item.colorBrand),
            _buildDetailRow(Icons.location_on, "Last Seen/Found", item.location),
            _buildDetailRow(Icons.person, "Posted By", item.ownerName),
            _buildDetailRow(Icons.school, "Department", item.department),
            _buildDetailRow(Icons.timer, "Semester", item.semester),
            _buildDetailRow(Icons.calendar_month, "Date Posted", DateFormat('MMM d, yyyy').format(item.createdAt)),

            const SizedBox(height: 30),
            
            // 4. CONDITIONAL BUTTONS
            if (isOwner && item.status == 'claimed')
               _buildOwnerNotice("This item has a pending claim. Check your Home Screen for review.")
            else if (isOwner)
               _buildOwnerNotice("You posted this item.")
            else if (item.status == 'returned')
               _buildLockedButton("ITEM RETURNED", Icons.check_circle, Colors.green)
            else if (item.status == 'claimed')
               _buildLockedButton("ALREADY CLAIMED", Icons.lock, Colors.orange)
            else
              _buildClaimButton(context),
          ],
        ),
      ),
    );
  }

  // --- Helper UI Widgets ---

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'active') color = const Color(0xFF64FFDA);
    if (status == 'claimed') color = Colors.orange;
    if (status == 'returned') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5))
      ),
      child: Text(status.toUpperCase(), 
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildOwnerNotice(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildLockedButton(String label, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildClaimButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF64FFDA),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => _showClaimDialog(context),
        icon: const Icon(Icons.verified_user),
        label: const Text("PROVE OWNERSHIP & CLAIM", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // --- Claim Logic ---

  void _showClaimDialog(BuildContext context) {
    final proofController = TextEditingController();
    final contactController = TextEditingController(); // Added for logic
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Claim Item", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Submit your contact info and unique proof. The owner will review this.", 
                style: TextStyle(color: Colors.grey, fontSize: 13)
              ),
              const SizedBox(height: 15),
              TextField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Your Contact Number",
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: proofController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter your proof here...",
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF64FFDA)),
            onPressed: () async {
              final String proofText = proofController.text.trim();
              final String contactText = contactController.text.trim();
              
              if (proofText.isEmpty || contactText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields"))
                );
                return;
              }

              try {
                final batch = FirebaseFirestore.instance.batch();
                
                DocumentReference claimRef = FirebaseFirestore.instance
                    .collection('items')
                    .doc(item.id)
                    .collection('claims')
                    .doc();

                batch.set(claimRef, {
                  'claimantId': FirebaseAuth.instance.currentUser!.uid,
                  'claimantName': FirebaseAuth.instance.currentUser!.email ?? "Student",
                  'contact': contactText,
                  'proof': proofText,
                  'status': 'pending',
                  'timestamp': FieldValue.serverTimestamp(),
                  'itemId': item.id,
                  'itemName': item.name,
                });

                batch.update(FirebaseFirestore.instance.collection('items').doc(item.id), {
                  'status': 'claimed',
                });

                await batch.commit();
                
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to home to refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Claim submitted successfully!")),
                  );
                }
              } catch (e) {
                debugPrint("ERROR: $e");
              }
            },
            child: const Text("Submit", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}