import 'dart:convert';

class Promotion {
  final String? title;
  final String? description;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? media;
  final String? link;

  Promotion({
    this.title,
    this.description,
    this.type,
    this.startDate,
    this.endDate,
    this.media,
    this.link,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      title: json['title'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      media: json['media'] as String?,
      link: json['link'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'media': media,
      'link': link,
    };
  }

  Promotion copyWith({
    String? title,
    String? description,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? media,
    String? link,
  }) {
    return Promotion(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      media: media ?? this.media,
      link: link ?? this.link,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
