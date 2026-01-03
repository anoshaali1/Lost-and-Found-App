import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminClaimsView extends StatelessWidget {
  final QueryDocumentSnapshot itemDoc;
  AdminClaimsView({required this.itemDoc});

  @override
  Widget build(BuildContext context) {
    final data = itemDoc.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text('Claims for ${data['name'] ?? ''}')),
      body: StreamBuilder<QuerySnapshot>(
          stream: itemDoc.reference
              .collection('claims')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (ctx, snap) {
            if (!snap.hasData) return Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            if (docs.isEmpty) return Center(child: Text('No claims'));
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final c = docs[i];
                final cd = c.data() as Map<String, dynamic>;
                final ts = cd['timestamp'] as Timestamp?;
                final dateStr =
                    ts != null ? DateFormat.yMMMd().add_jm().format(ts.toDate()) : '';
                return ListTile(
                  title: Text('${cd['name']} (${cd['regNo']})'),
                  subtitle: Text(
                      'Proof: ${cd['proof']}\nContact: ${cd['contactInfo']}\nStatus: ${cd['status']}\nDate: $dateStr'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'accept') {
                        final chosenClaimRef = c.reference;
                        final itemRef = itemDoc.reference;
                        try {
                          await FirebaseFirestore.instance.runTransaction((tx) async {
                            final itemSnap = await tx.get(itemRef);
                            if (!itemSnap.exists) throw Exception('Item missing');
                            final itemData = itemSnap.data() as Map<String, dynamic>;
                            final status = itemData['status'] as String? ?? 'active';
                            if (status != 'active') {
                              throw Exception('Item already returned or locked');
                            }

                            tx.update(itemRef, {
                              'status': 'returned',
                              'acceptedClaim': chosenClaimRef.id
                            });
                            tx.update(chosenClaimRef,
                                {'status': 'accepted', 'handledAt': Timestamp.now()});

                            final otherClaims = await itemRef
                                .collection('claims')
                                .where('status', isEqualTo: 'pending')
                                .get();
                            for (var oc in otherClaims.docs) {
                              if (oc.id != chosenClaimRef.id) {
                                tx.update(oc.reference, {'status': 'rejected'});
                              }
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Claim accepted and item returned')));
                        } catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      } else if (v == 'reject') {
                        await c.reference.update({'status': 'rejected'});
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Claim rejected')));
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'accept', child: Text('Accept')),
                      PopupMenuItem(
                          value: 'reject',
                          child: Text('Reject', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
