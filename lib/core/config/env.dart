// Basita env — reads from --dart-define, falls back to dev defaults.
// Usage: flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=... --dart-define=USE_MOCK_OTP=true
abstract class Env {
  // New Supabase project eczybgjywdppvyyygnrd (eu-west-1)
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://eczybgjywdppvyyygnrd.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjenliZ2p5d2RwcHZ5eXlnbnJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgwMDUyNDksImV4cCI6MjEwMzU4MTI0OX0.yFLpoefAdH7JOAgnJxakI-C6f8CWhidsWzy-sushly8',
  );

  // Legacy fallback (old project wduombkxwcqhipdumxmn) — kept for reference, not used
  static const legacySupabaseUrl = 'https://wduombkxwcqhipdumxmn.supabase.co';
}
