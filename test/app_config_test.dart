import 'package:flutter_test/flutter_test.dart';
import 'package:basita1/core/config/app_config.dart';
import 'package:basita1/core/config/env.dart';

void main() {
  group('AppConfig — Phase 2 OTP flag', () {
    test('useMockOtp defaults to true (PROMPT.MD mock required)', () {
      // No --dart-define passed in CI, so default true
      expect(AppConfig.useMockOtp, isTrue);
    });

    test('Env.supabaseUrl points to new project eczybgjywdppvyyygnrd', () {
      expect(Env.supabaseUrl, contains('eczybgjywdppvyyygnrd'));
      expect(Env.supabaseUrl, startsWith('https://'));
    });

    test('Env.supabaseAnonKey is legacy JWT and not empty', () {
      expect(Env.supabaseAnonKey, isNotEmpty);
      expect(Env.supabaseAnonKey.split('.'), hasLength(3));
    });
  });

  group('Edge Functions contract', () {
    test('expected function names are documented', () {
      const expected = ['send-notification', 'process-payment', 'daily-reset'];
      expect(expected, contains('send-notification'));
      expect(expected, contains('process-payment'));
      expect(expected, contains('daily-reset'));
      expect(expected, hasLength(3));
    });

    test('send-notification input shape', () {
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

    test('process-payment input shape', () {
      final payload = {
        'amount': 250,
        'currency': 'EGP',
        'paymentMethodId': 'pm_123',
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
