import 'dart:convert';

class Product {
  final String? id;
  final String? seller;
  final String? name;
  final String? image;
  final double? price;
  final double? offerPrice;
  final String? description;
  final int? moq;
  final String? units;
  final String status;
  final String? reason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    this.seller,
    this.name,
    this.image,
    this.price,
    this.offerPrice,
    this.description,
    this.moq,
    this.units,
    this.status = "pending",
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory method to create a Product instance from JSON.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String?,
      seller: json['seller'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      description: json['description'] as String?,
      moq: json['moq'] as int?,
      units: json['units'] as String?,
      status: json['status'] as String? ?? "pending",
      reason: json['reason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Method to convert a Product instance into JSON.
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'seller': seller,
      'name': name,
      'image': image,
      'price': price,
      'offerPrice': offerPrice,
      'description': description,
      'moq': moq,
      'units': units,
      'status': status,
      'reason': reason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Method to create a copy of the Product with modified values.
  Product copyWith({
    String? id,
    String? seller,
    String? name,
    String? image,
    double? price,
    double? offerPrice,
    String? description,
    int? moq,
    String? units,
    String? status,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      seller: seller ?? this.seller,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      offerPrice: offerPrice ?? this.offerPrice,
      description: description ?? this.description,
      moq: moq ?? this.moq,
      units: units ?? this.units,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
