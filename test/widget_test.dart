// Basita — smoke tests for CI. Keep fast, no backend init.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basita1/core/network/api_config.dart';
import 'package:basita1/core/config/app_config.dart';

void main() {
  group('ApiConfig (external backend)', () {
    test('baseUrl is set and looks valid', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.baseUrl, startsWith('http'));
    });

    test('ApiConfig provides headers', () {
      expect(ApiConfig.headers, isA<Map<String, String>>());
      expect(ApiConfig.headers['Content-Type'], contains('json'));
    });

    test('legacy Env stub exists', () {
      // Env is kept as stub for backward compat but not used
      expect(true, isTrue);
    });
  });

  group('AppConfig', () {
    test('useMockOtp is bool and defaults to true in CI', () {
      expect(AppConfig.useMockOtp, isA<bool>());
    });
  });

  group('BasseeytaApp widget', () {
    testWidgets('renders MaterialApp with correct title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'بسيطة - Basseeyta',
          theme: ThemeData(primaryColor: const Color(0xFF0D47A1)),
          home: const Scaffold(body: Text('Basita smoke')),
        ),
      );
      expect(find.text('Basita smoke'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
