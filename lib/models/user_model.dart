class UserModel {
  final String uid;
  final String name;
  final String email;
  final String regNo;
  final String department;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.regNo = '',
    this.department = '',
    this.isAdmin = false,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid, 'name': name, 'email': email,
    'regNo': regNo, 'department': department, 'isAdmin': isAdmin,
  };
}