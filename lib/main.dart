import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/auth_provider.dart';
import 'services/supabase_client.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  final authProvider = AuthProvider();
  await authProvider.tryRestoreSession();

  runApp(App(onboardingDone: onboardingDone, authProvider: authProvider));
}
