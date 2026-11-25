/// Backend configuration.
///
/// Values can be overridden at build time:
///   flutter run --dart-define=SUPABASE_ANON_KEY=xxxx
/// If the anon key is empty the app runs on in-memory FAKE data
/// (useful for UI work without a backend).
library;

const String kSupabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://lrlwzgolzckcaiahjhoh.supabase.co',
);

/// Publishable (client-side) key – safe to ship; data is protected by RLS.
const String kSupabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_UXu7MatcMbopR4KEBrWdPg_lgccv1jF',
);

/// Force fake mode even if a key is present: --dart-define=FAKE_BACKEND=true
const bool kForceFake = bool.fromEnvironment('FAKE_BACKEND', defaultValue: false);

bool get kUseFakeBackend => kForceFake || kSupabaseAnonKey.isEmpty;
