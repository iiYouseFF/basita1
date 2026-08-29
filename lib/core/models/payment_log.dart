class PaymentLog {
  final String id;
  final String? firebaseRequestId;
  final String? firebaseUserId;
  final String? technicianId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? stripePaymentId;
  final Map<String, dynamic>? gatewayResponse;
  final DateTime? createdAt;

  PaymentLog({
    required this.id,
    this.firebaseRequestId,
    this.firebaseUserId,
    this.technicianId,
    required this.amount,
    this.currency = 'EGP',
    required this.paymentMethod,
    this.status = 'pending',
    this.stripePaymentId,
    this.gatewayResponse,
    this.createdAt,
  });

  factory PaymentLog.fromJson(Map<String, dynamic> json) {
    return PaymentLog(
      id: json['id'] ?? '',
      firebaseRequestId: json['firebase_request_id'],
      firebaseUserId: json['firebase_user_id'],
      technicianId: json['technician_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'EGP',
      paymentMethod: json['payment_method'] ?? 'card',
      status: json['status'] ?? 'pending',
      stripePaymentId: json['stripe_payment_id'],
      gatewayResponse: json['gateway_response'] is Map<String, dynamic>
          ? json['gateway_response']
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firebase_request_id': firebaseRequestId,
      'firebase_user_id': firebaseUserId,
      'technician_id': technicianId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'status': status,
    };
  }
}
