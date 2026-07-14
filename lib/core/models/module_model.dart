class ModuleModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String moduleType;

  const ModuleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.moduleType,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['module_name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['thumbnail'] ?? json['icon'] ?? '').toString(),
      moduleType: (json['module_type'] ?? '').toString(),
    );
  }
}
