// Basita feature flags — external-backend edition.
// Firebase Phone Auth has been removed; OTP is now handled by your external backend
// (see docs/backend-prd.html § Auth). `useMockOtp` is kept as a dev bypass for UI testing.
abstract class AppConfig {
  /// When true, OTP screen accepts any 6 digits (dev/UI preview).
  /// Wire to real backend: POST /auth/verify-otp when false.
  static const useMockOtp = bool.fromEnvironment(
    'USE_MOCK_OTP',
    defaultValue: true,
  );

  static const seedOnStart = bool.fromEnvironment(
    'SEED_ON_START',
    defaultValue: false,
  );
}
