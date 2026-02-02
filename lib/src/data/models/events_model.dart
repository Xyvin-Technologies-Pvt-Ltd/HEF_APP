/// Extracts user ID from rsvp element (handles both string ID and populated User object).
String? _extractUserId(dynamic e) {
  if (e == null) return null;
  if (e is String) return e;
  if (e is Map) return e['_id']?.toString();
  return e.toString();
}

/// Extracts user ID from rsvpnew entry { user: ObjectId | User }.
String? _extractUserIdFromRsvpNew(dynamic e) {
  if (e == null || e is! Map) return null;
  final user = e['user'];
  if (user == null) return null;
  if (user is String) return user;
  if (user is Map) return user['_id']?.toString();
  return user.toString();
}

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
  final DateTime? eventDate;
  final String? platform;
  final String? link;
  final String? venue;
  final String? organiserName;
  final List<String>? coordinator;
  final List<Speaker>? speakers;
  final String? status;
  final List<String>? rsvp;

  /// New RSVP format from backend - stores user IDs (registrations go here).
  /// Never null - use [] when backend omits it.
  final List<String>? rsvpnew;
  final List<String>? attended;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? limit;
  final bool? allowGuestResgistration;
  Event({
    this.eventDate,
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
    this.rsvpnew,
    this.attended,
    this.createdAt,
    this.updatedAt,
    this.limit,
    this.allowGuestResgistration,
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
      eventDate: json['eventDate'] != null
          ? DateTime.tryParse(json['eventDate'])
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
      coordinator: (json['coordinator'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      speakers: (json['speakers'] as List<dynamic>?)
          ?.map((e) => Speaker.fromJson(e))
          .toList(),
      status: json['status'] as String?,
      rsvp: (json['rsvp'] as List<dynamic>?)
          ?.map((e) => _extractUserId(e))
          .whereType<String>()
          .toList(),
      rsvpnew: (json['rsvpnew'] as List<dynamic>?)
              ?.map((e) => _extractUserIdFromRsvpNew(e))
              .whereType<String>()
              .toList() ??
          [],
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
      allowGuestResgistration: json['allowGuestRegistration'] as bool?,
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
      'eventDate': eventDate?.toIso8601String(),
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
      'rsvpnew': rsvpnew,
      'attended': attended,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'limit': limit,
      'allowGuestRegistration': allowGuestResgistration,
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
