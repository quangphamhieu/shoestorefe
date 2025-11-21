class Supplier {
  final int id;
  final String? code;
  final String name;
  final String? contactInfo;
  final int statusId;

  Supplier({
    required this.id,
    this.code,
    required this.name,
    this.contactInfo,
    required this.statusId,
  });
}
