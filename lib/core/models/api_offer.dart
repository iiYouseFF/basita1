class ApiOffer {
  final String? id;
  final String? requestId;
  final String? technicianId;
  final String? technicianName;
  final double? price;
  final String? message;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiOffer({
    this.id,
    this.requestId,
    this.technicianId,
    this.technicianName,
    this.price,
    this.message,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiOffer.fromJson(Map<String, dynamic> json) {
    return ApiOffer(
      id: json['id']?.toString(),
      requestId: json['requestId'],
      technicianId: json['technicianId'],
      technicianName: json['technicianName'],
      price: json['price']?.toDouble(),
      message: json['message'],
      status: json['status'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'technicianId': technicianId,
      'price': price,
      'message': message,
    };
  }
}
