import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String _getValue(String key, String compileTimeFallback) {
    try {
      if (dotenv.isInitialized) {
        final val = dotenv.maybeGet(key);
        if (val != null && val.isNotEmpty) return val;
      }
    } catch (_) {}
    return compileTimeFallback;
  }

  static String get supabaseUrl {
    return _getValue(
      'SUPABASE_URL',
      const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    );
  }

  static String get supabaseAnonKey {
    return _getValue(
      'SUPABASE_ANON_KEY',
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
    );
  }

  static String get aiBackendUrl {
    return _getValue(
      'AI_BACKEND_URL',
      const String.fromEnvironment('AI_BACKEND_URL', defaultValue: ''),
    );
  }

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
