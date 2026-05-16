import '../models/models.dart';
import 'api_client.dart';

class ChatService {
  ChatService(this._api);

  final ApiClient _api;

  Future<List<ChatThread>> fetchThreads(String currentUserId) async {
    final data = await _api.get('/chat') as List<dynamic>;
    return data
        .map(
          (json) =>
              _threadFromJson(json as Map<String, dynamic>, currentUserId),
        )
        .toList();
  }

  Future<ChatThread> fetchThread(String id, String currentUserId) async {
    final data = await _api.get('/chat/$id') as Map<String, dynamic>;
    return _threadFromJson(data, currentUserId);
  }

  Future<ChatThread> createThread({
    required String foundItemId,
    required String otherUserId,
    required String currentUserId,
  }) async {
    final data =
        await _api.post(
              '/chat',
              body: {'foundItemId': foundItemId, 'otherUserId': otherUserId},
            )
            as Map<String, dynamic>;
    return _threadFromJson(data, currentUserId);
  }

  Future<ChatMessage> sendMessage({
    required String threadId,
    required String text,
    required String currentUserId,
    bool isAppointment = false,
    AppointmentData? appointmentData,
  }) async {
    final data =
        await _api.post(
              '/chat/$threadId/messages',
              body: {
                'text': text,
                'isAppointment': isAppointment,
                if (appointmentData != null)
                  'appointmentData': {
                    'location': appointmentData.location,
                    'date': appointmentData.date,
                    'time': appointmentData.time,
                  },
              },
            )
            as Map<String, dynamic>;

    return _messageFromJson(data, currentUserId);
  }

  ChatThread _threadFromJson(Map<String, dynamic> json, String currentUserId) {
    final userA = _map(json['user_a']);
    final userB = _map(json['user_b']);
    final item = _map(json['found_items']);
    final other = userA?['id'] == currentUserId ? userB : userA;
    final messages = _messagesFromJson(json['chat_messages'], currentUserId);
    messages.sort((a, b) => a.time.compareTo(b.time));
    final last = messages.isEmpty ? null : messages.last;

    return ChatThread(
      id: json['id'] as String,
      itemTitle: item?['title'] as String? ?? '습득물',
      itemEmoji: _categoryIcon(item?['category'] as String?),
      otherUser: other?['name'] as String? ?? '상대방',
      otherAvatar: other?['avatar'] as String? ?? '',
      lastMessage: last?.text ?? '',
      lastTime: last?.time ?? _formatTime(json['created_at']),
      unread: 0,
      messages: messages,
    );
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
