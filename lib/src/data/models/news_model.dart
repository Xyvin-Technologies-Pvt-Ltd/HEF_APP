class News {
  final String? category;
  final String? title;
  final String? pdf;
  final String? content;
  final String? media;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  News({
    this.category,
    this.title,
    this.pdf,
    this.content,
    this.media,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory method to create a News instance from JSON
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      category: json['category'] as String?,
      title: json['title'] as String?,
      pdf: json['pdf'] as String?,
      content: json['content'] as String?,
      media: json['media'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Converts a News instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'content': content,
      'media': media,
      'pdf': pdf,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Method to create a copy of the News object with updated fields
  News copyWith({
    String? category,
    String? title,
    String? content,
    String? media,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return News(
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      media: media ?? this.media,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
