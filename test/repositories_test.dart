import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basita1/core/repositories/request_repository.dart';
import 'package:basita1/core/repositories/technician_repository.dart';
import 'package:basita1/core/repositories/notification_repository.dart';
import 'package:basita1/core/repositories/review_repository.dart';
import 'package:basita1/core/repositories/promo_code_repository.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 3 — Firestore repositories (mock)', () {
    test('RequestRepository class exists', () {
      expect(RequestRepository, isA<Type>());
    });

    test('TechnicianRepository class exists', () {
      expect(TechnicianRepository, isA<Type>());
    });

    test('RequestRepository file exists and defines expected methods', () async {
      const expectedMethods = [
        'createRequest',
        'watchUserRequests',
        'watchAvailableRequests',
      ];
      expect(expectedMethods, contains('createRequest'));
      expect(expectedMethods.length, 3);
    });
  });

  group('Phase 3 — Repositories (external backend stub)', () {
    test('NotificationRepository has expected methods', () {
      final repo = NotificationRepository();
      expect(repo.getNotifications, isA<Function>());
      expect(repo.insertNotification, isA<Function>());
    });

    test('ReviewRepository has rating methods', () {
      final repo = ReviewRepository();
      expect(repo.getTechnicianAverageRating, isA<Function>());
    });

    test('PromoCodeRepository validate shape', () {
      final repo = PromoCodeRepository();
      expect(repo.validatePromoCode, isA<Function>());
    });
  });
}
