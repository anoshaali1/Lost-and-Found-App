import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/item_model.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final bool isAdmin;
  final VoidCallback? onDelete;

  const ItemCard({
    super.key,
    required this.item,
    this.isAdmin = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    bool isOwner = item.ownerId == currentUserId;

    // Status Colors
    Color statusColor = item.status == 'active' ? const Color(0xFF64FFDA) : Colors.amber;
    if (item.status == 'returned') statusColor = Colors.green;

    return InkWell(
      onTap: () => _showDetails(context),
      borderRadius: BorderRadius.circular(15),
      child: Card(
        color: const Color(0xFF1E1E1E), // Dark card background
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE SECTION WITH OVERLAY TYPE
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[850],
                  child: item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                      ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                      : const Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.type.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // 2. DETAILS SECTION
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- NEW CATEGORY BADGE ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64FFDA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF64FFDA), 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name, 
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF64FFDA)),
                      const SizedBox(width: 4),
                      Text(item.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),

                  const Divider(color: Colors.white12, height: 25),

                  // 3. FOOTER SECTION (Poster Name and Action Button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Color(0xFF64FFDA)),
                              const SizedBox(width: 4),
                              Text(
                                item.ownerName, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64FFDA))
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('MMM d, yyyy').format(item.createdAt),
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),

                      // Button / Status logic
                      if (isOwner)
                        const Text("MY POST", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))
                      else if (item.status == 'returned')
                        const Text("RETURNED", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
                      else if (item.status == 'claimed')
                        const Text("CLAIMED", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12))
                      else if (!isAdmin)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64FFDA),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _showClaimDialog(context),
                          child: const Text("CLAIM", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- POPUP DETAIL VIEW ---
  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF64FFDA)),
            const SizedBox(width: 10),
            Expanded(child: Text(item.name, style: const TextStyle(color: Colors.white))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.imagePath.isNotEmpty && File(item.imagePath).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(item.imagePath), height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 15),
              _infoTile("Category", item.category),
              _infoTile("Posted By", item.ownerName),
              _infoTile("Color/Brand", item.colorBrand),
              _infoTile("Reg No", item.regNo),
              _infoTile("Department", "${item.department} (${item.semester})"),
              _infoTile("Location", item.location),
              const Divider(color: Colors.white24, height: 25),
              const Text("ADDITIONAL DETAILS", style: TextStyle(color: Color(0xFF64FFDA), fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(item.details.isEmpty ? "No specific details provided." : item.details, 
                   style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 15),
              _infoTile("Contact Info", item.contact),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE", style: TextStyle(color: Colors.grey)),
          ),
          if (FirebaseAuth.instance.currentUser?.uid != item.ownerId && item.status == 'active')
             ElevatedButton(
               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF64FFDA)),
               onPressed: () {
                 Navigator.pop(context);
                 _showClaimDialog(context);
               }, 
               child: const Text("CLAIM NOW", style: TextStyle(color: Colors.black)),
             )
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // --- CLAIM DIALOG ---
  void _showClaimDialog(BuildContext context) {
    final proofController = TextEditingController();
    final contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Claim Item", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: contactController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "Your Contact Number", 
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: proofController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Proof (e.g., I have the key to this bag)", 
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF64FFDA), foregroundColor: Colors.black),
            onPressed: () async {
              if (contactController.text.isEmpty || proofController.text.isEmpty) return;
              
              final batch = FirebaseFirestore.instance.batch();
              final claimRef = FirebaseFirestore.instance.collection('items').doc(item.id).collection('claims').doc();

              batch.set(claimRef, {
                'claimantId': FirebaseAuth.instance.currentUser!.uid,
                'claimantName': FirebaseAuth.instance.currentUser!.displayName ?? "User",
                'contact': contactController.text.trim(),
                'proof': proofController.text.trim(),
                'status': 'pending',
                'timestamp': FieldValue.serverTimestamp(),
              });

              batch.update(FirebaseFirestore.instance.collection('items').doc(item.id), {'status': 'claimed'});

              await batch.commit();
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Claim request sent!"))
              );
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}