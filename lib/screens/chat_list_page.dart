import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../providers/auth_provider.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('💬', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('로그인이 필요해요', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
            const SizedBox(height: 8),
            const Text('채팅을 이용하려면 로그인하세요', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('로그인하기', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
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
            const Text('채팅', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            if (mockChatThreads.isNotEmpty)
              Text('${mockChatThreads.length}개', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
          ],
        ),
      ),
      body: mockChatThreads.isEmpty
          ? _emptyState(context)
          : _threadList(context),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
          child: const Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.textFaint),
        ),
        const SizedBox(height: 20),
        const Text('아직 연결된 채팅이 없습니다', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
        const SizedBox(height: 8),
        const Text('분실물 퀴즈 인증에 성공하면\n습득자와 채팅을 시작할 수 있어요', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 14, height: 1.5)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.push('/lost-items'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: const Text('분실물 찾아보기', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  Widget _threadList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: mockChatThreads.length,
      itemBuilder: (_, i) {
        final thread = mockChatThreads[i];
        return GestureDetector(
          onTap: () => context.push('/chat/${thread.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: i == 0 ? const Radius.circular(18) : Radius.zero,
                topRight: i == 0 ? const Radius.circular(18) : Radius.zero,
                bottomLeft: i == mockChatThreads.length - 1 ? const Radius.circular(18) : Radius.zero,
                bottomRight: i == mockChatThreads.length - 1 ? const Radius.circular(18) : Radius.zero,
              ),
              border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.04))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: AppColors.subtle, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]),
                      child: Center(child: Text(thread.otherAvatar, style: const TextStyle(fontSize: 24))),
                    ),
                    if (thread.unread > 0)
                      Positioned(
                        top: -2, right: -2,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 2)),
                          child: Text('${thread.unread}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Text(thread.otherUser, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.primary)),
                          const SizedBox(width: 6),
                          Text(thread.itemEmoji, style: const TextStyle(fontSize: 16)),
                        ]),
                        Text(thread.lastTime, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thread.lastMessage,
                      style: TextStyle(fontSize: 12, color: thread.unread > 0 ? AppColors.primary : AppColors.textMuted, fontWeight: thread.unread > 0 ? FontWeight.w500 : FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(thread.itemTitle, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
