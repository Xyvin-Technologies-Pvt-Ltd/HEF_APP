class Attachment {
      final String url;
      final String type; // image, voice, file, video

      Attachment({required this.url, required this.type});

      factory Attachment.fromJson(Map<String, dynamic> json) {
        return Attachment(
          url: json['url'] ?? '',
          type: json['type'] ?? '',
        );
      }

      Map<String, dynamic> toJson() {
        return {
          'url': url,
          'type': type,
        };
      }
    }

class MessageModel {
  final String? id;
  final String? from;
  final String? to;
  final String? content;
  final List<Attachment>? attachments;
  final ChatBusiness? feed;
  final ChatProduct? product;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;
  // final int? v;
  // final String? type;
  

  MessageModel({
    this.id,
    this.from,
    this.to,
    this.content,
    this.feed,
    this.product,
    required this.attachments,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  // fromJson method
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    String? asId(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map && value['_id'] != null) return value['_id'].toString();
      return value.toString();
    }

    DateTime? asDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return MessageModel(
      id: asId(json['_id']),
      from: asId(json['from']),
      to: asId(json['to']),
      content: json['content'] as String?,
      feed: json['feed'] != null && json['feed'] is Map
          ? ChatBusiness.fromJson(Map<String, dynamic>.from(json['feed']))
          : null,
      product: json['product'] != null && json['product'] is Map
          ? ChatProduct.fromJson(Map<String, dynamic>.from(json['product']))
          : null,
      status: json['status'] as String?,
      createdAt: asDate(json['createdAt']),
      updatedAt: asDate(json['updatedAt']),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      isDeleted: json['isDeleted'] == true ||
          json['deleted'] == true ||
          json['status'] == 'deleted',
    );
  }

  MessageModel copyWith({
    String? id,
    String? from,
    String? to,
    String? content,
    List<Attachment>? attachments,
    ChatBusiness? feed,
    ChatProduct? product,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      feed: feed ?? this.feed,
      product: product ?? this.product,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from': from,
      'to': to,
      'content': content,
      'attachments': attachments!.map((a) => a.toJson()).toList(),
      'feed': feed?.toJson(),
      'product': product?.toJson(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}


class ChatBusiness {
  String? id;
  String? image;
  String? content;

  ChatBusiness({this.id, this.image, this.content});

  factory ChatBusiness.fromJson(Map<String, dynamic> json) {
    return ChatBusiness(
      id: json['_id'],
      image: json['media'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'image': image,
      'content': content,
    };
  }
}

class ChatProduct {
  String? id;
  String? name;
  String? image;
  double? price;

  ChatProduct({this.id, this.name, this.image, this.price});

  factory ChatProduct.fromJson(Map<String, dynamic> json) {
    return ChatProduct(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'price': price,
    };
  }
}
