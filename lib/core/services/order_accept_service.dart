import 'package:flutter/foundation.dart';
import 'package:basita1/core/session/user_data_session.dart';
import 'package:basita1/core/repositories/chat_repository.dart';
import 'package:basita1/core/repositories/appointment_repository.dart';

// Previously directly wrote to Firestore `offers`/`requests` and dynamic `appointments`.
// Now mock-only; external backend will handle transactional accept.
// See docs/backend-prd.html § Service Requests & Offers — POST /service-requests/{id}/offers and /service-requests/{id}/accept
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

class OrderAcceptService {
  static String get _currentUserId =>
      UserDataSession.phone.isNotEmpty ? UserDataSession.phone : 'mock_uid';
  static String get _currentUserName => UserDataSession.fullName.isNotEmpty
      ? UserDataSession.fullName
      : 'بسيطة | الفني';

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

    // TODO(backend): POST /service-requests/$requestId/offers
    // await ApiClient().post('/service-requests/$requestId/offers', body: {
    //   'technicianId': uid, 'technicianName': techName, 'price': finalPrice, ...
    // });
    // TODO(backend): PATCH /service-requests/$requestId {status: 'offer_submitted'}
    debugPrint(
      '[OrderAcceptService] MOCK accept $requestId price=$finalPrice tech=$uid ($techName) — backend not connected',
    );

    try {
      await ChatRepository().getOrCreateRoom(
        clientId: clientPhone,
        technicianId: uid,
        requestId: requestId,
        serviceType: serviceType,
      );
    } catch (e) {
      debugPrint('[OrderAcceptService] chat mock: $e');
    }

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
      debugPrint('[OrderAcceptService] appointment mock: $e');
    }
  }
}
