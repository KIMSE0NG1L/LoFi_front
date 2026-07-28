import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _apptLocationCtrl = TextEditingController();
  final _apptDateCtrl = TextEditingController();
  final _apptTimeCtrl = TextEditingController();

  ChatThread? _thread;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  bool _showAppointment = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadThread());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _apptLocationCtrl.dispose();
    _apptDateCtrl.dispose();
    _apptTimeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadThread() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.user == null) {
      setState(() {
        _loading = false;
        _error = '로그인이 필요합니다.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final thread = await _chatService.fetchThread(
        widget.chatId,
        auth.user!.id,
      );
      if (!mounted) return;
      setState(() {
        _thread = thread;
        _messages = thread.messages;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id;
    if (userId == null || userId.isEmpty) return;

    setState(() => _sending = true);
    try {
      final message = await _chatService.sendMessage(
        threadId: widget.chatId,
        text: text,
        currentUserId: userId,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(message);
        _inputCtrl.clear();
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _createAppointment() async {
    if (_apptLocationCtrl.text.trim().isEmpty ||
        _apptDateCtrl.text.trim().isEmpty ||
        _apptTimeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 약속 정보를 입력해주세요.')));
      return;
    }

    final auth = context.read<AuthProvider>();
    final userId = auth.user?.id;
    if (userId == null || userId.isEmpty) return;

    final appointment = AppointmentData(
      location: _apptLocationCtrl.text.trim(),
      date: _apptDateCtrl.text.trim(),
      time: _apptTimeCtrl.text.trim(),
    );

    try {
      final message = await _chatService.sendMessage(
        threadId: widget.chatId,
        text: '약속을 제안했습니다.',
        currentUserId: userId,
        isAppointment: true,
        appointmentData: appointment,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(message);
        _showAppointment = false;
        _apptLocationCtrl.clear();
        _apptDateCtrl.clear();
        _apptTimeCtrl.clear();
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final thread = _thread;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary.withOpacity(0.95),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: thread == null
            ? const Text('채팅', style: TextStyle(color: Colors.white))
            : Row(
                children: [
                  Text(
                    thread.otherAvatar.isEmpty ? '🙂' : thread.otherAvatar,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.otherUser,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${thread.itemEmoji} ${thread.itemTitle}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          if (_loading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (_error != null)
            _messageState(_error!)
          else
            _buildMessages(),
          if (_showAppointment) _buildAppointmentSheet(),
        ],
      ),
    );
  }

  Widget _messageState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadThread, child: const Text('다시 시도')),
          ],
        ),
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
              _safetyNotice(),
              if (_messages.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      '아직 메시지가 없습니다.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
              ..._messages.map(
                (message) => message.isAppointment
                    ? _appointmentBubble(message)
                    : _messageBubble(message),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _quickAction(
              Icons.calendar_today_outlined,
              '약속 잡기',
              () => setState(() => _showAppointment = true),
            ),
          ),
        ),
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
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요.',
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _safetyNotice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: Colors.amber.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '직거래는 공공장소에서 진행하고 개인정보 요구는 주의해주세요.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.amber.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(ChatMessage message) {
    final isMe = message.senderId == 'me';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.subtle,
              child: Text(
                _thread?.otherAvatar.isNotEmpty == true
                    ? _thread!.otherAvatar
                    : '🙂',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: isMe
                      ? null
                      : Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.primary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.time,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textFaint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appointmentBubble(ChatMessage message) {
    final appointment = message.appointmentData;
    if (appointment == null) return _messageBubble(message);
    final isMe = message.senderId == 'me';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.76,
          ),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: isMe
                ? null
                : Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '약속 제안',
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _apptText(Icons.location_on_outlined, appointment.location, isMe),
              _apptText(Icons.calendar_today_outlined, appointment.date, isMe),
              _apptText(Icons.access_time_outlined, appointment.time, isMe),
            ],
          ),
        ),
      ),
    );
  }

  Widget _apptText(IconData icon, String value, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: isMe ? Colors.white70 : AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
    );
  }

  Widget _buildAppointmentSheet() {
    return GestureDetector(
      onTap: () => setState(() => _showAppointment = false),
      child: Stack(
        children: [
          Container(color: Colors.black54),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '약속 잡기',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _apptField('장소', _apptLocationCtrl, '예: 강남역 2번 출구'),
                    const SizedBox(height: 12),
                    _apptField('날짜', _apptDateCtrl, '2026-05-20'),
                    const SizedBox(height: 12),
                    _apptField('시간', _apptTimeCtrl, '18:00'),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createAppointment,
                        child: const Text('약속 제안하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _apptField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
