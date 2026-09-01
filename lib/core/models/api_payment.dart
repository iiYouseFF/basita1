class ApiPaymentCard {
  final String? id;
  final String? userId;
  final String? cardLast4;
  final String? cardHolder;
  final String? expiryDate;
  final String? cardType;
  final bool? isDefault;
  final DateTime? createdAt;

  ApiPaymentCard({
    this.id,
    this.userId,
    this.cardLast4,
    this.cardHolder,
    this.expiryDate,
    this.cardType,
    this.isDefault,
    this.createdAt,
  });

  factory ApiPaymentCard.fromJson(Map<String, dynamic> json) {
    return ApiPaymentCard(
      id: json['id']?.toString(),
      userId: json['userId'],
      cardLast4: json['cardLast4'],
      cardHolder: json['cardHolder'],
      expiryDate: json['expiryDate'],
      cardType: json['cardType'],
      isDefault: json['isDefault'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'cardLast4': cardLast4,
      'cardHolder': cardHolder,
      'expiryDate': expiryDate,
      'cardType': cardType,
      'isDefault': isDefault,
    };
  }
}

class ApiPayment {
  final String? id;
  final String? userId;
  final String? technicianId;
  final String? requestId;
  final double? amount;
  final String? paymentMethod;
  final String? status;
  final String? promoCode;
  final String? serviceName;
  final DateTime? createdAt;

  ApiPayment({
    this.id,
    this.userId,
    this.technicianId,
    this.requestId,
    this.amount,
    this.paymentMethod,
    this.status,
    this.promoCode,
    this.serviceName,
    this.createdAt,
  });

  factory ApiPayment.fromJson(Map<String, dynamic> json) {
    return ApiPayment(
      id: json['id']?.toString(),
      userId: json['userId'],
      technicianId: json['technicianId'],
      requestId: json['requestId'],
      amount: json['amount']?.toDouble(),
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      promoCode: json['promoCode'],
      serviceName: json['serviceName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'technicianId': technicianId,
      'requestId': requestId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'promoCode': promoCode,
      'serviceName': serviceName,
    };
  }
}

class ApiInstapayTransaction {
  final String? id;
  final String? userId;
  final String? technicianId;
  final String? requestId;
  final double? amount;
  final String? verificationCode;
  final String? status;
  final DateTime? createdAt;

  ApiInstapayTransaction({
    this.id,
    this.userId,
    this.technicianId,
    this.requestId,
    this.amount,
    this.verificationCode,
    this.status,
    this.createdAt,
  });

  factory ApiInstapayTransaction.fromJson(Map<String, dynamic> json) {
    return ApiInstapayTransaction(
      id: json['id']?.toString(),
      userId: json['userId'],
      technicianId: json['technicianId'],
      requestId: json['requestId'],
      amount: json['amount']?.toDouble(),
      verificationCode: json['verificationCode'],
      status: json['status'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'technicianId': technicianId,
      'requestId': requestId,
      'amount': amount,
    };
  }
}

class ApiPromoCode {
  final String? id;
  final String? code;
  final double? discount;
  final String? discountType;
  final double? minAmount;
  final int? maxUses;
  final int? usedCount;
  final DateTime? validUntil;
  final bool? isActive;

  ApiPromoCode({
    this.id,
    this.code,
    this.discount,
    this.discountType,
    this.minAmount,
    this.maxUses,
    this.usedCount,
    this.validUntil,
    this.isActive,
  });

  factory ApiPromoCode.fromJson(Map<String, dynamic> json) {
    return ApiPromoCode(
      id: json['id']?.toString(),
      code: json['code'],
      discount: json['discount']?.toDouble(),
      discountType: json['discountType'],
      minAmount: json['minAmount']?.toDouble(),
      maxUses: json['maxUses'],
      usedCount: json['usedCount'],
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil']) : null,
      isActive: json['isActive'],
    );
  }
}
