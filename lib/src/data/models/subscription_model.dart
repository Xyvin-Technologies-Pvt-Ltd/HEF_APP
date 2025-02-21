class Subscription {
  final String? id;
  final String? user;
  final String? status;
  final int? amount;
  final String? category;
  final ParentSub? parentSub;
  final String? receipt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Subscription({
    this.id,
    this.user,
    this.status,
    this.amount,
    this.category,
    this.parentSub,
    this.receipt,
    this.createdAt,
    this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json["_id"] as String?,
      user: json["user"] as String?,
      status: json["status"] as String?,
      amount: json["amount"] as int?,
      category: json["category"] as String?,
      parentSub: json["parentSub"] != null ? ParentSub.fromJson(json["parentSub"]) : null,
      receipt: json["receipt"] as String?,
      createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) : null,
      updatedAt: json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "user": user,
      "status": status,
      "amount": amount,
      "category": category,
      "parentSub": parentSub?.toJson(),
      "receipt": receipt,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}

class ParentSub {
  final String? id;
  final String? academicYear;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParentSub({
    this.id,
    this.academicYear,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ParentSub.fromJson(Map<String, dynamic> json) {
    return ParentSub(
      id: json["_id"] as String?,
      academicYear: json["academicYear"] as String?,
      expiryDate: json["expiryDate"] != null ? DateTime.tryParse(json["expiryDate"]) : null,
      createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) : null,
      updatedAt: json["updatedAt"] != null ? DateTime.tryParse(json["updatedAt"]) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "academicYear": academicYear,
      "expiryDate": expiryDate?.toIso8601String(),
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
    };
  }
}
