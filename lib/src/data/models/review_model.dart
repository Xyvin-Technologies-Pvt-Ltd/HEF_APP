class ReviewModel {
  final String? id;
  final String? toUser;
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

  // fromJson
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] as String?,
      toUser: json['toUser'] as String?,
      reviewer: json['reviewer'] != null
          ? Reviewer.fromJson(json['reviewer'] as Map<String, dynamic>)
          : null,
      rating: json['rating'] as int?,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      version: json['__v'] as int?,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'toUser': toUser,
      'reviewer': reviewer?.toJson(),
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}

class Reviewer {
  final String? id;
  final String? name;
  final String? image;

  Reviewer({
    this.id,
    this.name,
    this.image,
  });

  // fromJson
  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
    };
  }
}
