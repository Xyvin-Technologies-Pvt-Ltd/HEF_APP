class GroupInfoModel {
  final String groupName;
  final String groupInfo;
  final int memberCount;
  final List<GroupParticipantModel> participantsData;

  GroupInfoModel({
    required this.groupName,
    required this.groupInfo,
    required this.memberCount,
    required this.participantsData,
  });

  factory GroupInfoModel.fromJson(Map<String, dynamic> json) {
    return GroupInfoModel(
      groupName: json['groupInfo']?['groupName'] ?? '',
      groupInfo: json['groupInfo']?['groupInfo'] ?? '',
      memberCount: json['groupInfo']?['memberCount'] ?? 0,
      participantsData: (json['participantsData'] as List?)?.map((e) => GroupParticipantModel.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupInfo': {
        'groupName': groupName,
        'groupInfo': groupInfo,
        'memberCount': memberCount,
      },
      'participantsData': participantsData.map((e) => e.toJson()).toList(),
    };
  }
}

class GroupParticipantModel {
  final String id;
  final String name;
  final String image;
  final String phone;
  final String chapter;
  final String memberId;
  final String status;

  GroupParticipantModel({
    required this.id,
    required this.name,
    required this.image,
    required this.phone,
    required this.chapter,
    required this.memberId,
    required this.status,
  });

  factory GroupParticipantModel.fromJson(Map<String, dynamic> json) {
    return GroupParticipantModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      phone: json['phone'] ?? '',
      chapter: json['chapter'] ?? '',
      memberId: json['memberId'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'phone': phone,
      'chapter': chapter,
      'memberId': memberId,
      'status': status,
    };
  }
}
