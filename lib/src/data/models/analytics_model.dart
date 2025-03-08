class AnalyticsModel {
  final String? id;
  final String? user_id; 
  final String? username;
  final String? userImage;
  final String? title;
  final String? status;
  final DateTime? time;
  final String? description;
  final String? referral;
  final String? contact;
  final int? amount;
  final DateTime? date;
  final String? meetingLink;
  final String? location;

  AnalyticsModel({
    this.id,
    this.user_id, 
    this.username,
    this.userImage,
    this.title,
    this.status,
    this.time,
    this.description,
    this.referral,
    this.contact,
    this.amount,
    this.date,
    this.meetingLink,
    this.location,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      id: json['_id'] as String?,
      user_id: json['user_id'] as String?,  // Added to fromJson
      username: json['username'] as String?,
      userImage: json['user_image'] as String?,
      title: json['title'] as String?,
      status: json['status'] as String?,
      time: json['time'] != null ? DateTime.tryParse(json['time']) : null,
      description: json['description'] as String?,
      referral: json['referral'] as String?,
      contact: json['contact'] as String?,
      amount: json['amount'] as int?,
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      meetingLink: json['meetingLink'] as String?,
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user_id': user_id,  // Added to toJson
      'username': username,
      'user_image': userImage,
      'title': title,
      'status': status,
      'time': time?.toIso8601String(),
      'description': description,
      'referral': referral,
      'contact': contact,
      'amount': amount,
      'date': date?.toIso8601String(),
      'meetingLink': meetingLink,
      'location': location,
    };
  }

  AnalyticsModel copyWith({
    String? id,
    String? user_id,  // Added to copyWith
    String? username,
    String? userImage,
    String? title,
    String? status,
    DateTime? time,
    String? description,
    String? referral,
    String? contact,
    int? amount,
    DateTime? date,
    String? meetingLink,
    String? location,
  }) {
    return AnalyticsModel(
      id: id ?? this.id,
      user_id: user_id ?? this.user_id,  // Added to copyWith return
      username: username ?? this.username,
      userImage: userImage ?? this.userImage,
      title: title ?? this.title,
      status: status ?? this.status,
      time: time ?? this.time,
      description: description ?? this.description,
      referral: referral ?? this.referral,
      contact: contact ?? this.contact,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      meetingLink: meetingLink ?? this.meetingLink,
      location: location ?? this.location,
    );
  }
}