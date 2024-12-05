class AnalyticsModel {
  final String? id;
  final String? type;
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
  final int? version;

  AnalyticsModel({
    this.id,
    this.type,
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
    this.version,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      id: json['_id'] as String?,
      type: json['type'] as String?,
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
      version: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
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
      '__v': version,
    };
  }
}

class Sender {
  final String? id;
  final String? name;
  final String? image;

  Sender({
    this.id,
    this.name,
    this.image,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
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
