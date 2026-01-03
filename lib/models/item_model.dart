import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String? id;
  final String name;
  final String regNo;
  final String department;
  final String semester;
  final String colorBrand;
  final String details;
  final String category;
  final String location;
  final String contact;
  final String type; 
  final String ownerId;
  final String ownerName;
  final String imagePath; 
  final String status; 
  final DateTime createdAt;

  ItemModel({
    this.id,
    required this.name,
    required this.regNo,
    required this.department,
    required this.semester,
    required this.colorBrand,
    required this.details,
    required this.category,
    required this.location,
    required this.contact,
    required this.type,
    required this.ownerId,
    required this.ownerName,
    required this.imagePath,
    this.status = 'active',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'regNo': regNo,
      'department': department,
      'semester': semester,
      'colorBrand': colorBrand,
      'details': details,
      'category': category,
      'location': location,
      'contact': contact,
      'type': type,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'imagePath': imagePath,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return ItemModel(
      id: doc.id,
      name: map['name'] ?? '',
      regNo: map['regNo'] ?? '',
      department: map['department'] ?? '',
      semester: map['semester'] ?? '',
      colorBrand: map['colorBrand'] ?? '',
      details: map['details'] ?? '', 
      category: map['category'] ?? 'Others',
      location: map['location'] ?? '',
      contact: map['contact'] ?? '',
      type: map['type'] ?? 'lost',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? 'Unknown',
      imagePath: map['imagePath'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}