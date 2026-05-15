import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _activeTab = 'items';
  bool _notifEnabled = true;
  String? _modal;

  final _myItems = [
    {'id': 1, 'title': '갤럭시 워치 6', 'date': '2026.04.28', 'status': '매칭 완료', 'emoji': '⌚', 'matched': true},
    {'id': 2, 'title': '검정 우산', 'date': '2026.05.01', 'status': '대기 중', 'emoji': '☂️', 'matched': false},
    {'id': 3, 'title': '에어팟 프로', 'date': '2026.04.15', 'status': '찾는 중', 'emoji': '🎧', 'matched': false},
  ];

  final _myActivity = [
    {'text': '갤럭시 워치 6 매칭 완료!', 'time': '3일 전', 'pts': '+50', 'emoji': '🎉'},
    {'text': '검정 우산 등록', 'time': '5일 전', 'pts': '+10', 'emoji': '📦'},
    {'text': '일일 접속 보너스', 'time': '오늘', 'pts': '+5', 'emoji': '⭐'},
  ];

  static const _termsContent = '''제1조 (목적)
이 약관은 옛다 띱! 서비스의 이용에 관한 조건 및 절차, 권리와 의무를 규정합니다.

제2조 (서비스 이용)
서비스는 분실물 매칭 플랫폼으로, 습득물 등록 및 퀴즈 기반 인증을 제공합니다.

제3조 (퀴즈 시스템)
습득자는 분실물 특징으로 퀴즈를 출제하며, 분실자가 정답을 맞추면 매칭이 완료됩니다.

제4조 (포인트 시스템)
습득물 등록 시 10pts, 매칭 성공 시 50pts, 일일 접속 시 5pts가 지급됩니다.

제5조 (금지 행위)
허위 정보 등록, 타인 분실물 부정 청구, 시스템 악용을 금지합니다.''';

  static const _privacyContent = '''수집하는 개인정보
- 이름, 이메일 주소, 전화번호 (회원가입 시)
- 분실물 및 습득물 정보
- 서비스 이용 기록

개인정보 이용 목적
- 분실물 매칭 서비스 제공
- 포인트/랭킹 시스템 운영
- 서비스 개선
- 매칭 성공 시 분실자-습득자 간 연락

보유 및 이용 기간
회원 탈퇴 시까지 보유하며, 법령에서 정한 경우 해당 기간 동안 보관합니다.

제3자 제공
매칭 성공 시 분실자와 습득자 간 연락처 정보(전화번호 포함)를 상호 제공합니다.''';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) context.go('/login'); });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = auth.user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  color: AppColors.primary,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 16, right: 16, bottom: 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              context.go('/');
                            }
                          },
                          padding: EdgeInsets.zero,
                        ),
                        GestureDetector(
                          onTap: () { auth.logout(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그아웃 되었습니다'))); context.go('/'); },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(20)),
                            child: Row(children: [
                              const Icon(Icons.logout_outlined, color: Colors.white38, size: 14),
                              const SizedBox(width: 4),
                              const Text('로그아웃', style: TextStyle(color: Colors.white38, fontSize: 12)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(0.1))),
                        child: Center(child: Text(user.avatar, style: const TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.star_outline, color: Colors.white54, size: 14),
                          const SizedBox(width: 4),
                          Text('${user.points} pts', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(' · ', style: TextStyle(color: Colors.white.withOpacity(0.2))),
                          Text('${user.itemsFound}개 찾아줌', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                        ]),
                      ])),
                    ]),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.08)), borderRadius: BorderRadius.circular(18)),
                      child: Row(children: [
                        _statCell(user.points.toString(), '포인트'),
                        Container(width: 1, height: 50, color: Colors.white.withOpacity(0.06)),
                        _statCell(user.itemsFound.toString(), '찾아줌'),
                        Container(width: 1, height: 50, color: Colors.white.withOpacity(0.06)),
                        _statCell('12위', '랭킹'),
                      ]),
                    ),
                  ]),
                ),
                // Tab switcher
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
                    child: Row(children: [
                      _tabBtn('items', '내 물건', Icons.inventory_2_outlined),
                      _tabBtn('activity', '활동 내역', Icons.emoji_events_outlined),
                    ]),
                  ),
                ),
                // Tab content
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    children: _activeTab == 'items'
                        ? _myItems.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                          child: Row(children: [
                            Text(item['emoji'] as String, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.primary), overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(item['date'] as String, style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: item['matched'] as bool ? AppColors.primary : AppColors.subtle,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(item['status'] as String, style: TextStyle(color: item['matched'] as bool ? Colors.white : AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
                            ),
                          ]),
                        )).toList()
                        : _myActivity.map((act) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                          child: Row(children: [
                            Text(act['emoji']!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(act['text']!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.primary)),
                              const SizedBox(height: 2),
                              Text(act['time']!, style: const TextStyle(color: AppColors.textFaint, fontSize: 11)),
                            ])),
                            Text(act['pts']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                          ]),
                        )).toList(),
                  ),
                ),
                // Quick links
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('바로가기', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Row(children: [
                      _quickLink('🔖', '즐겨찾기', '/favorites'),
                      _quickLink('💬', '채팅', '/chats'),
                      _quickLink('🛍️', '포인트 상점', '/shop'),
                    ]),
                  ]),
                ),
                // Settings
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('설정', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                      child: Column(children: [
                        _settingRow(
                          icon: Icons.notifications_outlined, label: '알림 설정',
                          trailing: Switch(
                            value: _notifEnabled,
                            onChanged: (v) => setState(() => _notifEnabled = v),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Divider(height: 1, color: Colors.black.withOpacity(0.04)),
                        _settingRow(icon: Icons.description_outlined, label: '서비스 이용약관', onTap: () => setState(() => _modal = 'terms')),
                        Divider(height: 1, color: Colors.black.withOpacity(0.04)),
                        _settingRow(icon: Icons.shield_outlined, label: '개인정보 처리방침', onTap: () => setState(() => _modal = 'privacy')),
                        Divider(height: 1, color: Colors.black.withOpacity(0.04)),
                        _settingRow(icon: Icons.settings_outlined, label: '계정 설정', onTap: () => context.push('/account-settings')),
                      ]),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          if (_modal != null) _buildPolicyModal(_modal == 'terms' ? '서비스 이용약관' : '개인정보 처리방침', _modal == 'terms' ? _termsContent : _privacyContent),
        ],
      ),
    );
  }

  Widget _statCell(String val, String label) {
    return Expanded(
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _tabBtn(String id, String label, IconData icon) {
    final active = _activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 14, color: active ? Colors.white : AppColors.textMuted),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: active ? Colors.white : AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _quickLink(String emoji, String label, String path) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(path),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
          child: Column(children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary)),
          ]),
        ),
      ),
    );
  }

  Widget _settingRow({required IconData icon, required String label, VoidCallback? onTap, Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.primary))),
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.textFaint, size: 18),
        ]),
      ),
    );
  }

  Widget _buildPolicyModal(String title, String content) {
    return GestureDetector(
      onTap: () => setState(() => _modal = null),
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                    GestureDetector(onTap: () => setState(() => _modal = null), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.background, shape: BoxShape.circle), child: const Icon(Icons.close, size: 16, color: AppColors.textMuted))),
                  ]),
                ),
                Divider(height: 1, color: Colors.black.withOpacity(0.06)),
                Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Text(content, style: const TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.6)))),
                Divider(height: 1, color: Colors.black.withOpacity(0.06)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () => setState(() => _modal = null),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w600)),
                  )),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
