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
  final String? productPriceType;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  Product({
    this.id,
    this.seller,
    this.name,
    this.image,
    this.price,
    this.offerPrice,
    this.description,
    this.moq,
    this.productPriceType,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

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
      productPriceType: json['units'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      version: json['__v'] as int?,
    );
  }

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
      'units': productPriceType,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}
