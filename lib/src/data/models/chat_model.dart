
class ChatModel {
  final String? id;
  final List<Participant>? participants;
  final LastMessage? lastMessage;
  final Map<String, int>? unreadCount;
  final bool? isGroup;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  ChatModel({
    this.id,
    this.participants,
    this.lastMessage,
    this.unreadCount,
    this.isGroup,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['_id'] as String?,
      participants: (json['participants'] as List?)
          ?.map((e) => Participant.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount: (json['unreadCount'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value as int),
      ),
      isGroup: json['isGroup'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'participants': participants?.map((e) => e.toJson()).toList(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

class Participant {
  final String? id;
  final String? name;
  final String? image;

  Participant({
    this.id,
    this.name,
    this.image,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
    };
  }
}



class LastMessage {
  final String? id;
  final String? from;
  final String? to;
  final String? content;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  LastMessage({
    this.id,
    this.from,
    this.to,
    this.content,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      id: json['_id'] as String?,
      from: json['from'] as String?,
      to: json['to'] as String?,
      content: json['content'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'from': from,
      'to': to,
      'content': content,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}
