class DistrictModel {
  final String id;
  final String name;
  final String zoneId;
  final List<DistrictAdmin> admins;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  DistrictModel({
    required this.id,
    required this.name,
    required this.zoneId,
    required this.admins,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json["_id"] ?? '',
      name: json["name"] ?? '',
      zoneId: json["zoneId"] ?? '',
      admins:
          (json["admins"] as List?)?.map((e) => DistrictAdmin.fromJson(e)).toList() ??
              [],
      createdAt:
          DateTime.tryParse(json["createdAt"] ?? '') ?? DateTime(1970, 1, 1),
      updatedAt:
          DateTime.tryParse(json["updatedAt"] ?? '') ?? DateTime(1970, 1, 1),
      version: json["__v"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "zoneId": zoneId,
      "admins": admins.map((e) => e.toJson()).toList(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
      "__v": version,
    };
  }
}

class DistrictAdmin {
  final String user;
  final String role;
  final String id;

  DistrictAdmin({
    required this.user,
    required this.role,
    required this.id,
  });

  factory DistrictAdmin.fromJson(Map<String, dynamic> json) {
    return DistrictAdmin(
      user: json["user"] ?? '',
      role: json["role"] ?? '',
      id: json["_id"] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user": user,
      "role": role,
      "_id": id,
    };
  }
}
