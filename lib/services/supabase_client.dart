import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase project 생성 후 실제 값으로 교체하거나
// `--dart-define=SUPABASE_URL=...` / `--dart-define=SUPABASE_ANON_KEY=...` 로 오버라이드.
const String _defaultSupabaseUrl = 'https://npvtlwwjxmdbkudetuio.supabase.co';
const String _defaultSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wdnRsd3dqeG1kYmt1ZGV0dWlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUyNTUyNTksImV4cCI6MjEwMDgzMTI1OX0.OOenFiAW1Erpy1J1KpLVjSRgh5f-faJLuLtAosbY58E';

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

Future<void> initSupabase() async {
  const url = String.fromEnvironment('SUPABASE_URL');
  const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  await Supabase.initialize(
    url: url.isNotEmpty ? url : _defaultSupabaseUrl,
    anonKey: anonKey.isNotEmpty ? anonKey : _defaultSupabaseAnonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;

String? get currentUserId => supabase.auth.currentUser?.id;
