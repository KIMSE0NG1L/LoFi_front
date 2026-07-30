import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/surfaces.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _showPw = false;
  bool _showResetModal = false;
  final _resetEmailCtrl = TextEditingController();
  bool _resetSent = false;
  bool _kakaoLoading = false;
  bool _googleLoading = false;

  Future<void> _submit() async {
    if (_emailCtrl.text.isEmpty || _pwCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요')));
      return;
    }
    try {
      await context.read<AuthProvider>().login(_emailCtrl.text, _pwCtrl.text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('로그인 되었습니다! 🎉')));
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) context.go('/');
    });
  }

  Future<void> _loginWithKakao() async {
    setState(() => _kakaoLoading = true);
    try {
      await context.read<AuthProvider>().loginWithKakao();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _kakaoLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      await context.read<AuthProvider>().loginWithGoogle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _sendReset() {
    if (_resetEmailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일을 입력해주세요')));
      return;
    }
    setState(() => _resetSent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Top brand area
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 40,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/app_logo_T.png',
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '구해조!',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '분실물 퀴즈 매칭 서비스',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                // Form card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 28,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.interactive,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _label('이메일'),
                          _inputField(
                            controller: _emailCtrl,
                            hint: '이메일을 입력하세요',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 14),
                          _label('비밀번호'),
                          _inputField(
                            controller: _pwCtrl,
                            hint: '비밀번호를 입력하세요',
                            obscure: !_showPw,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPw
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textFaint,
                                size: 18,
                              ),
                              onPressed: () =>
                                  setState(() => _showPw = !_showPw),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.interactive,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '로그인',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('또는', style: TextStyle(color: AppColors.textFaint, fontSize: 12)),
                              ),
                              Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _socialButton(
                            label: '카카오로 시작하기',
                            backgroundColor: const Color(0xFFFEE500),
                            textColor: const Color(0xFF191600),
                            loading: _kakaoLoading,
                            onTap: _loginWithKakao,
                          ),
                          const SizedBox(height: 10),
                          _socialButton(
                            label: 'Google로 시작하기',
                            backgroundColor: Colors.white,
                            textColor: AppColors.textDark,
                            border: Border.all(color: Colors.black.withOpacity(0.12)),
                            loading: _googleLoading,
                            onTap: _loginWithGoogle,
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: () => context.push('/signup'),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(text: '계정이 없으신가요? '),
                                    TextSpan(
                                      text: '회원가입',
                                      style: TextStyle(
                                        color: AppColors.interactive,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _showResetModal = true),
                              child: const Text(
                                '비밀번호를 잊으셨나요?',
                                style: TextStyle(
                                  color: AppColors.textFaint,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          if (_showResetModal) _buildResetModal(),
        ],
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required bool loading,
    required VoidCallback onTap,
    Border? border,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: border?.top ?? BorderSide.none,
          ),
        ),
        child: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) => TextField(
    controller: controller,
    obscureText: obscure,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 14, color: AppColors.primary),
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: Icon(prefixIcon, color: AppColors.interactive, size: 18),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
  );

  Widget _buildResetModal() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '비밀번호 재설정',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _showResetModal = false;
                        _resetSent = false;
                        _resetEmailCtrl.clear();
                      }),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_resetSent) ...[
                  const Text('📬', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text(
                    '이메일을 확인해주세요!',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_resetEmailCtrl.text}로\n재설정 링크를 보냈습니다.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() {
                        _showResetModal = false;
                        _resetSent = false;
                        _resetEmailCtrl.clear();
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.interactive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('확인'),
                    ),
                  ),
                ] else ...[
                  const Text(
                    '가입하신 이메일을 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _resetEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: '이메일을 입력하세요',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        size: 18,
                        color: AppColors.interactive,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _sendReset,
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: const Text('재설정 링크 전송'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.interactive,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
