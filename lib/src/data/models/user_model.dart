

class UserModel {
  final String? name;
  final String? uid;
  final String? memberId;
  final String? bloodGroup;
  final String? role;
  final String? chapter;
  final String? image;
  final String? email;
  final String? phone;
  final List<String>? secondaryPhone;
  final String? bio;
  final String? status;
  final String? address;
  final Company? company;
  final String? social;
  final String? businessCategory;
  final String? businessSubCategory;
  final List<Award>? awards;
  final String? videos;
  final String? certificates;
  final int? otp;
  final List<String>? blockedUsers;

  UserModel({
    this.name,
    this.uid,
    this.memberId,
    this.bloodGroup,
    this.role = "member",
    this.chapter,
    this.image,
    this.email,
    this.phone,
    this.secondaryPhone,
    this.bio,
    this.status = "inactive",
    this.address,
    this.company,
    this.social,
    this.businessCategory,
    this.businessSubCategory,
    this.awards,
    this.videos,
    this.certificates,
    this.otp,
    this.blockedUsers,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String?,
      uid: json['uid'] as String?,
      memberId: json['memberId'] as String?,
      bloodGroup: json['bloodgroup'] as String?,
      role: json['role'] as String? ?? "member",
      chapter: json['chapter'] as String?,
      image: json['image'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      secondaryPhone: (json['secondaryPhone'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      bio: json['bio'] as String?,
      status: json['status'] as String? ?? "inactive",
      address: json['address'] as String?,
      company: json['company'] != null
          ? Company.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      social: json['social'] as String?,
      businessCategory: json['businessCatogary'] as String?,
      businessSubCategory: json['businessSubCatogary'] as String?,
      awards: (json['awards'] as List<dynamic>?)
          ?.map((e) => Award.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: json['videos'] as String?,
      certificates: json['certificates'] as String?,
      otp: json['otp'] as int?,
      blockedUsers: (json['blockedUsers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'uid': uid,
      'memberId': memberId,
      'bloodgroup': bloodGroup,
      'role': role,
      'chapter': chapter,
      'image': image,
      'email': email,
      'phone': phone,
      'secondaryPhone': secondaryPhone,
      'bio': bio,
      'status': status,
      'address': address,
      'company': company?.toJson(),
      'social': social,
      'businessCatogary': businessCategory,
      'businessSubCatogary': businessSubCategory,
      'awards': awards?.map((e) => e.toJson()).toList(),
      'videos': videos,
      'certificates': certificates,
      'otp': otp,
      'blockedUsers': blockedUsers,
    };
  }
}

class Company {
  final String? name;
  final String? designation;
  final String? email;
  final String? websites;
  final String? phone;

  Company({
    this.name,
    this.designation,
    this.email,
    this.websites,
    this.phone,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] as String?,
      designation: json['designation'] as String?,
      email: json['email'] as String?,
      websites: json['websites'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'designation': designation,
      'email': email,
      'websites': websites,
      'phone': phone,
    };
  }
}

class Award {
  final String? image;
  final String? name;
  final String? authority;

  Award({this.image, this.name, this.authority});

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      image: json['image'] as String?,
      name: json['name'] as String?,
      authority: json['authority'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'name': name,
      'authority': authority,
    };
  }
}
