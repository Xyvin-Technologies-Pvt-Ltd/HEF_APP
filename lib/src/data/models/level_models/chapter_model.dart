class ChapterDetailsModel {
  final String id;
  final String name;
  final String districtId;
  final List<Admin> admins;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  ChapterDetailsModel({
    required this.id,
    required this.name,
    required this.districtId,
    required this.admins,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory ChapterDetailsModel.fromJson(Map<String, dynamic> json) {
    return ChapterDetailsModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      districtId: json['districtId'] ?? '',
      admins: (json['admins'] as List?)?.map((e) => Admin.fromJson(e)).toList() ?? [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime(1970, 1, 1),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime(1970, 1, 1),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'districtId': districtId,
      'admins': admins.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }

  ChapterDetailsModel copyWith({
    String? id,
    String? name,
    String? districtId,
    List<Admin>? admins,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return ChapterDetailsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      districtId: districtId ?? this.districtId,
      admins: admins ?? this.admins,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}

class Admin {
  final AdminDetails user;
  final String role;
  final String id;

  Admin({
    required this.user,
    required this.role,
    required this.id,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      user: AdminDetails.fromJson(json['user'] ?? {}),
      role: json['role'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'role': role,
      '_id': id,
    };
  }
}

class AdminDetails {
  final String id;
  final String name;
  final String phone;

  AdminDetails({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory AdminDetails.fromJson(Map<String, dynamic> json) {
    return AdminDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
    };
  }
}
