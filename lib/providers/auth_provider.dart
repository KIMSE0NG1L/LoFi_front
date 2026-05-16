import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/items_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService(ApiClient.instance);
  final ItemsService _itemsService = ItemsService(ApiClient.instance);

  AppUser? _user;
  List<String> _favorites = [];

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  List<String> get favorites => _favorites;

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
  }) async {
    _user = await _authService.signup(
      name: name,
      email: email,
      password: password,
      phone: phone,
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
