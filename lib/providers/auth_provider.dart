import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  List<String> _favorites = [];

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  List<String> get favorites => _favorites;

  void login(String email, {String name = '사용자', String phone = ''}) {
    _user = AppUser(
      name: name,
      email: email,
      phone: phone,
      points: 120,
      itemsFound: 3,
      avatar: '😊',
    );
    notifyListeners();
  }

  void logout() {
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
