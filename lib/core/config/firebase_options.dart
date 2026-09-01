// REMOVED — Firebase is no longer used.
// See lib/core/network/api_config.dart and docs/backend-prd.html
// This stub exists only to prevent import errors in legacy files.

@Deprecated('Firebase removed — use ApiConfig / ApiClient instead')
class DefaultFirebaseOptions {
  @Deprecated('Firebase removed')
  static dynamic get currentPlatform => throw UnsupportedError(
    'Firebase removed. Configure external backend via ApiConfig.baseUrl.',
  );
}
