class GlobalSearchResult {
  final List<GlobalSearchMember> members;
  final List<GlobalSearchCategory> categories;
  final List<GlobalSearchProduct> products;
  final List<GlobalSearchChapter> chapters;
  final List<GlobalSearchService> services;

  const GlobalSearchResult({
    this.members = const [],
    this.categories = const [],
    this.products = const [],
    this.chapters = const [],
    this.services = const [],
  });

  factory GlobalSearchResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const GlobalSearchResult();

    return GlobalSearchResult(
      members: _mapList(json['members'], GlobalSearchMember.fromJson),
      categories: _mapList(json['categories'], GlobalSearchCategory.fromJson),
      products: _mapList(json['products'], GlobalSearchProduct.fromJson),
      chapters: _mapList(json['chapters'], GlobalSearchChapter.fromJson),
      services: _mapList(json['services'], GlobalSearchService.fromJson),
    );
  }

  bool get isEmpty =>
      members.isEmpty &&
      categories.isEmpty &&
      products.isEmpty &&
      chapters.isEmpty &&
      services.isEmpty;

  /// Visible buckets used by the app search UI.
  bool get hasVisibleResults =>
      members.isNotEmpty ||
      categories.isNotEmpty ||
      products.isNotEmpty ||
      chapters.isNotEmpty;

  static List<T> _mapList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) mapper,
  ) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => mapper(Map<String, dynamic>.from(item)))
        .toList();
  }
}

class GlobalSearchMember {
  final String id;
  final String name;
  final String image;
  final String memberId;
  final String phone;
  final String chapter;
  final String? chapterId;

  const GlobalSearchMember({
    required this.id,
    required this.name,
    this.image = '',
    this.memberId = '',
    this.phone = '',
    this.chapter = '',
    this.chapterId,
  });

  factory GlobalSearchMember.fromJson(Map<String, dynamic> json) {
    return GlobalSearchMember(
      id: _idOf(json),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      memberId: (json['memberId'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      chapter: (json['chapter'] ?? '').toString(),
      chapterId: _nullableId(json['chapterId']),
    );
  }

  String get subtitle {
    final parts = <String>[
      if (memberId.isNotEmpty) memberId,
      if (chapter.isNotEmpty) chapter,
    ];
    return parts.join(' • ');
  }
}

class GlobalSearchCategory {
  final String id;
  final String name;

  const GlobalSearchCategory({
    required this.id,
    required this.name,
  });

  factory GlobalSearchCategory.fromJson(Map<String, dynamic> json) {
    return GlobalSearchCategory(
      id: _idOf(json),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class GlobalSearchProduct {
  final String id;
  final String name;
  final String image;
  final double? price;
  final double? offerPrice;
  final String? seller;
  final List<String> tags;

  const GlobalSearchProduct({
    required this.id,
    required this.name,
    this.image = '',
    this.price,
    this.offerPrice,
    this.seller,
    this.tags = const [],
  });

  factory GlobalSearchProduct.fromJson(Map<String, dynamic> json) {
    final sellerRaw = json['seller'];
    String? sellerId;
    if (sellerRaw is String) {
      sellerId = sellerRaw;
    } else if (sellerRaw is Map) {
      sellerId = (sellerRaw['_id'] ?? sellerRaw['id'])?.toString();
    }

    return GlobalSearchProduct(
      id: _idOf(json),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      price: _toDouble(json['price']),
      offerPrice: _toDouble(json['offerPrice']),
      seller: sellerId,
      tags: (json['tags'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
    );
  }

  String get subtitle {
    final parts = <String>[
      if (offerPrice != null)
        '₹$offerPrice'
      else if (price != null)
        '₹$price',
      if (tags.isNotEmpty) tags.take(2).join(', '),
    ];
    return parts.join(' • ');
  }
}

class GlobalSearchChapter {
  final String id;
  final String name;
  final String shortCode;

  const GlobalSearchChapter({
    required this.id,
    required this.name,
    this.shortCode = '',
  });

  factory GlobalSearchChapter.fromJson(Map<String, dynamic> json) {
    return GlobalSearchChapter(
      id: _idOf(json),
      name: (json['name'] ?? '').toString(),
      shortCode: (json['shortCode'] ?? '').toString(),
    );
  }
}

enum GlobalSearchServiceType { businessTag, product, unknown }

class GlobalSearchService {
  final GlobalSearchServiceType type;
  final String? id;
  final String name;
  final String image;
  final double? price;
  final double? offerPrice;
  final List<String> tags;

  const GlobalSearchService({
    required this.type,
    required this.name,
    this.id,
    this.image = '',
    this.price,
    this.offerPrice,
    this.tags = const [],
  });

  factory GlobalSearchService.fromJson(Map<String, dynamic> json) {
    final rawType = (json['type'] ?? '').toString();
    final type = switch (rawType) {
      'business_tag' => GlobalSearchServiceType.businessTag,
      'product' => GlobalSearchServiceType.product,
      _ => GlobalSearchServiceType.unknown,
    };

    return GlobalSearchService(
      type: type,
      id: _nullableId(json['_id'] ?? json['id']),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      price: _toDouble(json['price']),
      offerPrice: _toDouble(json['offerPrice']),
      tags: (json['tags'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
    );
  }

  String get badgeLabel => switch (type) {
        GlobalSearchServiceType.businessTag => 'Tag',
        GlobalSearchServiceType.product => 'Service',
        GlobalSearchServiceType.unknown => 'Service',
      };

  String get subtitle {
    if (type == GlobalSearchServiceType.businessTag) {
      return 'Business tag';
    }
    final parts = <String>[
      if (offerPrice != null)
        '₹$offerPrice'
      else if (price != null)
        '₹$price',
      if (tags.isNotEmpty) tags.take(2).join(', '),
    ];
    return parts.isEmpty ? 'Service' : parts.join(' • ');
  }
}

String _idOf(Map<String, dynamic> json) {
  return (json['_id'] ?? json['id'] ?? '').toString();
}

String? _nullableId(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') return null;
  return text;
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
