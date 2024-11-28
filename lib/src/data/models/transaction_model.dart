class Transaction {
  final String? id;
  final String? member;
  final DateTime? date;
  final DateTime? time;
  final int? amount;
  final String? modeOfPayment;
  final String? category;
  final String? status;
  final DateTime? renewal;
  final int? days;
  final String? invoiceUrl;
  final String? remarks;

  Transaction({
    this.id,
    this.member,
    this.date,
    this.time,
    this.amount,
    this.modeOfPayment,
    this.category,
    this.status,
    this.renewal,
    this.days,
    this.invoiceUrl,
    this.remarks,
  });

  // Factory constructor to create a Payment instance from JSON with null safety
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] as String?,
      member: json['member'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      time: json['time'] != null ? DateTime.parse(json['time']) : null,
      amount: json['amount'] as int?,
      modeOfPayment: json['mode_of_payment'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      renewal: json['renewal'] != null ? DateTime.parse(json['renewal']) : null,
      days: json['days'] as int?,
      invoiceUrl: json['invoice_url'] as String?,
      remarks: json['remarks'] as String?,
    );
  }

  // Method to convert Payment instance to JSON with null safety
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'member': member,
      'date': date?.toIso8601String(),
      'time': time?.toIso8601String(),
      'amount': amount,
      'mode_of_payment': modeOfPayment,
      'category': category,
      'status': status,
      'renewal': renewal?.toIso8601String(),
      'days': days,
      'invoice_url': invoiceUrl,
      'remarks': remarks,
    };
  }

  // CopyWith method to create a copy of Payment instance with updated fields
  Transaction copyWith({
    String? id,
    String? member,
    DateTime? date,
    DateTime? time,
    int? amount,
    String? modeOfPayment,
    String? category,
    String? status,
    DateTime? renewal,
    int? days,
    String? invoiceUrl,
    String? remarks,
  }) {
    return Transaction(
      id: id ?? this.id,
      member: member ?? this.member,
      date: date ?? this.date,
      time: time ?? this.time,
      amount: amount ?? this.amount,
      modeOfPayment: modeOfPayment ?? this.modeOfPayment,
      category: category ?? this.category,
      status: status ?? this.status,
      renewal: renewal ?? this.renewal,
      days: days ?? this.days,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      remarks: remarks ?? this.remarks,
    );
  }
}
