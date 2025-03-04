class UserDashboard {
  final int businessGiven;
  final int businessReceived;
  final int referralGiven;
  final int referralReceived;
  final int oneToOneCount;

  UserDashboard({
    required this.businessGiven,
    required this.businessReceived,
    required this.referralGiven,
    required this.referralReceived,
    required this.oneToOneCount,
  });

  factory UserDashboard.fromJson(Map<String, dynamic> json) {
    return UserDashboard(
      businessGiven: json["businessGiven"] ?? 0,
      businessReceived: json["businessReceived"] ?? 0,
      referralGiven: json["refferalGiven"] ?? 0,
      referralReceived: json["refferalReceived"] ?? 0,
      oneToOneCount: json["oneToOneCount"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "businessGiven": businessGiven,
      "businessReceived": businessReceived,
      "refferalGiven": referralGiven,
      "refferalReceived": referralReceived,
      "oneToOneCount": oneToOneCount,
    };
  }

  UserDashboard copyWith({
    int? businessGiven,
    int? businessReceived,
    int? referralGiven,
    int? referralReceived,
    int? oneToOneCount,
  }) {
    return UserDashboard(
      businessGiven: businessGiven ?? this.businessGiven,
      businessReceived: businessReceived ?? this.businessReceived,
      referralGiven: referralGiven ?? this.referralGiven,
      referralReceived: referralReceived ?? this.referralReceived,
      oneToOneCount: oneToOneCount ?? this.oneToOneCount,
    );
  }
}
