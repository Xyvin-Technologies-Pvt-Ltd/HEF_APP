
import 'package:hef/src/data/models/msg_model.dart';

class GroupChatModel {
  final String? id;
  final GroupChatUserModel? from;
  final String? to;
  final String? content;
  final List<Attachment>? attachments;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final bool isDeleted;

  GroupChatModel({
    this.id,
    this.from,
    this.to,
    this.content,
    this.attachments,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isDeleted = false,
  });

  // fromJson factory method
  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    GroupChatUserModel? parseFrom(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        return GroupChatUserModel(id: value);
      }
      if (value is Map) {
        return GroupChatUserModel.fromJson(Map<String, dynamic>.from(value));
      }
      return GroupChatUserModel(id: value.toString());
    }

    DateTime? asDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return GroupChatModel(
      id: json['_id']?.toString(),
      from: parseFrom(json['from']),
      to: json['to']?.toString(),
      content: json['content'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => Attachment.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      status: json['status'] as String?,
      createdAt: asDate(json['createdAt']),
      updatedAt: asDate(json['updatedAt']),
      v: json['__v'] as int?,
      isDeleted: json['isDeleted'] == true ||
          json['deleted'] == true ||
          json['status'] == 'deleted',
    );
  }

  GroupChatModel copyWith({
    String? id,
    GroupChatUserModel? from,
    String? to,
    String? content,
    List<Attachment>? attachments,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    bool? isDeleted,
  }) {
    return GroupChatModel(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      content: content ?? this.content,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from': from?.toJson(),
      'to': to,
      'content': content,
      'attachments': attachments?.map((a) => a.toJson()).toList(),
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
      'isDeleted': isDeleted,
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
