import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Helper to get current user ID dynamically
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. Get all items (Real-time Stream)
  Stream<List<ItemModel>> getActiveItems() {
    return _db
        .collection('items')
        .orderBy('createdAt', descending: true) // Newest first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemModel.fromFirestore(doc))
            .toList());
  }

  // 2. Add a new Lost/Found Item
  Future<void> addItem(ItemModel item) async {
    await _db.collection('items').add(item.toMap());
  }

  // 3. --- PROFILE MANAGEMENT (Fixes your error) ---
  
  // Get User Data (Used by Profile Screen StreamBuilder)
  Stream<DocumentSnapshot> getUserData(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  // Update User Profile Data (When user edits their profile)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(
      data, 
      SetOptions(merge: true), // Merges with existing data so we don't overwrite everything
    );
  }

  // 4. --- CLAIM & ITEM ACTIONS ---

  // Update Claim Status
  Future<void> updateClaimStatus(String itemId, String claimId, String newStatus) async {
    await _db
        .collection('items')
        .doc(itemId)
        .collection('claims')
        .doc(claimId)
        .update({'status': newStatus});
  }

  // Delete Item
  Future<void> deleteItem(String itemId) async {
    await _db.collection('items').doc(itemId).delete();
  }

  // Update Item Status (Active, Claimed, Returned)
  Future<void> updateItemStatus(String itemId, String status) async {
    await _db.collection('items').doc(itemId).update({'status': status});
  }
}