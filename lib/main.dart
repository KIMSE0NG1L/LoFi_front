import 'package:flutter/material.dart';
import 'providers/auth_provider.dart';
import 'services/supabase_client.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  final authProvider = AuthProvider();
  authProvider.listenAuthChanges();
  await authProvider.tryRestoreSession();

  runApp(App(authProvider: authProvider));
}
