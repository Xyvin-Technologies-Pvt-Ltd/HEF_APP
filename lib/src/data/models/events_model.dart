class Event {
  final String? id;
  final String? eventName;
  final String? description;
  final String? type;
  final String? image;
  final DateTime? startDate;
  final DateTime? startTime;
  final DateTime? endDate;
  final DateTime? endTime;
  final String? platform;
  final String? link;
  final String? venue;
  final String? organiserName;
  final List<String>? coordinator;
  final List<Speaker>? speakers;
  final String? status;
  final List<String>? rsvp;
  final List<String>? attended;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? limit;
  Event({
    this.id,
    this.eventName,
    this.description,
    this.type,
    this.image,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.platform,
    this.link,
    this.venue,
    this.organiserName,
    this.coordinator,
    this.speakers,
    this.status,
    this.rsvp,
    this.attended,
    this.createdAt,
    this.updatedAt,this.limit
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] as String?,
      eventName: json['eventName'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      image: json['image'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'])
          : null,
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      endTime:
          json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      platform: json['platform'] as String?,
      link: json['link'] as String?,
      venue: json['venue'] as String?,
      organiserName: json['organiserName'] as String?,
      coordinator:  (json['coordinator'] as List<dynamic>?)?.map((e) => e as String).toList(),
      speakers: (json['speakers'] as List<dynamic>?)
          ?.map((e) => Speaker.fromJson(e))
          .toList(),
      status: json['status'] as String?,
      rsvp: (json['rsvp'] as List<dynamic>?)?.map((e) => e as String).toList(),
      attended: (json['attended'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
                limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventName': eventName,
      'description': description,
      'type': type,
      'image': image,
      'startDate': startDate?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'platform': platform,
      'link': link,
      'venue': venue,
      'organiserName': organiserName,
      'coordinator': coordinator,
      'speakers': speakers?.map((e) => e.toJson()).toList(),
      'status': status,
      'rsvp': rsvp,
      'attended': attended,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'limit':limit
    };
  }
}


class Speaker {
  final String? name;
  final String? designation;
  final String? role;
  final String? image;

  Speaker({
    this.name,
    this.designation,
    this.role,
    this.image,
  });

  factory Speaker.fromJson(Map<String, dynamic> json) {
    return Speaker(
      name: json['name'] as String?,
      designation: json['designation'] as String?,
      role: json['role'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'designation': designation,
      'role': role,
      'image': image,
    };
  }
}
