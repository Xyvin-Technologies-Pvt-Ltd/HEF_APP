class Business {
  final String? id;
  final String? type;
  final String? media;
  final String? link;
  final String? content;
  final String? author;
  final List<String>? likes;
  final List<Comment>? comments;
  final String? status;
  final String? reason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Business({
    this.id,
    this.type,
    this.media,
    this.link,
    this.content,
    this.author,
    this.likes,
    this.comments,
    this.status,
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  // fromJson method
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['_id'] as String?,
      type: json['type'] as String?,
      media: json['media'] as String?,
      link: json['link'] as String?,
      content: json['content'] as String?,
      author: json['author'] as String?,
      likes: (json['like'] as List<dynamic>?)?.map((e) => e as String).toList(),
      comments: (json['comment'] as List<dynamic>?)
          ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
      reason: json['reason'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'media': media,
      'link': link,
      'content': content,
      'author': author,
      'like': likes,
      'comment': comments?.map((e) => e.toJson()).toList(),
      'status': status,
      'reason': reason,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Comment {
  final String? user;
  final String? comment;

  Comment({
    this.user,
    this.comment,
  });

  // fromJson method
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: json['user'] as String?,
      comment: json['comment'] as String?,
    );
  }

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'comment': comment,
    };
  }
}
