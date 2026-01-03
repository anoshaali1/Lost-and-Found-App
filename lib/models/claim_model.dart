class ClaimModel {
  final String id;
  final String itemId;
  final String userId;
  final String proof;
  final String status; // 'Pending', 'Accepted', 'Rejected'

  ClaimModel({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.proof,
    required this.status,
  });

  factory ClaimModel.fromMap(String id, Map<String, dynamic> map) => ClaimModel(
    id: id,
    itemId: map['itemId'] ?? '',
    userId: map['userId'] ?? '',
    proof: map['proof'] ?? '',
    status: map['status'] ?? 'Pending',
  );
}