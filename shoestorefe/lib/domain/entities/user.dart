class User {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final int gender; // 0 = Male, 1 = Female (theo backend enum)
  final String roleName;
  final String statusName;
  final int? storeId;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.gender,
    required this.roleName,
    required this.statusName,
    this.storeId,
    required this.createdAt,
  });
}
