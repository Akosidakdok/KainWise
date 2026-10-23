import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely attempt to load .env if present
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    debugPrint('.env file not found, falling back to environment or defaults.');
  }

  // Initialize Supabase if credentials are provided
  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: KainWiseApp(),
    ),
  );
}
