// Basita feature flags — all via --dart-define so prod can flip without code change.
abstract class AppConfig {
  /// When true (default for dev), OTP screen accepts any 6 digits and skips
  /// Firebase verifyPhoneNumber. Required by PROMPT.MD:1.
  /// Prod: --dart-define=USE_MOCK_OTP=false
  static const useMockOtp = bool.fromEnvironment('USE_MOCK_OTP', defaultValue: true);

  /// Optional: seed data on first run
  static const seedOnStart = bool.fromEnvironment('SEED_ON_START', defaultValue: false);
}
