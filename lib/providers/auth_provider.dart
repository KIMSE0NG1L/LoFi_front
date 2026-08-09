import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider, AuthChangeEvent;

import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/items_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ItemsService _itemsService = ItemsService();
  StreamSubscription? _authSub;

  AppUser? _user;
  List<String> _favorites = [];

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  List<String> get favorites => _favorites;

  Future<void> tryRestoreSession() async {
    final user = await _authService.restoreSession();
    if (user == null) return;
    _user = user;
    await loadFavorites();
    notifyListeners();
  }

  /// 소셜로그인은 외부 브라우저 redirect로 비동기 완료되므로, 세션 변화를
  /// 구독해뒀다가 로그인이 완료되면 프로필을 불러와 반영한다.
  void listenAuthChanges() {
    _authSub?.cancel();
    _authSub = _authService.onAuthStateChange.listen((state) async {
      if (state.event == AuthChangeEvent.signedIn && state.session != null) {
        final email = state.session!.user.email ?? '';
        try {
          _user = await _authService.me(email: email);
          await loadFavorites();
          notifyListeners();
        } catch (e) {
          debugPrint('소셜로그인 후 프로필 로딩 실패: $e');
        }
      } else if (state.event == AuthChangeEvent.signedOut) {
        _user = null;
        _favorites = [];
        notifyListeners();
      }
    });
  }

  Future<void> loginWithKakao() => _authService.signInWithOAuth(OAuthProvider.kakao);

  Future<void> loginWithGoogle() => _authService.signInWithOAuth(OAuthProvider.google);

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> login(String email, String password) async {
    _user = await _authService.login(email: email, password: password);
    await loadFavorites();
    notifyListeners();
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String gender = 'male',
  }) async {
    _user = await _authService.signup(
      name: name,
      email: email,
      password: password,
      phone: phone,
      gender: gender,
    );
    await loadFavorites();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _favorites = [];
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    if (!isLoggedIn) return;
    final items = await _itemsService.fetchFavorites();
    _favorites = items.map((item) => item.id).toList();
  }

  Future<void> toggleFavorite(String id) async {
    if (!isLoggedIn) return;
    final wasFavorite = _favorites.contains(id);
    if (wasFavorite) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();

    try {
      final favorited = await _itemsService.toggleFavorite(id);
      if (favorited && !_favorites.contains(id)) {
        _favorites.add(id);
      }
      if (!favorited) {
        _favorites.remove(id);
      }
    } catch (_) {
      if (wasFavorite && !_favorites.contains(id)) {
        _favorites.add(id);
      }
      if (!wasFavorite) {
        _favorites.remove(id);
      }
    }
    notifyListeners();
  }

  bool isFavorite(String id) => _favorites.contains(id);

  bool spendPoints(int amount) {
    if (_user == null || _user!.points < amount) return false;
    _user = _user!.copyWith(points: _user!.points - amount);
    notifyListeners();
    return true;
  }

  void addPoints(int amount) {
    if (_user == null) return;
    _user = _user!.copyWith(points: _user!.points + amount);
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_user == null) return;
    _user = await _authService.me(email: _user!.email);
    notifyListeners();
  }

  void updateUser({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(
      name: name,
      email: email,
      phone: phone,
      avatar: avatar,
    );
    notifyListeners();
  }

  void deleteAccount() {
    _user = null;
    _favorites = [];
    notifyListeners();
  }
}
