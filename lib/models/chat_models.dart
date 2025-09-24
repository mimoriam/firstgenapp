
class ChatUser {
  final String uid;
  final String name;
  final String avatarUrl;

  ChatUser({required this.uid, required this.name, required this.avatarUrl});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'Unknown User',
      avatarUrl:
          json['avatarUrl'] ?? 'https://picsum.photos/seed/error/200/200',
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'name': name, 'avatarUrl': avatarUrl};
  }
}

class ChatMessage {
  final String id;
  final String? text;
  final String senderId;
  final String timestamp;
  final String? imageUrl;
  final String status;
  final String? readTimestamp;

  ChatMessage({
    required this.id,
    this.text,
    required this.senderId,
    required this.timestamp,
    this.imageUrl,
    this.status = 'sent',
    this.readTimestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String id) {
    return ChatMessage(
      id: id,
      text: json['text'],
      senderId: json['senderId'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().toUtc().toIso8601String(),
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'sent',
      readTimestamp: json['readTimestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'status': status,
      'readTimestamp': readTimestamp,
    };
  }
}

class Conversation {
  final String id;
  final String lastMessage;
  final String lastMessageTimestamp;
  final ChatUser otherUser;
  final int unreadCount;
  final String lastMessageSenderId;

  Conversation({
    required this.id,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    required this.otherUser,
    required this.unreadCount,
    required this.lastMessageSenderId,
  });

  factory Conversation.fromJson(
    Map<String, dynamic> json,
    String id,
    String currentUserId,
  ) {
    final usersMap = Map<String, dynamic>.from(json['users'] as Map? ?? {});
    final otherUserEntry = usersMap.entries.firstWhere(
      (entry) => entry.key != currentUserId,
      orElse: () => MapEntry('', {}),
    );

    return Conversation(
      id: id,
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTimestamp:
          json['lastMessageTimestamp'] ??
          DateTime.now().toUtc().toIso8601String(),
      otherUser: ChatUser.fromJson(
        Map<String, dynamic>.from(otherUserEntry.value as Map? ?? {}),
      ),
      unreadCount:
          (json['unreadCount'] as Map<String, dynamic>?)?[currentUserId] ?? 0,
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
    );
  }
}
