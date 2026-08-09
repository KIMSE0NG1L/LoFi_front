import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'supabase_client.dart';

class AuthService {
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user == null) {
        throw const AppException('이메일 또는 비밀번호가 올바르지 않습니다.');
      }
      return _fetchProfile(res.user!.id, email);
    } on AuthException catch (_) {
      throw const AppException('이메일 또는 비밀번호가 올바르지 않습니다.');
    }
  }

  Future<AppUser> signup({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String gender = 'male',
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'gender': gender},
      );
      final user = res.user;
      if (user == null) {
        throw const AppException('회원가입에 실패했습니다.');
      }
      if (res.session == null) {
        // Supabase 프로젝트의 Auth > Confirm email 설정이 켜져 있으면
        // 세션 없이 확인 메일 발송만 되고 즉시 로그인되지 않습니다.
        throw const AppException('이메일 인증이 필요합니다. 메일함을 확인해주세요.');
      }

      if (phone.isNotEmpty) {
        await supabase.from('profiles').update({'phone': phone}).eq('id', user.id);
      }

      return _fetchProfile(user.id, email);
    } on AuthException catch (e) {
      final status = e.message.toLowerCase().contains('already') ? '이미 가입된 이메일입니다.' : e.message;
      throw AppException(status);
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  /// 서버의 delete_user RPC(security definer)로 본인 계정과 데이터를
  /// 실제로 삭제한다. 삭제 후에는 세션도 즉시 정리한다.
  Future<void> deleteAccount() async {
    try {
      await supabase.rpc('delete_user');
    } finally {
      await supabase.auth.signOut();
    }
  }

  /// 소셜로그인 — 외부 브라우저에서 진행되고, 완료되면 딥링크로 앱에 돌아와
  /// onAuthStateChange 스트림으로 세션이 통지된다 (여기서 완료를 기다리지 않음).
  Future<void> signInWithOAuth(OAuthProvider provider, {String? scopes}) async {
    await supabase.auth.signInWithOAuth(
      provider,
      redirectTo: 'guhaejo://login-callback/',
      authScreenLaunchMode: LaunchMode.externalApplication,
      scopes: scopes,
    );
  }

  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;

  Future<AppUser?> restoreSession() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    try {
      return await _fetchProfile(user.id, user.email ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<AppUser> me({required String email}) async {
    final uid = currentUserId;
    if (uid == null) throw const AppException('로그인이 필요합니다.');
    return _fetchProfile(uid, email);
  }

  Future<AppUser> _fetchProfile(String id, String email) async {
    final json = await supabase.from('profiles').select().eq('id', id).single();
    return _userFromJson(json, email);
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
      gender: json['gender'] as String? ?? 'male',
    );
  }
}
