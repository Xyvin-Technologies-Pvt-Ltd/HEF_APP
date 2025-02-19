class Subscription {
  final String? id;
  final String? user;
  final String? status;
  final int? amount;
  final String? category;
  final DateTime? lastRenewDate;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Subscription({
    this.id,
    this.user,
    this.status,
    this.amount,
    this.category,
    this.lastRenewDate,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  /// Factory constructor for creating an instance from a JSON map
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] as String?,
      user: json['user'] as String?,
      status: json['status'] as String?,
      amount: json['amount'] as int?,
      category: json['category'] as String?,
      lastRenewDate: json['lastRenewDate'] != null
          ? DateTime.parse(json['lastRenewDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      v: json['__v'] as int?,
    );
  }

  /// Method to convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'status': status,
      'amount': amount,
      'category': category,
      'lastRenewDate': lastRenewDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }

  /// CopyWith method for creating a new instance with modified fields
  Subscription copyWith({
    String? id,
    String? user,
    String? status,
    int? amount,
    String? category,
    DateTime? lastRenewDate,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return Subscription(
      id: id ?? this.id,
      user: user ?? this.user,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      lastRenewDate: lastRenewDate ?? this.lastRenewDate,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}
