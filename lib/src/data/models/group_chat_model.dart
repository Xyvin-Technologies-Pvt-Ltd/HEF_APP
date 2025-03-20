
class GroupChatModel {
  final String? id;
  final GroupChatUserModel? from;
  final String? to;
  final String? content;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  GroupChatModel({
    this.id,
    this.from,
    this.to,
    this.content,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  // fromJson factory method
  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    return GroupChatModel(
      id: json['_id'] as String?,
      from: json['from'] != null
          ? GroupChatUserModel.fromJson(json['from'])
          : null,
      to: json['to'] as String?,
      content: json['content'] as String?,
      status: json['status'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] as int?,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from': from?.toJson(),
      'to': to,
      'content': content,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

class GroupChatUserModel {
  final String? id;
  final String? name;
  final String? image;

  GroupChatUserModel({
    this.id,
    this.name,
    this.image,
  });

  // fromJson factory method for UserModel
  factory GroupChatUserModel.fromJson(Map<String, dynamic> json) {
    return GroupChatUserModel(
      id: json['_id'] as String?,
      name: json['name']as String?,
      image: json['image'] as String?,
    );
  }

  // toJson method for UserModel
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
    };
  }
}
