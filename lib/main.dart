import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable simulated phone frame in debug mode
  if (kDebugMode) {
    DevicePreview.enable();
    DevicePreview.maybeController?.applyPreset(DevicePresets.iPhone17ProMax);
  }

  // Safely attempt to load .env if present
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    if (kDebugMode) {
      print('.env file not found, running in zero-cost standalone mode.');
    }
  }

  // Initialize Supabase if credentials are provided
  try {
    await SupabaseService.initialize();
  } catch (e) {
    if (kDebugMode) {
      print('Supabase init skipped/failed: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: KainWiseApp(),
    ),
  );
}
