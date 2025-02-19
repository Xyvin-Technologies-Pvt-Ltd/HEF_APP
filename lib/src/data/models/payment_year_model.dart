class PaymentYearModel {
  final String? id;
  final String? academicYear;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  PaymentYearModel({
    this.id,
    this.academicYear,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  // fromJson method
  factory PaymentYearModel.fromJson(Map<String, dynamic> json) {
    return PaymentYearModel(
      id: json['_id'] as String?,
      academicYear: json['academicYear'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      version: json['__v'] as int?,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'academicYear': academicYear,
      'expiryDate': expiryDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }

  // copyWith method
  PaymentYearModel copyWith({
    String? id,
    String? academicYear,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return PaymentYearModel(
      id: id ?? this.id,
      academicYear: academicYear ?? this.academicYear,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}
