import '../models/models.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final data =
        await _api.post(
              '/auth/login',
              body: {'email': email, 'password': password},
            )
            as Map<String, dynamic>;

    await _api.saveToken(data['token'] as String);
    return _userFromJson(data['user'] as Map<String, dynamic>, email);
  }

  Future<AppUser> signup({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final data =
        await _api.post(
              '/auth/signup',
              body: {
                'name': name,
                'email': email,
                'password': password,
                'phone': phone,
              },
            )
            as Map<String, dynamic>;

    await _api.saveToken(data['token'] as String);
    return _userFromJson(data['user'] as Map<String, dynamic>, email);
  }

  Future<void> logout() => _api.clearToken();

  Future<AppUser> me({required String email}) async {
    final data = await _api.get('/users/me') as Map<String, dynamic>;
    return _userFromJson(data, email);
  }

  AppUser _userFromJson(Map<String, dynamic> json, String email) {
    return AppUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? email.split('@').first,
      email: email,
      phone: json['phone'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      itemsFound: json['items_found'] as int? ?? 0,
      avatar: json['avatar'] as String? ?? '',
    );
  }
}
