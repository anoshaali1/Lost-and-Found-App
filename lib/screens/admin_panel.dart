import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_claims_view.dart';

class AdminPanel extends StatefulWidget {
  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final itemsRef = FirebaseFirestore.instance.collection('items');
  final usersRef = FirebaseFirestore.instance.collection('users');

  Future<Map<String, int>> _fetchStats() async {
    final totalItemsSnap = await itemsRef.get();
    final totalClaimsSnap = await FirebaseFirestore.instance.collectionGroup('claims').get();
    final returnedItemsSnap = await itemsRef.where('status', isEqualTo: 'returned').get();
    final usersSnap = await usersRef.get();
    return {
      'totalItems': totalItemsSnap.size,
      'totalClaims': totalClaimsSnap.size,
      'returnedItems': returnedItemsSnap.size,
      'users': usersSnap.size,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Admin Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        FutureBuilder<Map<String, int>>(
            future: _fetchStats(),
            builder: (ctx, snap) {
              if (!snap.hasData) return Center(child: CircularProgressIndicator());
              final stats = snap.data!;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard('Items', stats['totalItems']!.toString(), Icons.list),
                  _statCard('Claims', stats['totalClaims']!.toString(), Icons.how_to_reg),
                  _statCard('Returned', stats['returnedItems']!.toString(), Icons.check_box),
                  _statCard('Users', stats['users']!.toString(), Icons.person),
                ],
              );
            }),
        SizedBox(height: 16),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
              stream: itemsRef.orderBy('createdAt', descending: true).snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return Center(child: Text('No items yet.'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final data = d.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(data['name'] ?? 'Unknown'),
                        subtitle: Text(
                            '${data['category'] ?? ''} • ${data['status'] ?? 'active'} • ${data['ownerName'] ?? ''}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'delete') {
                              final batch = FirebaseFirestore.instance.batch();
                              final claims = await d.reference.collection('claims').get();
                              for (var c in claims.docs) batch.delete(c.reference);
                              batch.delete(d.reference);
                              await batch.commit();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Item deleted')));
                            } else if (v == 'viewClaims') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminClaimsView(itemDoc: d),
                                ),
                              );
                            } else if (v == 'lock') {
                              await d.reference.update({'status': 'locked'});
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Item locked')));
                            } else if (v == 'unlock') {
                              await d.reference.update({'status': 'active'});
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('Item unlocked')));
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(value: 'viewClaims', child: Text('View Claims')),
                            PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete', style: TextStyle(color: Colors.red))),
                            PopupMenuItem(value: 'lock', child: Text('Lock Item')),
                            PopupMenuItem(value: 'unlock', child: Text('Unlock Item')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
        )
      ]),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 4,
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 28),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
