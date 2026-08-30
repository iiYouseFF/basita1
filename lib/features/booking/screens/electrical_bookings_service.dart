import 'package:basita1/core/network/mock_backend.dart';
// removed: cloud_firestore - see docs/backend-prd.html

class ElectricalBookingService {
  final dynamic _firestore = MockFirestore;

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
        'created_at': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }
}