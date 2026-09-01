class ApiUser {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? governorate;
  final String? city;
  final String? region;
  final String? placeType;
  final String? profileImageUrl;
  final String? userType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiUser({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.governorate,
    this.city,
    this.region,
    this.placeType,
    this.profileImageUrl,
    this.userType,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id']?.toString(),
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      governorate: json['governorate'],
      city: json['city'],
      region: json['region'],
      placeType: json['placeType'],
      profileImageUrl: json['profileImageUrl'],
      userType: json['userType'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'governorate': governorate,
      'city': city,
      'region': region,
      'placeType': placeType,
      'profileImageUrl': profileImageUrl,
      'userType': userType,
    };
  }
}

class ApiTechnician {
  final String? phone;
  final String? fullName;
  final String? experience;
  final String? specialty;
  final String? governorate;
  final String? area;
  final String? profileImageUrl;
  final double? avgRating;
  final int? totalReviews;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ApiTechnician({
    this.phone,
    this.fullName,
    this.experience,
    this.specialty,
    this.governorate,
    this.area,
    this.profileImageUrl,
    this.avgRating,
    this.totalReviews,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiTechnician.fromJson(Map<String, dynamic> json) {
    return ApiTechnician(
      phone: json['phone'],
      fullName: json['fullName'],
      experience: json['experience'],
      specialty: json['specialty'],
      governorate: json['governorate'],
      area: json['area'],
      profileImageUrl: json['profileImageUrl'],
      avgRating: json['avgRating']?.toDouble(),
      totalReviews: json['totalReviews'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'fullName': fullName,
      'experience': experience,
      'specialty': specialty,
      'governorate': governorate,
      'area': area,
      'profileImageUrl': profileImageUrl,
    };
  }
}

class ApiTechnicianWallet {
  final String? technicianPhone;
  final double? balance;
  final double? totalEarned;
  final double? totalWithdrawn;
  final DateTime? lastUpdated;

  ApiTechnicianWallet({
    this.technicianPhone,
    this.balance,
    this.totalEarned,
    this.totalWithdrawn,
    this.lastUpdated,
  });

  factory ApiTechnicianWallet.fromJson(Map<String, dynamic> json) {
    return ApiTechnicianWallet(
      technicianPhone: json['technicianPhone'],
      balance: json['balance']?.toDouble(),
      totalEarned: json['totalEarned']?.toDouble(),
      totalWithdrawn: json['totalWithdrawn']?.toDouble(),
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
    );
  }
}
