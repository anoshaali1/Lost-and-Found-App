// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart';
// import '../providers/theme_provider.dart';
// import '../models/item_model.dart';
// import '../widgets/item_card.dart';

// class HomeScreen extends StatefulWidget {
//   final bool isAdmin;
//   const HomeScreen({super.key, this.isAdmin = false});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String searchQuery = "";
//   String selectedCategory = "All";
//   final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

//   // 1. LOGOUT DIALOG
//   void _logout() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1E1E1E),
//         title: const Text("Log Out", style: TextStyle(color: Colors.white)),
//         content: const Text("Are you sure you want to leave?", style: TextStyle(color: Colors.grey)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
//           ),
//           TextButton(
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               if (mounted) Navigator.pop(context);
//             },
//             child: const Text("Log Out", style: TextStyle(color: Colors.redAccent)),
//           ),
//         ],
//       ),
//     );
//   }

//   // 2. ADMIN HEADER WIDGET
//   Widget _buildAdminHeader() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFF64FFDA).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: const Text(
//         "ADMIN MODE: Management Access", 
//         style: TextStyle(color: Color(0xFF64FFDA), fontSize: 11, fontWeight: FontWeight.bold),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   // 3. OWNER REVIEW DIALOG (Accept/Reject Logic)
//   void _showOwnerReviewDialog(BuildContext context, ItemModel item) async {
//     var claimSnap = await FirebaseFirestore.instance
//         .collection('items').doc(item.id).collection('claims')
//         .where('status', isEqualTo: 'pending').get();

//     if (claimSnap.docs.isEmpty) return;
//     var claim = claimSnap.docs.first;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1E1E1E),
//         title: Text("Claim for ${item.name}", style: const TextStyle(color: Colors.white)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Claimant: ${claim['claimantName']}", style: const TextStyle(color: Colors.white70)),
//             Text("Contact: ${claim['contact']}", style: const TextStyle(color: Colors.white70)),
//             const SizedBox(height: 15),
//             const Text("Proof Provided:", style: TextStyle(color: Color(0xFF64FFDA), fontWeight: FontWeight.bold)),
//             Text(claim['proof'], style: const TextStyle(color: Colors.white)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               await FirebaseFirestore.instance.collection('items').doc(item.id).update({'status': 'active'});
//               await claim.reference.update({'status': 'rejected'});
//               Navigator.pop(context);
//             },
//             child: const Text("REJECT", style: TextStyle(color: Colors.redAccent)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF64FFDA)),
//             onPressed: () async {
//               await FirebaseFirestore.instance.collection('items').doc(item.id).update({'status': 'returned'});
//               await claim.reference.update({'status': 'accepted'});
//               Navigator.pop(context);
//             },
//             child: const Text("ACCEPT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   // 4. ADMIN DELETE CONFIRMATION
//   void _confirmDelete(String itemId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1E1E1E),
//         title: const Text("Delete Record?", style: TextStyle(color: Colors.white)),
//         content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.grey)),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           TextButton(
//             onPressed: () async {
//               await FirebaseFirestore.instance.collection('items').doc(itemId).delete();
//               Navigator.pop(context);
//             },
//             child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.logout, color: Colors.redAccent),
//           onPressed: _logout,
//         ),
//         title: Text(
//           widget.isAdmin ? "Admin Dashboard" : "Campus Connect",
//           style: TextStyle(
//             color: themeProvider.isDark ? Colors.white : Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               themeProvider.isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
//               color: const Color(0xFF64FFDA),
//             ),
//             onPressed: () => themeProvider.toggleTheme(),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // SEARCH BAR
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: TextField(
//               onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
//               style: TextStyle(color: themeProvider.isDark ? Colors.white : Colors.black),
//               decoration: InputDecoration(
//                 hintText: "Search item, brand, or location...",
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFF64FFDA)),
//                 filled: true,
//                 fillColor: themeProvider.isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(15),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ),

//           // FILTER CHIPS
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Row(
//               children: ["All", "Keys", "Books", "Electronics", "ID Cards", "Others"].map((cat) {
//                 bool isSelected = selectedCategory == cat;
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   child: FilterChip(
//                     selected: isSelected,
//                     label: Text(cat),
//                     onSelected: (s) => setState(() => selectedCategory = cat),
//                     selectedColor: const Color(0xFF64FFDA),
//                     labelStyle: TextStyle(
//                       color: isSelected ? Colors.black : (themeProvider.isDark ? Colors.white : Colors.black),
//                       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),

//           if (widget.isAdmin) _buildAdminHeader(),

//           // OWNER'S PENDING CLAIMS BOX
//           StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('items')
//                 .where('ownerId', isEqualTo: currentUserId)
//                 .where('status', isEqualTo: 'claimed')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();

//               return Container(
//                 margin: const EdgeInsets.all(16),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.amber.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: Colors.amber.withOpacity(0.5)),
//                 ),
//                 child: Column(
//                   children: snapshot.data!.docs.map((doc) {
//                     final item = ItemModel.fromFirestore(doc);
//                     return ListTile(
//                       contentPadding: EdgeInsets.zero,
//                       title: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//                       trailing: ElevatedButton(
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
//                         onPressed: () => _showOwnerReviewDialog(context, item),
//                         child: const Text("REVIEW", style: TextStyle(fontSize: 11)),
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               );
//             },
//           ),

//           // MAIN LIST VIEW
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('items')
//                   .orderBy('createdAt', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator(color: Color(0xFF64FFDA)));
//                 }

//                 final filteredItems = snapshot.data?.docs.map((d) => ItemModel.fromFirestore(d)).where((item) {
//                   final matchesSearch = item.name.toLowerCase().contains(searchQuery) ||
//                                        item.location.toLowerCase().contains(searchQuery);
//                   final matchesCategory = selectedCategory == "All" || item.category == selectedCategory;
//                   return matchesSearch && matchesCategory;
//                 }).toList() ?? [];

//                 if (filteredItems.isEmpty) return const Center(child: Text("No items found."));

//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: filteredItems.length,
//                   itemBuilder: (context, index) {
//                     final item = filteredItems[index];
//                     return ItemCard(
//                       item: item, 
//                       isAdmin: widget.isAdmin,
//                       onDelete: () => _confirmDelete(item.id!),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/item_model.dart';
import '../widgets/item_card.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  const HomeScreen({super.key, this.isAdmin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  // Kept currentUserId because it is needed for the "Owner's Pending Claims" StreamBuilder
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  // --- LOGOUT DIALOG REMOVED ---

  // 1. ADMIN HEADER WIDGET
  Widget _buildAdminHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF64FFDA).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "ADMIN MODE: Management Access", 
        style: TextStyle(color: Color(0xFF64FFDA), fontSize: 11, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  // 2. OWNER REVIEW DIALOG
  void _showOwnerReviewDialog(BuildContext context, ItemModel item) async {
    var claimSnap = await FirebaseFirestore.instance
        .collection('items').doc(item.id).collection('claims')
        .where('status', isEqualTo: 'pending').get();

    if (claimSnap.docs.isEmpty) return;
    var claim = claimSnap.docs.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text("Claim for ${item.name}", style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Claimant: ${claim['claimantName']}", style: const TextStyle(color: Colors.white70)),
            Text("Contact: ${claim['contact']}", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 15),
            const Text("Proof Provided:", style: TextStyle(color: Color(0xFF64FFDA), fontWeight: FontWeight.bold)),
            Text(claim['proof'], style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('items').doc(item.id).update({'status': 'active'});
              await claim.reference.update({'status': 'rejected'});
              Navigator.pop(context);
            },
            child: const Text("REJECT", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF64FFDA)),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('items').doc(item.id).update({'status': 'returned'});
              await claim.reference.update({'status': 'accepted'});
              Navigator.pop(context);
            },
            child: const Text("ACCEPT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 3. ADMIN DELETE CONFIRMATION
  void _confirmDelete(String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Delete Record?", style: TextStyle(color: Colors.white)),
        content: const Text("This action cannot be undone.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('items').doc(itemId).delete();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // LEADING (LOGOUT) ICON REMOVED
        title: Text(
          widget.isAdmin ? "Admin Dashboard" : "Campus Connect",
          style: TextStyle(
            color: themeProvider.isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
              color: const Color(0xFF64FFDA),
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
              style: TextStyle(color: themeProvider.isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Search item, brand, or location...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64FFDA)),
                filled: true,
                fillColor: themeProvider.isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: ["All", "Keys", "Books", "Electronics", "ID Cards", "Others"].map((cat) {
                bool isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    onSelected: (s) => setState(() => selectedCategory = cat),
                    selectedColor: const Color(0xFF64FFDA),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : (themeProvider.isDark ? Colors.white : Colors.black),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          if (widget.isAdmin) _buildAdminHeader(),

          // OWNER'S PENDING CLAIMS BOX
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('ownerId', isEqualTo: currentUserId)
                .where('status', isEqualTo: 'claimed')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Column(
                  children: snapshot.data!.docs.map((doc) {
                    final item = ItemModel.fromFirestore(doc);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                        onPressed: () => _showOwnerReviewDialog(context, item),
                        child: const Text("REVIEW", style: TextStyle(fontSize: 11)),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // MAIN LIST VIEW
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF64FFDA)));
                }

                final filteredItems = snapshot.data?.docs.map((d) => ItemModel.fromFirestore(d)).where((item) {
                  final matchesSearch = item.name.toLowerCase().contains(searchQuery) ||
                                       item.location.toLowerCase().contains(searchQuery);
                  final matchesCategory = selectedCategory == "All" || item.category == selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList() ?? [];

                if (filteredItems.isEmpty) return const Center(child: Text("No items found."));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return ItemCard(
                      item: item, 
                      isAdmin: widget.isAdmin,
                      onDelete: () => _confirmDelete(item.id!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}