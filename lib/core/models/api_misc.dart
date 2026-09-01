class ApiNotification {
  final String? id;
  final String? userId;
  final String? userType;
  final String? title;
  final String? body;
  final String? type;
  final Map<String, dynamic>? data;
  final bool? isRead;
  final DateTime? createdAt;

  ApiNotification({
    this.id,
    this.userId,
    this.userType,
    this.title,
    this.body,
    this.type,
    this.data,
    this.isRead,
    this.createdAt,
  });

  factory ApiNotification.fromJson(Map<String, dynamic> json) {
    return ApiNotification(
      id: json['id']?.toString(),
      userId: json['userId'],
      userType: json['userType'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      data: json['data'],
      isRead: json['isRead'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
    };
  }
}

class ApiSupportTicket {
  final String? id;
  final String? userId;
  final String? userType;
  final String? subject;
  final String? description;
  final String? priority;
  final String? status;
  final String? adminReply;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiSupportTicket({
    this.id,
    this.userId,
    this.userType,
    this.subject,
    this.description,
    this.priority,
    this.status,
    this.adminReply,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiSupportTicket.fromJson(Map<String, dynamic> json) {
    return ApiSupportTicket(
      id: json['id']?.toString(),
      userId: json['userId'],
      userType: json['userType'],
      subject: json['subject'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      adminReply: json['adminReply'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userType': userType,
      'subject': subject,
      'description': description,
      'priority': priority,
    };
  }
}

class ApiReview {
  final String? id;
  final String? requestId;
  final String? reviewerId;
  final String? technicianId;
  final int? rating;
  final String? comment;
  final DateTime? createdAt;

  ApiReview({
    this.id,
    this.requestId,
    this.reviewerId,
    this.technicianId,
    this.rating,
    this.comment,
    this.createdAt,
  });

  factory ApiReview.fromJson(Map<String, dynamic> json) {
    return ApiReview(
      id: json['id']?.toString(),
      requestId: json['requestId'],
      reviewerId: json['reviewerId'],
      technicianId: json['technicianId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'reviewerId': reviewerId,
      'technicianId': technicianId,
      'rating': rating,
      'comment': comment,
    };
  }
}

class ApiVerification {
  final String? userId;
  final String? name;
  final String? phone;
  final String? email;
  final String? city;
  final String? governorate;
  final String? frontIdPath;
  final String? backIdPath;
  final String? status;
  final DateTime? reviewedAt;
  final DateTime? createdAt;

  ApiVerification({
    this.userId,
    this.name,
    this.phone,
    this.email,
    this.city,
    this.governorate,
    this.frontIdPath,
    this.backIdPath,
    this.status,
    this.reviewedAt,
    this.createdAt,
  });

  factory ApiVerification.fromJson(Map<String, dynamic> json) {
    return ApiVerification(
      userId: json['userId'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      city: json['city'],
      governorate: json['governorate'],
      frontIdPath: json['frontIdPath'],
      backIdPath: json['backIdPath'],
      status: json['status'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'city': city,
      'governorate': governorate,
      'frontIdPath': frontIdPath,
      'backIdPath': backIdPath,
    };
  }
}

class ApiFamilyMember {
  final String? id;
  final String? memberName;
  final String? memberPhone;
  final String? relationship;
  final DateTime? createdAt;

  ApiFamilyMember({
    this.id,
    this.memberName,
    this.memberPhone,
    this.relationship,
    this.createdAt,
  });

  factory ApiFamilyMember.fromJson(Map<String, dynamic> json) {
    return ApiFamilyMember(
      id: json['id']?.toString(),
      memberName: json['memberName'],
      memberPhone: json['memberPhone'],
      relationship: json['relationship'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberName': memberName,
      'memberPhone': memberPhone,
      'relationship': relationship,
    };
  }
}

class ApiSearchResult {
  final String? entityType;
  final String? entityId;
  final String? title;
  final String? description;
  final String? governorate;
  final String? specialty;
  final double? rank;

  ApiSearchResult({
    this.entityType,
    this.entityId,
    this.title,
    this.description,
    this.governorate,
    this.specialty,
    this.rank,
  });

  factory ApiSearchResult.fromJson(Map<String, dynamic> json) {
    return ApiSearchResult(
      entityType: json['entityType'],
      entityId: json['entityId'],
      title: json['title'],
      description: json['description'],
      governorate: json['governorate'],
      specialty: json['specialty'],
      rank: json['rank']?.toDouble(),
    );
  }
}

class ApiAiResponse {
  final String? answer;
  final String? serviceType;
  final double? estimatedCost;
  final String? currency;

  ApiAiResponse({
    this.answer,
    this.serviceType,
    this.estimatedCost,
    this.currency,
  });

  factory ApiAiResponse.fromJson(Map<String, dynamic> json) {
    return ApiAiResponse(
      answer: json['answer'],
      serviceType: json['serviceType'],
      estimatedCost: json['estimatedCost']?.toDouble(),
      currency: json['currency'],
    );
  }
}
