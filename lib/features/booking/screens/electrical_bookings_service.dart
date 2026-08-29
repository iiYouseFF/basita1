import 'package:cloud_firestore/cloud_firestore.dart';

class ElectricalBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // دالة حفظ البيانات في Firebase
  Future<void> saveBookingData({
    required String finishingType,
    required String roomsCount,
    required String budget,
    required String bookingDate,
    required String bookingTime,
    required String notes,
  }) async {
    try {
      await _firestore.collection('electrical_bookings').add({
        'finishing_type': finishingType,
        'rooms_count': roomsCount,
        'budget': budget,
        'booking_date': bookingDate,
        'booking_time': bookingTime,
        'notes': notes,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}