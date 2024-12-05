class ReviewModel {
  final String? id;
  final ToUser? toUser;
  final Reviewer? reviewer;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  ReviewModel({
    this.id,
    this.toUser,
    this.reviewer,
    this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] as String?,
      toUser: json['toUser'] != null ? ToUser.fromJson(json['toUser']) : null,
      reviewer:
          json['reviewer'] != null ? Reviewer.fromJson(json['reviewer']) : null,
      rating: json['rating'] as int?,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      version: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'toUser': toUser?.toJson(),
      'reviewer': reviewer?.toJson(),
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }

  ReviewModel copyWith({
    String? id,
    ToUser? toUser,
    Reviewer? reviewer,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? version,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      toUser: toUser ?? this.toUser,
      reviewer: reviewer ?? this.reviewer,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}

class ToUser {
  final String? id;
  final String? name;
  final String? image;

  ToUser({this.id, this.name, this.image});

  factory ToUser.fromJson(Map<String, dynamic> json) {
    return ToUser(
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

  ToUser copyWith({
    String? id,
    String? name,
    String? image,
  }) {
    return ToUser(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
    );
  }
}

class Reviewer {
  final String? id;

  Reviewer({this.id});

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      id: json['_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
    };
  }

  Reviewer copyWith({
    String? id,
  }) {
    return Reviewer(
      id: id ?? this.id,
    );
  }
}
