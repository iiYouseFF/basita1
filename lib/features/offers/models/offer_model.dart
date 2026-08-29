// ملف: offer_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String technicianId;
  final String name;
  final double rating;
  final int reviewsCount;
  final int price;
  final int experienceYears;
  final String arrivalTime;
  final String imagePath;
  final bool isVerified;
  final bool hasGreenArrivalTag;
  final DateTime? timestamp;

  OfferModel({
    required this.id,
    required this.technicianId,
    required this.name,
    required this.rating,
    required this.reviewsCount,
    required this.price,
    required this.experienceYears,
    required this.arrivalTime,
    required this.imagePath,
    this.isVerified = false,
    this.hasGreenArrivalTag = false,
    this.timestamp,
  });

  // استخراج البيانات من Firebase
  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OfferModel(
      id: doc.id,
      technicianId: data['technicianId'] ?? '',
      name: data['name'] ?? 'فني مجهول',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      price: data['price'] ?? 0,
      experienceYears: data['experienceYears'] ?? 0,
      arrivalTime: data['arrivalTime'] ?? '',
      imagePath: data['imagePath'] ?? 'assets/images/default_avatar.png',
      isVerified: data['isVerified'] ?? false,
      hasGreenArrivalTag: data['hasGreenArrivalTag'] ?? false,
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // إرسال البيانات إلى Firebase (يُستخدم في تطبيق الفني)
  Map<String, dynamic> toMap() {
    return {
      'technicianId': technicianId,
      'name': name,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'price': price,
      'experienceYears': experienceYears,
      'arrivalTime': arrivalTime,
      'imagePath': imagePath,
      'isVerified': isVerified,
      'hasGreenArrivalTag': hasGreenArrivalTag,
      'timestamp': FieldValue.serverTimestamp(), // الوقت الفعلي من السيرفر
    };
  }
}
