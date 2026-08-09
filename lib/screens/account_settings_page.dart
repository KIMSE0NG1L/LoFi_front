import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/surfaces.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  bool _showDeleteConfirm = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  void _save() {
    context.read<AuthProvider>().updateUser(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('정보가 저장되었습니다')));
    context.canPop() ? context.pop() : context.go('/');
  }

  Future<void> _deleteAccount() async {
    setState(() => _showDeleteConfirm = false);
    try {
      await context.read<AuthProvider>().deleteAccount();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('계정 삭제에 실패했습니다: $e')));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('계정이 삭제되었습니다')));
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.textDark), onPressed: () => context.canPop() ? context.pop() : context.go('/')),
        title: const Text('계정 설정', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('프로필 정보', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  _label('이름'),
                  _field(_nameCtrl, '이름을 입력하세요', Icons.person_outline),
                  const SizedBox(height: 14),
                  _label('이메일'),
                  _field(_emailCtrl, '이메일을 입력하세요', Icons.email_outlined, type: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _label('전화번호'),
                  _field(_phoneCtrl, '010-0000-0000', Icons.phone_outlined, type: TextInputType.phone),
                ]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('비밀번호 변경', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  _label('현재 비밀번호'),
                  _field(TextEditingController(), '현재 비밀번호 입력', Icons.lock_outline, obscure: true),
                  const SizedBox(height: 14),
                  _label('새 비밀번호'),
                  _field(TextEditingController(), '새 비밀번호 입력', Icons.lock_outline, obscure: true),
                  const SizedBox(height: 14),
                  _label('새 비밀번호 확인'),
                  _field(TextEditingController(), '새 비밀번호 다시 입력', Icons.lock_outline, obscure: true),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  child: const Text('저장하기', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _showDeleteConfirm = true),
                  child: const Text('계정 삭제', style: TextStyle(color: Colors.red, fontSize: 14, decoration: TextDecoration.underline)),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
          if (_showDeleteConfirm) _buildDeleteConfirm(),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
  );

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {bool obscure = false, TextInputType? type}) => TextField(
    controller: ctrl,
    obscureText: obscure,
    keyboardType: type,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppColors.textFaint),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.black.withOpacity(0.15))),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    ),
  );

  Widget _buildDeleteConfirm() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 28)),
              const SizedBox(height: 16),
              const Text('계정을 삭제하시겠어요?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary)),
              const SizedBox(height: 8),
              const Text('삭제된 계정은 복구할 수 없습니다.\n포인트와 모든 데이터가 사라집니다.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5)),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _showDeleteConfirm = false),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), side: BorderSide(color: Colors.black.withOpacity(0.1))),
                    child: const Text('취소', style: TextStyle(color: AppColors.textMuted)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('삭제', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
