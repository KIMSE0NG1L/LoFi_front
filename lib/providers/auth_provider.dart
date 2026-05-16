import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService(ApiClient.instance);

  AppUser? _user;
  List<String> _favorites = [];

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  List<String> get favorites => _favorites;

  Future<void> login(String email, String password) async {
    _user = await _authService.login(email: email, password: password);
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
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _favorites = [];
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
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

  void updateUser({String? name, String? email, String? phone, String? avatar}) {
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
