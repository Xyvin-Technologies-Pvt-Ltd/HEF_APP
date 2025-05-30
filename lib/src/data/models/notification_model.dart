class NotificationModel {
  final List<UserNotification>? users;
  final String? subject;
  final String? content;
  final String? media;
  final String? link;
  final String? type;
  final String? fileUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    this.users,
    this.subject,
    this.content,
    this.media,
    this.link,
    this.type,
    this.fileUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      users: json['users'] != null
          ? (json['users'] as List)
              .map((user) => UserNotification.fromJson(user))
              .toList()
          : null,
      subject: json['subject'] as String?,
      content: json['content'] as String?,
      media: json['media'] as String?,
      link: json['link'] as String?,
      type: json['type'] as String?,
      fileUrl: json['fileUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users?.map((user) => user.toJson()).toList(),
      'subject': subject,
      'content': content,
      'media': media,
      'link': link,
      'type': type,
      'fileUrl': fileUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class UserNotification {
  final String? userId;
  final bool? read;

  UserNotification({this.userId, this.read});

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      userId: json['user'] as String?,
      read: json['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'read': read,
    };
  }
}
