
class AttendanceUserModel {
  final String? username;
  final String? image;
  final String? email;
  final String? state;
  final String? zone;
  final String? district;
  final String? chapter;

  AttendanceUserModel({
    this.username,
    this.image,
    this.email,
    this.state,
    this.zone,
    this.district,
    this.chapter,
  });

  /// Creates an instance from a JSON map.
  factory AttendanceUserModel.fromJson(Map<String, dynamic> json) {
    return AttendanceUserModel(
      username: json['username'] as String?,
      image: json['image'] as String?,
      email: json['email'] as String?,
      state: json['state'] as String?,
      zone: json['zone'] as String?,
      district: json['district'] as String?,
      chapter: json['chapter'] as String?,
    );
  }

  /// Converts the instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'image': image,
      'email': email,
      'state': state,
      'zone': zone,
      'district': district,
      'chapter': chapter,
    };
  }

  /// Creates a copy of the instance with updated fields.
  AttendanceUserModel copyWith({
    String? username,
    String? image,
    String? email,
    String? state,
    String? zone,
    String? district,
    String? chapter,
  }) {
    return AttendanceUserModel(
      username: username ?? this.username,
      image: image ?? this.image,
      email: email ?? this.email,
      state: state ?? this.state,
      zone: zone ?? this.zone,
      district: district ?? this.district,
      chapter: chapter ?? this.chapter,
    );
  }
}
