import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://xkffzkwrcnbuzvgaxrgy.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhrZmZ6a3dyY25idXp2Z2F4cmd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzOTczNDMsImV4cCI6MjA3Mzk3MzM0M30.t9BGFXQy_MUdy6JUBQge_XsJ05GqpNekTvloEuM7jyo'; // Replace with your actual anon key

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
