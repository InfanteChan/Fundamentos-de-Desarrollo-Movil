class AppConfig {
  static const String supabaseUrl =
      String.fromEnvironment('https://gdpcokdgmedvpxzjzdjh.supabase.co', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('sb_secret_XGLQnWbK7vja6-r6Fb-GXA_sbOj31xd', defaultValue: '');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}