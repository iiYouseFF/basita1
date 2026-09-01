class ApiServiceRequest {
  final String? id;
  final String? userId;
  final String? userName;
  final String? userPhone;
  final String? userGovernorate;
  final String? title;
  final String? description;
  final double? budget;
  final String? serviceType;
  final String? status;
  final DateTime? scheduledDate;
  final List<String>? images;
  final bool? hasOffers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiServiceRequest({
    this.id,
    this.userId,
    this.userName,
    this.userPhone,
    this.userGovernorate,
    this.title,
    this.description,
    this.budget,
    this.serviceType,
    this.status,
    this.scheduledDate,
    this.images,
    this.hasOffers,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiServiceRequest.fromJson(Map<String, dynamic> json) {
    return ApiServiceRequest(
      id: json['id']?.toString(),
      userId: json['userId'],
      userName: json['userName'],
      userPhone: json['userPhone'],
      userGovernorate: json['userGovernorate'],
      title: json['title'],
      description: json['description'],
      budget: json['budget']?.toDouble(),
      serviceType: json['serviceType'],
      status: json['status'],
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      hasOffers: json['hasOffers'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userGovernorate': userGovernorate,
      'title': title,
      'description': description,
      'budget': budget,
      'serviceType': serviceType,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'images': images,
    };
  }
}
