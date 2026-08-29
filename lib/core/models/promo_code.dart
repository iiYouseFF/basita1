class PromoCode {
  final String id;
  final String code;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final int? maxUses;
  final int usedCount;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final bool isActive;

  PromoCode({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount = 0,
    this.maxUses,
    this.usedCount = 0,
    this.validFrom,
    this.validUntil,
    this.isActive = true,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      discountType: json['discount_type'] ?? 'percentage',
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      minOrderAmount: (json['min_order_amount'] ?? 0).toDouble(),
      maxUses: json['max_uses'],
      usedCount: json['used_count'] ?? 0,
      validFrom: json['valid_from'] != null
          ? DateTime.tryParse(json['valid_from'])
          : null,
      validUntil: json['valid_until'] != null
          ? DateTime.tryParse(json['valid_until'])
          : null,
      isActive: json['is_active'] ?? true,
    );
  }

  double calculateDiscount(double orderAmount) {
    if (!isActive) return 0;
    if (orderAmount < minOrderAmount) return 0;
    if (maxUses != null && usedCount >= maxUses!) return 0;

    if (discountType == 'percentage') {
      return orderAmount * (discountValue / 100);
    }
    return discountValue;
  }
}
