class Quiz {
  final String question;
  final String type; // 'multiple' | 'text'
  final List<String>? options;
  final dynamic correctAnswer; // int for multiple, String for text

  const Quiz({
    required this.question,
    required this.type,
    this.options,
    required this.correctAnswer,
  });
}

class LostItem {
  final String id;
  final String category;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;
  final List<Quiz> quizzes;
  final String? finderId;
  final String? foundBy;
  final String location;
  final MapPos mapPos;

  const LostItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdAt,
    required this.quizzes,
    this.finderId,
    this.foundBy,
    required this.location,
    required this.mapPos,
  });
}

class MapPos {
  final double x;
  final double y;
  const MapPos({required this.x, required this.y});
}

class MyLostItem {
  final String id;
  final String category;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;
  final String location;
  final String status; // 'searching' | 'matched' | 'closed'
  final String? reward;

  const MyLostItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdAt,
    required this.location,
    required this.status,
    this.reward,
  });
}

class AngelUser {
  final String id;
  final String name;
  final String avatar;
  final int itemsFound;
  final int points;

  const AngelUser({
    required this.id,
    required this.name,
    required this.avatar,
    required this.itemsFound,
    required this.points,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final String time;
  final bool isAppointment;
  final AppointmentData? appointmentData;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
    this.isAppointment = false,
    this.appointmentData,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? text,
    String? time,
    bool? isAppointment,
    AppointmentData? appointmentData,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      time: time ?? this.time,
      isAppointment: isAppointment ?? this.isAppointment,
      appointmentData: appointmentData ?? this.appointmentData,
    );
  }
}

class AppointmentData {
  final String location;
  final String date;
  final String time;

  const AppointmentData({
    required this.location,
    required this.date,
    required this.time,
  });
}

class ChatThread {
  final String id;
  final String itemTitle;
  final String itemEmoji;
  final String otherUser;
  final String otherAvatar;
  final String lastMessage;
  final String lastTime;
  final int unread;
  final List<ChatMessage> messages;

  const ChatThread({
    required this.id,
    required this.itemTitle,
    required this.itemEmoji,
    required this.otherUser,
    required this.otherAvatar,
    required this.lastMessage,
    required this.lastTime,
    required this.unread,
    required this.messages,
  });
}

class ShopItem {
  final String id;
  final String title;
  final String description;
  final int cost;
  final String emoji;
  final String category;
  final int stock;

  const ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.emoji,
    required this.category,
    required this.stock,
  });
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int points;
  final int itemsFound;
  final String avatar;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.points,
    required this.itemsFound,
    required this.avatar,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? points,
    int? itemsFound,
    String? avatar,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      points: points ?? this.points,
      itemsFound: itemsFound ?? this.itemsFound,
      avatar: avatar ?? this.avatar,
    );
  }
}

class ActivityItem {
  final String id;
  final String type;
  final String title;
  final String description;
  final String icon;
  final String? location;
  final int? pointsDelta;
  final DateTime createdAt;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    this.location,
    this.pointsDelta,
    required this.createdAt,
  });
}
