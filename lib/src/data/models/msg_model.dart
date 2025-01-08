class MessageModel {
  final String? id;
  final String? from;
  final String? to;
  final String? content;
  final ChatBusiness? feed;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  MessageModel({
    this.id,
    this.from,
    this.to,
    this.content,
    this.feed,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  // fromJson method
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] as String?,
      from: json['from'] as String?,
      to: json['to'] as String?,
      content: json['content'] as String?,
      feed: json['feed'] != null ? ChatBusiness.fromJson(json['feed']) : null,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] as int?,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from': from,
      'to': to,
      'content': content,
      'feed': feed?.toJson(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
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
      image: json['image'],
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
