import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_page.dart';
import 'screens/lost_items_page.dart';
import 'screens/register_found_page.dart';
import 'screens/register_lost_page.dart';
import 'screens/ranking_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/profile_page.dart';
import 'screens/account_settings_page.dart';
import 'screens/chat_list_page.dart';
import 'screens/chat_page.dart';
import 'screens/map_page.dart';
import 'screens/favorites_page.dart';
import 'screens/shop_page.dart';
import 'widgets/bottom_nav.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

GoRouter _buildRouter(bool onboardingDone) => GoRouter(
      navigatorKey: _rootKey,
      initialLocation: onboardingDone ? '/' : '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (ctx, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellKey,
          builder: (ctx, state, child) {
            final location = state.uri.toString();
            final noNavPaths = ['/login', '/signup', '/profile', '/account-settings', '/chat/'];
            final hideNav = noNavPaths.any((p) => location.startsWith(p));
            return Scaffold(
              body: child,
              bottomNavigationBar: hideNav ? null : const BottomNav(),
            );
          },
          routes: [
            GoRoute(path: '/', builder: (ctx, state) => const HomePage()),
            GoRoute(path: '/lost-items', builder: (ctx, state) => const LostItemsPage()),
            GoRoute(path: '/register-found', builder: (ctx, state) => const RegisterFoundPage()),
            GoRoute(path: '/register-lost', builder: (ctx, state) => const RegisterLostPage()),
            GoRoute(path: '/ranking', builder: (ctx, state) => const RankingPage()),
            GoRoute(path: '/login', builder: (ctx, state) => const LoginPage()),
            GoRoute(path: '/signup', builder: (ctx, state) => const SignupPage()),
            GoRoute(path: '/profile', builder: (ctx, state) => const ProfilePage()),
            GoRoute(path: '/account-settings', builder: (ctx, state) => const AccountSettingsPage()),
            GoRoute(path: '/chats', builder: (ctx, state) => const ChatListPage()),
            GoRoute(
              path: '/chat/:id',
              builder: (ctx, state) => ChatPage(chatId: state.pathParameters['id']!),
            ),
            GoRoute(path: '/map', builder: (ctx, state) => const MapPage()),
            GoRoute(path: '/favorites', builder: (ctx, state) => const FavoritesPage()),
            GoRoute(path: '/shop', builder: (ctx, state) => const ShopPage()),
          ],
        ),
      ],
    );

class App extends StatefulWidget {
  final bool onboardingDone;
  const App({super.key, this.onboardingDone = true});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = _buildRouter(widget.onboardingDone);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp.router(
        title: '옛다 띱!',
        theme: AppTheme.theme,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
