import 'package:flutter/foundation.dart';
import 'package:pizzeria/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBootstrap {
  static bool isReady = false;

  static Future<void> init() async {
    if (!AppConfig.isSupabaseConfigured || isReady) return;
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      isReady = true;
    } catch (e) {
      debugPrint('Error al iniciar Supabase: $e');
    }
  }
}