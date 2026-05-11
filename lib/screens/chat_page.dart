import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<ChatMessage> _messages = [];
  ChatThread? _thread;
  LostItem? _item;
  bool _showMenu = false;
  bool _showReport = false;
  bool _showAppointment = false;
  String _reportReason = '';
  final _apptLocationCtrl = TextEditingController();
  final _apptDateCtrl = TextEditingController();
  final _apptTimeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);

    _thread = mockChatThreads.firstWhere(
      (t) => t.id == widget.chatId,
      orElse: () {
        final item = mockLostItems.firstWhere((i) => i.id == widget.chatId, orElse: () => mockLostItems.first);
        return ChatThread(
          id: item.id,
          itemTitle: item.title,
          itemEmoji: categoryEmoji[item.category] ?? '📦',
          otherUser: '습득자',
          otherAvatar: '😊',
          lastMessage: '',
          lastTime: '방금',
          unread: 0,
          messages: [
            ChatMessage(id: 'm1', senderId: 'other', text: '안녕하세요! ${item.title} 퀴즈를 맞추셨군요 🎉', time: _now()),
            ChatMessage(id: 'm2', senderId: 'other', text: '언제 물건을 전달받을 수 있으신가요?', time: _now()),
          ],
        );
      },
    );
    _item = mockLostItems.firstWhere((i) => i.id == widget.chatId, orElse: () => mockLostItems.first);
    _messages = List.from(_thread!.messages);
  }

  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _send() {
    if (_inputCtrl.text.trim().isEmpty) return;
    final msg = ChatMessage(id: 'm${DateTime.now().millisecondsSinceEpoch}', senderId: 'me', text: _inputCtrl.text.trim(), time: _now());
    setState(() { _messages.add(msg); _inputCtrl.clear(); });
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 1200), () {
      final replies = ['네, 알겠습니다! 😊', '좋아요! 그 시간에 맞춰 갈게요', '감사합니다 정말로!', '오늘 저녁 7시에 만나요', '장소를 알려주시면 찾아갈게요'];
      replies.shuffle();
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(id: 'm${DateTime.now().millisecondsSinceEpoch}', senderId: 'other', text: replies.first, time: _now()));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _shareLocation() {
    setState(() {
      _messages.add(ChatMessage(id: 'm${DateTime.now().millisecondsSinceEpoch}', senderId: 'me', text: '📍 강남역 2번 출구 앞에서 만나요!', time: _now()));
    });
    _scrollToBottom();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('위치 정보를 공유했습니다')));
  }

  void _createAppointment() {
    if (_apptLocationCtrl.text.isEmpty || _apptDateCtrl.text.isEmpty || _apptTimeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 정보를 입력해주세요')));
      return;
    }
    setState(() {
      _messages.add(ChatMessage(
        id: 'm${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'me',
        text: '약속을 제안했습니다',
        time: _now(),
        isAppointment: true,
        appointmentData: AppointmentData(location: _apptLocationCtrl.text, date: _apptDateCtrl.text, time: _apptTimeCtrl.text),
      ));
      _showAppointment = false;
      _apptLocationCtrl.clear();
      _apptDateCtrl.clear();
      _apptTimeCtrl.clear();
    });
    _scrollToBottom();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('약속이 제안되었습니다')));
  }

  @override
  Widget build(BuildContext context) {
    if (_thread == null) {
      return const Scaffold(body: Center(child: Text('채팅을 찾을 수 없어요')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary.withOpacity(0.95),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        title: Row(
          children: [
            Text(_thread!.otherAvatar, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(_thread!.otherUser, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(width: 6),
                  Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 10)),
                ]),
                Text('${_thread!.itemEmoji} ${_thread!.itemTitle}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
              ]),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => setState(() => _showMenu = !_showMenu),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [Tab(text: '메시지'), Tab(text: '지도')],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: Colors.white,
          dividerColor: Colors.transparent,
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabCtrl,
            children: [
              _buildMessages(),
              _buildMapTab(),
            ],
          ),
          if (_showMenu) _buildMenu(),
          if (_showReport) _buildReportSheet(),
          if (_showAppointment) _buildAppointmentSheet(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            children: [
              // Item info card
              if (_item != null && _item!.id == widget.chatId || _thread != null)
                _itemInfoCard(),
              // Safety notice
              _safetyNotice(),
              // Date separator
              _dateSeparator(),
              // Messages
              ..._messages.map((msg) => msg.isAppointment ? _appointmentBubble(msg) : _messageBubble(msg)),
            ],
          ),
        ),
        // Quick actions
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              _quickAction(Icons.location_on_outlined, '위치 공유하기', _shareLocation),
              const SizedBox(width: 8),
              _quickAction(Icons.calendar_today_outlined, '약속 잡기', () => setState(() => _showAppointment = true)),
            ],
          ),
        ),
        // Input
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    onSubmitted: (_) => _send(),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.black.withOpacity(0.06))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.black.withOpacity(0.15))),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _inputCtrl,
                  builder: (_, val, __) => GestureDetector(
                    onTap: val.text.trim().isNotEmpty ? _send : null,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: val.text.trim().isNotEmpty ? AppColors.primary : AppColors.subtle,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send_rounded, color: val.text.trim().isNotEmpty ? Colors.white : AppColors.textFaint, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemInfoCard() {
    final item = mockLostItems.firstWhere((i) => i.id == widget.chatId, orElse: () => mockLostItems.first);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          if (item.imageUrl != null)
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(item.imageUrl!, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 64, height: 64, color: AppColors.subtle))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${_thread!.itemEmoji} ${_thread!.itemTitle}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(item.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textFaint), const SizedBox(width: 2), Text(item.location, style: const TextStyle(fontSize: 10, color: AppColors.textFaint))]),
          ])),
        ],
      ),
    );
  }

  Widget _safetyNotice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.amber.shade100)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: Colors.amber.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('안전거래 안내', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.amber.shade900)),
            const SizedBox(height: 2),
            Text('직거래 시 안전한 공공장소를 이용하세요. 개인정보 요구나 의심스러운 행동은 신고해주세요.', style: TextStyle(fontSize: 11, color: Colors.amber.shade800, height: 1.4)),
          ])),
        ],
      ),
    );
  }

  Widget _dateSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(20)),
          child: const Text('오늘', style: TextStyle(fontSize: 10, color: AppColors.textFaint)),
        ),
      ),
    );
  }

  Widget _messageBubble(ChatMessage msg) {
    final isMe = msg.senderId == 'me';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(_thread!.otherAvatar, style: const TextStyle(fontSize: 16)))),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(isMe ? 14 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 14),
                  ),
                  border: isMe ? null : Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Text(msg.text, style: TextStyle(color: isMe ? Colors.white : AppColors.primary, fontSize: 14, height: 1.4)),
              ),
              const SizedBox(height: 4),
              Text(msg.time, style: const TextStyle(fontSize: 10, color: AppColors.textFaint)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appointmentBubble(ChatMessage msg) {
    final isMe = msg.senderId == 'me';
    final appt = msg.appointmentData!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(_thread!.otherAvatar, style: const TextStyle(fontSize: 16)))),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: isMe ? null : Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: isMe ? Colors.white.withOpacity(0.05) : AppColors.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(14))),
                      child: Row(children: [
                        Icon(Icons.calendar_today_outlined, size: 16, color: isMe ? Colors.white60 : AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text('약속 제안', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: isMe ? Colors.white.withOpacity(0.8) : AppColors.primary)),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _apptRow(Icons.location_on_outlined, '장소', appt.location, isMe),
                        const SizedBox(height: 8),
                        _apptRow(Icons.calendar_today_outlined, '날짜', appt.date, isMe),
                        const SizedBox(height: 8),
                        _apptRow(Icons.access_time_outlined, '시간', appt.time, isMe),
                      ]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(msg.time, style: const TextStyle(fontSize: 10, color: AppColors.textFaint)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _apptRow(IconData icon, String label, String value, bool isMe) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isMe ? Colors.white60 : AppColors.textMuted),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 9, color: isMe ? Colors.white.withOpacity(0.4) : AppColors.textFaint, letterSpacing: 0.5)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isMe ? Colors.white : AppColors.primary)),
        ]),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.07)),
        ),
        child: Row(children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ]),
      ),
    );
  }

  Widget _buildMapTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.subtle, borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.map_outlined, size: 40, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          const Text('약속 장소 지도', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          const SizedBox(height: 8),
          const Text('약속 잡기 기능을 통해\n만남 장소를 설정하세요', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5)),
        ]),
      ),
    );
  }

  Widget _buildMenu() {
    return Stack(children: [
      GestureDetector(onTap: () => setState(() => _showMenu = false), child: Container(color: Colors.transparent)),
      Positioned(
        top: 0, right: 16,
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)], border: Border.all(color: Colors.black.withOpacity(0.05))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _menuItem(Icons.flag_outlined, '신고하기', AppColors.primary, () { setState(() { _showMenu = false; _showReport = true; }); }),
            _menuItem(Icons.block_outlined, '차단하기', Colors.red, () { setState(() => _showMenu = false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('차단했습니다'))); Navigator.of(context).pop(); }),
          ]),
        ),
      ),
    ]);
  }

  Widget _menuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 10), Text(label, style: TextStyle(color: color, fontSize: 14))]),
      ),
    );
  }

  Widget _buildReportSheet() {
    return GestureDetector(
      onTap: () => setState(() => _showReport = false),
      child: Stack(children: [
        Container(color: Colors.black54),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                const Text('신고하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary)),
                const SizedBox(height: 16),
                ...[
                  {'value': 'abuse', 'label': '욕설 / 비매너', 'icon': '🚫'},
                  {'value': 'scam', 'label': '사기 의심', 'icon': '⚠️'},
                  {'value': 'fake', 'label': '허위 등록', 'icon': '❌'},
                  {'value': 'privacy', 'label': '개인정보 요구', 'icon': '🔒'},
                  {'value': 'other', 'label': '기타', 'icon': '📝'},
                ].map((r) {
                  final active = _reportReason == r['value'];
                  return GestureDetector(
                    onTap: () => setState(() => _reportReason = r['value']!),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: active ? Colors.red.shade50 : AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: active ? Colors.red : Colors.black.withOpacity(0.08)),
                      ),
                      child: Row(children: [
                        Text(r['icon']!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(r['label']!, style: TextStyle(color: active ? Colors.red.shade700 : AppColors.primary, fontSize: 14))),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _reportReason.isNotEmpty ? () { setState(() => _showReport = false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('신고가 접수되었습니다'))); } : null,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600, foregroundColor: Colors.white, disabledBackgroundColor: AppColors.subtle, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    child: const Text('신고 접수하기', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildAppointmentSheet() {
    return GestureDetector(
      onTap: () => setState(() => _showAppointment = false),
      child: Stack(children: [
        Container(color: Colors.black54),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                const Text('약속 잡기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primary)),
                const SizedBox(height: 20),
                _apptField('장소', _apptLocationCtrl, '예) 강남역 2번 출구', Icons.location_on_outlined),
                const SizedBox(height: 12),
                _apptField('날짜', _apptDateCtrl, '2026-05-20', Icons.calendar_today_outlined),
                const SizedBox(height: 12),
                _apptField('시간', _apptTimeCtrl, '18:00', Icons.access_time_outlined),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createAppointment,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                    child: const Text('약속 제안하기', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _apptField(String label, TextEditingController ctrl, String hint, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: 0.4)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
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
      ),
    ]);
  }
}
