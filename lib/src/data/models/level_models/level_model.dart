class LevelModel {
  final String id;
  final String name;
  final List<String> admins;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  LevelModel({
    required this.id,
    required this.name,
    required this.admins,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  // Factory method to create a StateModel from JSON
  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      admins: (json['admins'] as List<dynamic>?)
              ?.map((admin) => admin.toString())
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      version: json['__v'] ?? 0,
    );
  }

  // Method to convert a StateModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'admins': admins,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  // CopyWith method to create a new instance with modified fields
  LevelModel copyWith({
    String? id,
    String? name,
    List<String>? admins,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return LevelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      admins: admins ?? this.admins,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}
