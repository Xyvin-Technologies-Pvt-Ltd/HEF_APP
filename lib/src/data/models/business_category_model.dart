class BusinessCategoryModel {
  final String id;
  final String name;
  final String? icon;
  final int? v;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? companyCount;
  final bool? status;

  BusinessCategoryModel(
      {required this.id,
      required this.name,
      this.icon,
      this.v,
      this.createdAt,
      this.updatedAt,
      this.companyCount,
      this.status});

  factory BusinessCategoryModel.fromJson(Map<String, dynamic> json) {
    return BusinessCategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      v: json['__v'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      companyCount: json['company_count'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'icon': icon,
      '__v': v,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'company_count': companyCount,
      'status': status,
    };
  }

  BusinessCategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? v,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? companyCount,
    bool? status,
  }) {
    return BusinessCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      v: v ?? this.v,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      companyCount: companyCount ?? this.companyCount,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'BusinessCategoryModel(id: $id, name: $name, icon: $icon, v: $v, createdAt: $createdAt, updatedAt: $updatedAt, companyCount: $companyCount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessCategoryModel &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode;
  }
}
