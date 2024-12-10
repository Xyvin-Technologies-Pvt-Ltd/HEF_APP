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
class AttendanceUserListModel {
  final List<AttendanceUser>? registeredUsers;
  final List<AttendanceUser>? attendedUsers;
  final int uniqueUsersCount;

  AttendanceUserListModel({
    this.registeredUsers,
    this.attendedUsers,
    this.uniqueUsersCount = 0,
  });

  factory AttendanceUserListModel.fromJson(Map<String, dynamic> json) {
    return AttendanceUserListModel(
      registeredUsers: (json['registeredUsers'] as List<dynamic>?)
          ?.map((item) => AttendanceUser.fromJson(item as Map<String, dynamic>))
          .toList(),
      attendedUsers: (json['attendedUsers'] as List<dynamic>?)
          ?.map((item) => AttendanceUser.fromJson(item as Map<String, dynamic>))
          .toList(),
      uniqueUsersCount: json['uniqueUsersCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registeredUsers': registeredUsers?.map((user) => user.toJson()).toList(),
      'attendedUsers': attendedUsers?.map((user) => user.toJson()).toList(),
      'uniqueUsersCount': uniqueUsersCount,
    };
  }
}

class AttendanceUser {
  final String? id;
  final String? name;
  final String? image;
  final String? email;

  AttendanceUser({
    this.id,
    this.name,
    this.image,
    this.email,
  });

  factory AttendanceUser.fromJson(Map<String, dynamic> json) {
    return AttendanceUser(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      image: json['image'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'email': email,
    };
  }
}
