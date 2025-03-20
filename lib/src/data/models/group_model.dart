class GroupModel {
  String? id;
  String? groupName;
  int? unreadCount;
  String? lastMessage;

  GroupModel({
    this.id,
    this.groupName,
    this.unreadCount,
    this.lastMessage
  });

  // From JSON
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] as String?,
      groupName: json['groupName'] as String?,
      unreadCount: json['unreadCount'] as int?,
      lastMessage: json['lastMessage'] as String?
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'groupName': groupName,
      'unreadCount': unreadCount,
      'lastMessage': lastMessage
    };
  }
}
