class ZoneModel {
  final int id;
  final String name;

  const ZoneModel({required this.id, required this.name});

  factory ZoneModel.fromJson(Map<String, dynamic> json) => ZoneModel(
        id: (json['id'] ?? 0) as int,
        name: (json['name'] ?? '').toString(),
      );
}

