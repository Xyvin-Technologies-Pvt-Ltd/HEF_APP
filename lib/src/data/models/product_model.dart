class Product {
  final String? id;
  final String? seller;
  final String? name;
  final String? image;
  final double? price;
  final double? offerPrice;
  final String? description;
  final num? moq;
  final String? productPriceType;
  final String? status;
  final String? categoryId;
  final String? categoryName;
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
    this.productPriceType,
    this.status,
    this.categoryId,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final sellerData = json['seller'];
    final sellerId = sellerData is String
        ? sellerData
        : sellerData is Map
            ? (sellerData['_id'] ?? sellerData['id'])?.toString()
            : null;

    final category = _readCategory(json);

    return Product(
      id: json['_id'] as String?,
      seller: sellerId,
      name: json['name'] as String?,
      image: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      description: json['description'] as String?,
      moq: json['moq'] as num?,
      productPriceType: json['units'] as String?,
      status: json['status'] as String?,
      categoryId: category.$1,
      categoryName: category.$2,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  static (String?, String?) _readCategory(Map<String, dynamic> json) {
    final raw = json['category'] ?? json['productCategory'];
    String? id;
    String? name;
    if (raw is Map) {
      id = (raw['_id'] ?? raw['id'])?.toString();
      name = (raw['name'] ?? raw['title'])?.toString();
    } else if (raw is String && raw.trim().isNotEmpty && raw != 'null') {
      id = raw.trim();
    }
    final named = json['categoryName'] ?? json['category_name'];
    if (named is String && named.trim().isNotEmpty && named != 'null') {
      name = named.trim();
    }
    if (id != null && id.isEmpty) id = null;
    if (name != null && name.isEmpty) name = null;
    return (id, name);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
    };
  }
}
