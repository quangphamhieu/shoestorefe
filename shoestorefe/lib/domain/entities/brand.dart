class Brand {
  final int id;
  final String? code;
  final String name;
  final String? description;
  final int statusId;

  Brand({
    required this.id,
    this.code,
    required this.name,
    this.description,
    required this.statusId,
  });
}
