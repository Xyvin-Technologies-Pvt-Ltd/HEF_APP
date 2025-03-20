class GroupInfoModel {
  final String? groupName;
  final String? groupInfo;
  final int? memberCount;
  final List<GroupParticipantModel>? participantsData;

  GroupInfoModel({
    this.groupName,
    this.groupInfo,
    this.memberCount,
    this.participantsData,
  });

  factory GroupInfoModel.fromJson(Map<String, dynamic> json) {
    return GroupInfoModel(
      groupName: json['groupInfo']?['groupName'] as String?,
      groupInfo: json['groupInfo']?['groupInfo'] as String?,
      memberCount: json['groupInfo']?['memberCount'] as int?,
      participantsData: (json['participantsData'] as List?)
          ?.map((item) => GroupParticipantModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupInfo': {
        'groupName': groupName,
        'groupInfo': groupInfo,
        'memberCount': memberCount,
      },
      'participantsData': participantsData?.map((item) => item.toJson()).toList(),
    };
  }
}

class GroupParticipantModel {
  final String? id;
  final String? name;
  final String? phone;
  final int? batch;
  final String? college;
  final String? memberId;
  final String? status;

  GroupParticipantModel({
    this.id,
    this.name,
    this.phone,
    this.batch,
    this.college,
    this.memberId,
    this.status,
  });

  factory GroupParticipantModel.fromJson(Map<String, dynamic> json) {
    return GroupParticipantModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      batch: json['batch'] as int?,
      college: json['college'] as String?,
      memberId: json['memberId'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'batch': batch,
      'college': college,
      'memberId': memberId,
      'status': status,
    };
  }
}