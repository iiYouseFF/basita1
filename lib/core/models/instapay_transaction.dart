class InstaPayTransaction {
  final String id;
  final String requestId;
  final String senderId;
  final String receiverId;
  final double amount;
  final String currency;
  final String? instapayCode;
  final String? verificationCode;
  final String status;
  final DateTime? verifiedAt;
  final DateTime? createdAt;

  InstaPayTransaction({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    this.currency = 'EGP',
    this.instapayCode,
    this.verificationCode,
    this.status = 'pending',
    this.verifiedAt,
    this.createdAt,
  });

  factory InstaPayTransaction.fromJson(Map<String, dynamic> json) {
    return InstaPayTransaction(
      id: json['id'] ?? '',
      requestId: json['request_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EGP',
      instapayCode: json['instapay_code'],
      verificationCode: json['verification_code'],
      status: json['status'] ?? 'pending',
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'amount': amount,
      'currency': currency,
      'instapay_code': instapayCode,
      'verification_code': verificationCode,
      'status': status,
    };
  }
}
