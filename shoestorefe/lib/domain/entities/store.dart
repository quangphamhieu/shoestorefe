class Store {
  final int id;
  final String? code;
  final String name;
  final String? address;
  final String? phone;
  final int statusId;
  final DateTime createdAt;

  Store({
    required this.id,
    this.code,
    required this.name,
    this.address,
    this.phone,
    required this.statusId,
    required this.createdAt,
  });
}
