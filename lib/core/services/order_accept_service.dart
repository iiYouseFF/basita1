import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/core/repositories/chat_repository.dart';
import 'package:basita1/core/repositories/appointment_repository.dart';

/// تحويل السعر النصي (مثال: "٣٥٠ ج.م") إلى رقم عشري.
double? parsePriceText(String? price) {
  if (price == null || price.isEmpty) return null;
  final normalized = price
      .replaceAll('٠', '0')
      .replaceAll('١', '1')
      .replaceAll('٢', '2')
      .replaceAll('٣', '3')
      .replaceAll('٤', '4')
      .replaceAll('٥', '5')
      .replaceAll('٦', '6')
      .replaceAll('٧', '7')
      .replaceAll('٨', '8')
      .replaceAll('٩', '9');
  final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(normalized);
  return match != null ? double.tryParse(match.group(1)!) : null;
}

/// خدمة قبول الطلبات الموحدة.
/// تُستخدم في صفحة الطلبات وصفحة الطلبات الجديدة والخريطة لضمان استخدام
/// نفس منطق القبول (إنشاء عرض + تحديث الطلب + إنشاء محادثة + حجز موعد).
class OrderAcceptService {
  static String get _currentUserId => UserDataSession.phone.isNotEmpty
      ? UserDataSession.phone
      : (FirebaseAuth.instance.currentUser?.uid ?? 'unknown_uid');

  static String get _currentUserName => UserDataSession.fullName.isNotEmpty
      ? UserDataSession.fullName
      : (FirebaseAuth.instance.currentUser?.displayName ?? 'بسيطة | الفني');

  /// قبول الطلب بالسعر المعروض، أو بتقديم عرض سعر آخر عند تمرير [offerPrice].
  static Future<void> acceptRequest({
    required String requestId,
    required String clientPhone,
    required String serviceType,
    required String serviceName,
    required String clientAddress,
    required String requestPrice,
    String? offerPrice,
    String? duration,
    String? arrivalTime,
    String? warranty,
    String? message,
    bool provideMaterials = false,
    bool priceIncludesMaterials = false,
  }) async {
    final uid = _currentUserId;
    final techName = _currentUserName;

    final finalPrice = (offerPrice != null && offerPrice.trim().isNotEmpty)
        ? offerPrice.trim()
        : requestPrice;
    final finalMessage = (message != null && message.trim().isNotEmpty)
        ? message.trim()
        : 'أوافق على طلبك بالسعر المعروض.';
    final finalDuration = (duration != null && duration.trim().isNotEmpty)
        ? duration.trim()
        : 'غير محدد';
    final finalArrivalTime =
        (arrivalTime != null && arrivalTime.trim().isNotEmpty)
        ? arrivalTime.trim()
        : 'غير محدد';
    final finalWarranty = (warranty != null && warranty.trim().isNotEmpty)
        ? warranty.trim()
        : 'غير محدد';

    // 1) إنشاء العرض في Firebase
    await FirebaseFirestore.instance.collection('offers').add({
      'requestId': requestId,
      'technicianId': uid,
      'technicianName': techName,
      'price': finalPrice,
      'duration': finalDuration,
      'arrivalTime': finalArrivalTime,
      'warranty': finalWarranty,
      'message': finalMessage,
      'provideMaterials': provideMaterials,
      'priceIncludesMaterials': priceIncludesMaterials,
      'rating': 4.9,
      'reviewsCount': 15,
      'experienceYears': 4,
      'isVerified': true,
      'imagePath': 'assets/Container (8).png',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2) تحديث حالة الطلب إلى "offer_submitted"
    await FirebaseFirestore.instance.collection('requests').doc(requestId).set({
      'status': 'offer_submitted',
      'hasOffers': true,
      'technicianName': techName,
      'technicianId': uid,
      'acceptedPrice': finalPrice,
      'acceptedAt': FieldValue.serverTimestamp(),
      'clientAccepted': false,
      'lastOfferTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 3) إنشاء/تحديث المحادثة
    await ChatRepository().getOrCreateRoom(
      clientId: clientPhone,
      technicianId: uid,
      requestId: requestId,
      serviceType: serviceType,
    );

    // 4) إنشاء موعد (Supabase) ليظهر فوراً في مواعيد الفني
    try {
      await AppointmentRepository().upsertAppointmentOnAccept(
        requestId: requestId,
        clientId: clientPhone,
        technicianId: uid,
        serviceType: serviceType,
        serviceName: serviceName,
        clientAddress: clientAddress,
        price: parsePriceText(finalPrice),
      );
    } catch (e) {
      debugPrint("Error creating appointment: $e");
    }
  }
}
