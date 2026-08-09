import '../models/models.dart';
import 'supabase_client.dart';

const _threadSelect = '''
  id, created_at, user_a_id,
  found_items(id, title, category, status, finder_id),
  lost_items(id, title, category, status, owner_id),
  user_a:profiles!chat_threads_user_a_id_fkey(id, name, avatar),
  user_b:profiles!chat_threads_user_b_id_fkey(id, name, avatar),
  chat_messages(id, text, is_appointment, appointment_data, created_at, sender_id, profiles(id, name, avatar))
''';

class ChatService {
  Future<List<ChatThread>> fetchThreads(String currentUserId) async {
    final data = await supabase
        .from('chat_threads')
        .select(_threadSelect)
        .or('user_a_id.eq.$currentUserId,user_b_id.eq.$currentUserId')
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => _threadFromJson(json as Map<String, dynamic>, currentUserId))
        .toList();
  }

  Future<ChatThread> fetchThread(String id, String currentUserId) async {
    final data = await supabase.from('chat_threads').select(_threadSelect).eq('id', id).single();
    return _threadFromJson(data, currentUserId);
  }

  Future<ChatThread> createThread({
    required String foundItemId,
    required String otherUserId,
    required String currentUserId,
  }) async {
    final existing = await supabase
        .from('chat_threads')
        .select(_threadSelect)
        .eq('item_id', foundItemId)
        .or(
          'and(user_a_id.eq.$currentUserId,user_b_id.eq.$otherUserId),'
          'and(user_a_id.eq.$otherUserId,user_b_id.eq.$currentUserId)',
        )
        .maybeSingle();

    if (existing != null) return _threadFromJson(existing, currentUserId);

    final data = await supabase
        .from('chat_threads')
        .insert({
          'item_id': foundItemId,
          'user_a_id': currentUserId,
          'user_b_id': otherUserId,
        })
        .select(_threadSelect)
        .single();

    return _threadFromJson(data, currentUserId);
  }

  /// 분실 신고에 채팅 걸기 — 기존 스레드가 있으면 재사용, 없으면 RPC가 생성
  Future<ChatThread> startLostItemChat({
    required String lostItemId,
    required String currentUserId,
  }) async {
    final threadRow = await supabase.rpc('start_lost_item_chat', params: {
      'p_lost_item_id': lostItemId,
    }) as Map<String, dynamic>;

    final data = await supabase
        .from('chat_threads')
        .select(_threadSelect)
        .eq('id', threadRow['id'] as String)
        .single();

    return _threadFromJson(data, currentUserId);
  }

  Future<ChatMessage> sendMessage({
    required String threadId,
    required String text,
    required String currentUserId,
    bool isAppointment = false,
    AppointmentData? appointmentData,
  }) async {
    final data = await supabase
        .from('chat_messages')
        .insert({
          'thread_id': threadId,
          'sender_id': currentUserId,
          'text': text,
          'is_appointment': isAppointment,
          'appointment_data': appointmentData == null
              ? null
              : {
                  'location': appointmentData.location,
                  'date': appointmentData.date,
                  'time': appointmentData.time,
                },
        })
        .select('*, profiles(id, name, avatar)')
        .single();

    return _messageFromJson(data, currentUserId);
  }

  ChatThread _threadFromJson(Map<String, dynamic> json, String currentUserId) {
    final userA = _map(json['user_a']);
    final userB = _map(json['user_b']);
    final lostItem = _map(json['lost_items']);
    final item = _map(json['found_items']) ?? lostItem;
    final isLostItem = json['found_items'] == null && lostItem != null;
    final other = userA?['id'] == currentUserId ? userB : userA;
    final rawMessages = json['chat_messages'];
    final messages = _messagesFromJson(rawMessages, currentUserId);
    messages.sort((a, b) => a.time.compareTo(b.time));
    final last = messages.isEmpty ? null : messages.last;

    return ChatThread(
      id: json['id'] as String,
      itemTitle: item?['title'] as String? ?? (isLostItem ? '분실물' : '습득물'),
      itemEmoji: _categoryIcon(item?['category'] as String?),
      otherUser: other?['name'] as String? ?? '상대방',
      otherUserId: other?['id'] as String?,
      otherAvatar: other?['avatar'] as String? ?? '',
      lastMessage: last?.text ?? '',
      lastTime: last?.time ?? _formatTime(json['created_at']),
      unread: 0,
      messages: messages,
      lastMessageAt: _latestMessageAt(rawMessages),
      lostItemId: isLostItem ? lostItem['id'] as String? : null,
      lostItemOwnerId: isLostItem ? lostItem['owner_id'] as String? : null,
      lostItemStatus: isLostItem ? lostItem['status'] as String? : null,
      foundItemId: isLostItem ? null : item?['id'] as String?,
      foundItemStatus: isLostItem ? null : item?['status'] as String?,
      foundItemFinderId: isLostItem ? null : item?['finder_id'] as String?,
      userAId: json['user_a_id'] as String?,
    );
  }

  /// 퀴즈 없이 채팅으로만 매칭된 습득물을, 물건을 받은 쪽(채팅을 먼저 건
  /// user_a)이 직접 "받았어요"로 확정한다. 확정 시 습득자에게 포인트가 지급됨.
  Future<void> completeFoundItemHandoff(String threadId) async {
    await supabase.rpc('complete_found_item_handoff', params: {
      'p_thread_id': threadId,
    });
  }

  DateTime? _latestMessageAt(dynamic rawMessages) {
    if (rawMessages is! List) return null;
    DateTime? latest;
    for (final msg in rawMessages) {
      if (msg is Map<String, dynamic>) {
        final dt = DateTime.tryParse(msg['created_at'] as String? ?? '')?.toLocal();
        if (dt != null && (latest == null || dt.isAfter(latest))) latest = dt;
      }
    }
    return latest;
  }

  List<ChatMessage> _messagesFromJson(dynamic value, String currentUserId) {
    if (value is! List) return [];
    return value
        .map(
          (json) =>
              _messageFromJson(json as Map<String, dynamic>, currentUserId),
        )
        .toList();
  }

  ChatMessage _messageFromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final senderId =
        json['sender_id'] as String? ??
        _map(json['profiles'])?['id'] as String?;
    final appointment = _map(json['appointment_data']);

    return ChatMessage(
      id: json['id'] as String,
      senderId: senderId == currentUserId ? 'me' : 'other',
      text: json['text'] as String? ?? '',
      time: _formatTime(json['created_at']),
      isAppointment: json['is_appointment'] == true,
      appointmentData: appointment == null
          ? null
          : AppointmentData(
              location: appointment['location'] as String? ?? '',
              date: appointment['date'] as String? ?? '',
              time: appointment['time'] as String? ?? '',
            ),
    );
  }

  Map<String, dynamic>? _map(dynamic value) =>
      value is Map<String, dynamic> ? value : null;

  String _formatTime(dynamic value) {
    final date = DateTime.tryParse(value as String? ?? '')?.toLocal();
    if (date == null) return '';
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _categoryIcon(String? category) {
    switch (category) {
      case 'electronics':
        return '📱';
      case 'wallet':
        return '👛';
      case 'clothing':
        return '👕';
      case 'accessories':
        return '⌚';
      default:
        return '📦';
    }
  }
}
