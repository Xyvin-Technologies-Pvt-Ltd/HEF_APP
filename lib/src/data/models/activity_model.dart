class ActivityModel {
  final String? id;
  final String? type;
  final Member? member;
  final Sender? sender;
  final String? title;
  final String? description;
  final String? referral;
  final String? contact;
  final String? amount;
  final String? date;
  final String? time;
  final String? meetingLink;
  final String? location;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  ActivityModel({
    this.id,
    this.type,
    this.member,
    this.sender,
    this.title,
    this.description,
    this.referral,
    this.contact,
    this.amount,
    this.date,
    this.time,
    this.meetingLink,
    this.location,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['_id'] as String?,
      type: json['type'] as String?,
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
      sender: json['sender'] != null ? Sender.fromJson(json['sender']) : null,
      title: json['title'] as String?,
      description: json['description'] as String?,
      referral: json['referral'] as String?,
      contact: json['contact'] as String?,
      amount: json['amount'] as String?,
      date: json['date'] as String?,
      time: json['time'] as String?,
      meetingLink: json['meetingLink'] as String?,
      location: json['location'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'member': member?.toJson(),
      'sender': sender?.toJson(),
      'title': title,
      'description': description,
      'referral': referral,
      'contact': contact,
      'amount': amount,
      'date': date,
      'time': time,
      'meetingLink': meetingLink,
      'location': location,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }

  ActivityModel copyWith({
    String? id,
    String? type,
    Member? member,
    Sender? sender,
    String? title,
    String? description,
    String? referral,
    String? contact,
    String? amount,
    String? date,
    String? time,
    String? meetingLink,
    String? location,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      type: type ?? this.type,
      member: member ?? this.member,
      sender: sender ?? this.sender,
      title: title ?? this.title,
      description: description ?? this.description,
      referral: referral ?? this.referral,
      contact: contact ?? this.contact,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      meetingLink: meetingLink ?? this.meetingLink,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }
}

class Member {
  final String? id;
  final String? name;
  final String? role;
  final String? chapter;
  final String? email;

  Member({
    this.id,
    this.name,
    this.role,
    this.chapter,
    this.email,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
      chapter: json['chapter'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'role': role,
      'chapter': chapter,
      'email': email,
    };
  }
}

class Sender {
  final String? id;
  final String? name;
  final String? role;
  final String? chapter;
  final String? email;

  Sender({
    this.id,
    this.name,
    this.role,
    this.chapter,
    this.email,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      role: json['role'] as String?,
      chapter: json['chapter'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'role': role,
      'chapter': chapter,
      'email': email,
    };
  }
}
