class SizeModel {
  final String id;
  final String name;
  final String tenantId;

  SizeModel({
    required this.id,
    required this.name,
    required this.tenantId,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      tenantId: json['tenantId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tenantId': tenantId,
    };
  }
}