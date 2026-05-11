import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  runApp(MainApp(onboardingDone: onboardingDone));
}

class MainApp extends StatelessWidget {
  final bool onboardingDone;
  const MainApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    if (!onboardingDone) {
      return MaterialApp(
        title: '옛다 띱!',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const OnboardingScreen(),
      );
    }
    return const App();
  }
}
