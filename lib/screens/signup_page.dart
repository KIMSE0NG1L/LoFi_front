import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();
  bool _showPw = false;
  bool _agreeTerms = false;
  bool _agreePrivacy = false;

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _pwCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 필드를 입력해주세요')));
      return;
    }
    if (_pwCtrl.text != _pwConfirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다')));
      return;
    }
    if (!_agreeTerms || !_agreePrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('약관에 동의해주세요')));
      return;
    }
    try {
      await context.read<AuthProvider>().signup(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _pwCtrl.text,
        phone: _phoneCtrl.text,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다! 🎉')));
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('회원가입', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _section('기본 정보', [
              _field('이름', _nameCtrl, '이름을 입력하세요', Icons.person_outline),
              _field('이메일', _emailCtrl, '이메일을 입력하세요', Icons.email_outlined, type: TextInputType.emailAddress),
              _field('전화번호 (선택)', _phoneCtrl, '010-0000-0000', Icons.phone_outlined, type: TextInputType.phone),
            ]),
            const SizedBox(height: 16),
            _section('비밀번호', [
              _field('비밀번호', _pwCtrl, '8자 이상 입력하세요', Icons.lock_outline, obscure: !_showPw),
              _field('비밀번호 확인', _pwConfirmCtrl, '비밀번호를 다시 입력하세요', Icons.lock_outline, obscure: !_showPw),
              Row(
                children: [
                  Checkbox(
                    value: _showPw,
                    onChanged: (v) => setState(() => _showPw = v!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: AppColors.primary,
                  ),
                  const Text('비밀번호 표시', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('약관 동의', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _checkRow('서비스 이용약관 동의 (필수)', _agreeTerms, (v) => setState(() => _agreeTerms = v!)),
                  const SizedBox(height: 8),
                  _checkRow('개인정보 처리방침 동의 (필수)', _agreePrivacy, (v) => setState(() => _agreePrivacy = v!)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('가입하기', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => context.canPop() ? context.pop() : context.go('/'),
                child: const Text('이미 계정이 있으신가요? 로그인', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
          const SizedBox(height: 12),
          ...children.expand((w) => [w, const SizedBox(height: 10)]).toList()..removeLast(),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint, IconData icon, {bool obscure = false, TextInputType? type}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: type,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textFaint),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.15))),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _checkRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          activeColor: AppColors.primary,
        ),
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.textDark, fontSize: 13))),
      ],
    );
  }
}
