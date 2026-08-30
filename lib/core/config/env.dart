// REMOVED — Firebase/dynamic env is no longer used.
// The external backend is configured via `lib/core/network/api_config.dart`
// using --dart-define=API_BASE_URL and --dart-define=API_KEY.
//
// This stub is kept only to avoid breaking imports in files that haven't
// been migrated yet. New code should NOT import this file.

@Deprecated('Use ApiConfig from lib/core/network/api_config.dart instead')
abstract class Env {
  @Deprecated('Use ApiConfig.baseUrl')
  static const supabaseUrl = '';
  @Deprecated('No longer used')
  static const supabaseAnonKey = '';
  static const legacySupabaseUrl = '';
}
