import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();

  List<ChatThread> _threads = [];
  bool _loading = true;
  String? _error;
  Map<String, DateTime> _lastSeen = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLastSeen();
      _loadThreads();
    });
  }

  Future<void> _loadLastSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('chat_seen_'));
    final map = <String, DateTime>{};
    for (final key in keys) {
      final threadId = key.replaceFirst('chat_seen_', '');
      final iso = prefs.getString(key);
      if (iso != null) {
        final dt = DateTime.tryParse(iso);
        if (dt != null) map[threadId] = dt;
      }
    }
    if (mounted) setState(() => _lastSeen = map);
  }

  bool _hasUnread(ChatThread thread) {
    final lastMsgAt = thread.lastMessageAt;
    if (lastMsgAt == null) return false;
    final seen = _lastSeen[thread.id];
    if (seen == null) return true;
    return lastMsgAt.isAfter(seen);
  }

  Future<void> _openChat(String threadId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_seen_$threadId', DateTime.now().toIso8601String());
    setState(() => _lastSeen[threadId] = DateTime.now());
    if (mounted) context.push('/chat/$threadId');
  }

  Future<void> _loadThreads() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn || auth.user == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final threads = await _chatService.fetchThreads(auth.user!.id);
      if (!mounted) return;
      setState(() => _threads = threads);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 52,
                color: AppColors.textFaint,
              ),
              const SizedBox(height: 16),
              const Text(
                '로그인이 필요해요',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('로그인하기'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary.withOpacity(0.95),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '채팅',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              '${_threads.length}개',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? _messageState(_error!, retry: _loadThreads)
          : _threads.isEmpty
          ? _messageState('아직 연결된 채팅이 없습니다.', retry: _loadThreads)
          : RefreshIndicator(
              onRefresh: _loadThreads,
              color: AppColors.primary,
              child: _threadList(context),
            ),
    );
  }

  Widget _messageState(String message, {VoidCallback? retry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 52,
            color: AppColors.textFaint,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
          if (retry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: retry, child: const Text('새로고침')),
          ],
        ],
      ),
    );
  }

  Widget _threadList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: _threads.length,
      itemBuilder: (_, index) {
        final thread = _threads[index];
        final unread = _hasUnread(thread);
        return GestureDetector(
          onTap: () => _openChat(thread.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: index == 0 ? const Radius.circular(18) : Radius.zero,
                topRight: index == 0 ? const Radius.circular(18) : Radius.zero,
                bottomLeft: index == _threads.length - 1
                    ? const Radius.circular(18)
                    : Radius.zero,
                bottomRight: index == _threads.length - 1
                    ? const Radius.circular(18)
                    : Radius.zero,
              ),
              border: Border(
                bottom: BorderSide(color: Colors.black.withOpacity(0.04)),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.subtle,
                  child: Text(
                    thread.otherAvatar.isEmpty ? '🙂' : thread.otherAvatar,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              thread.otherUser,
                              style: TextStyle(
                                fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              if (unread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                thread.lastTime,
                                style: TextStyle(
                                  color: unread ? AppColors.primary : AppColors.textLight,
                                  fontSize: 11,
                                  fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        thread.lastMessage.isEmpty
                            ? '메시지가 없습니다.'
                            : thread.lastMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: unread ? AppColors.primary : AppColors.textMuted,
                          fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${thread.itemEmoji} ${thread.itemTitle}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
