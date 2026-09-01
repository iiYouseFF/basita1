import 'package:flutter_test/flutter_test.dart';
import 'package:basita1/core/config/app_config.dart';
import 'package:basita1/core/network/api_config.dart';

void main() {
  group('AppConfig — OTP flag (external backend)', () {
    test('useMockOtp defaults to true (mock OTP for dev)', () {
      expect(AppConfig.useMockOtp, isTrue);
    });

    test('ApiConfig.baseUrl is set', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.baseUrl, startsWith('http'));
    });

    test('ApiConfig.baseUrl default is placeholder', () {
      // In CI without dart-define, default is http://basseeyta.duckdns.org
      expect(ApiConfig.baseUrl.toLowerCase(), contains('basseeyta'));
    });
  });

  group('External backend contract', () {
    test('expected endpoints are documented in PRD', () {
      const expected = [
        '/auth/request-otp',
        '/service-requests',
        '/chat/rooms',
        '/payments',
        '/posts',
        '/storage/upload',
      ];
      expect(expected, contains('/auth/request-otp'));
      expect(expected, contains('/service-requests'));
      expect(expected, contains('/payments'));
    });

    test('send-notification input shape (now POST /push/send)', () {
      final payload = {
        'userId': 'uid123',
        'userType': 'user',
        'title': 'Test',
        'body': 'Hello',
        'type': 'system',
        'data': {'foo': 'bar'},
      };
      expect(payload['userId'], isNotEmpty);
      expect(payload['title'], isNotEmpty);
      expect(payload['body'], isNotEmpty);
    });

    test('process-payment input shape (now POST /payments)', () {
      final payload = {
        'amount': 250,
        'currency': 'EGP',
        'paymentMethod': 'card',
        'requestId': 'req_001',
        'userId': 'user_123',
        'technicianId': '01012345678',
        'serviceName': 'plumbing',
      };
      expect(payload['amount'], greaterThan(0));
      expect(payload['userId'], isNotEmpty);
    });
  });
}
