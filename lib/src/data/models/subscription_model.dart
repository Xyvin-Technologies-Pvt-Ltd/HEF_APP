import 'package:flutter/foundation.dart';

class Subscription {
  final String? id;
  final String? user;
  final String? status;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Subscription({
    this.id,
    this.user,
    this.status,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  // fromJson method to parse JSON data
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      status: json['status'] as String?,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] as int?,
    );
  }

  // toJson method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'status': status,
      'expiryDate': expiryDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }

  // copyWith method to create a copy of the object with updated fields
  Subscription copyWith({
    String? id,
    String? user,
    String? status,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return Subscription(
      id: id ?? this.id,
      user: user ?? this.user,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }

  @override
  String toString() {
    return 'Subscription(id: $id, user: $user, status: $status, expiryDate: $expiryDate, createdAt: $createdAt, updatedAt: $updatedAt, v: $v)';
  }
}
