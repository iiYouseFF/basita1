// Supabase env — kept for CI verify-backend + legacy fallback.
// Primary config is now ApiConfig (http://basseeyta.duckdns.org) via --dart-define=API_BASE_URL.
// See lib/core/network/api_config.dart and https://github.com/iiYouseFF/basseeyta

@Deprecated(
  'Use ApiConfig from lib/core/network/api_config.dart instead — kept for CI',
)
abstract class Env {
  // CI checks for this string: eczybgjywdppvyyygnrd
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://eczybgjywdppvyyygnrd.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjenliZ2p5d2RwcHZ5eXlnbnJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgwMDUyNDksImV4cCI6MjEwMzU4MTI0OX0.yFLpoefAdH7JOAgnJxakI-C6f8CWhidsWzy-sushly8',
  );
  static const legacySupabaseUrl = 'https://wduombkxwcqhipdumxmn.supabase.co';
}
