import 'package:cloud_firestore/cloud_firestore.dart';

enum ActivityType { liked, matched }

class Activity {
  final String id;
  final String userId; // The user who receives the notification
  final ActivityType type;
  final String fromUserId;
  final String fromUserName;
  final String fromUserAvatar;
  final Timestamp timestamp;
  final bool isRead;

  Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserAvatar,
    required this.timestamp,
    this.isRead = false,
  });

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: (data['type'] == 'matched')
          ? ActivityType.matched
          : ActivityType.liked,
      fromUserId: data['fromUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      fromUserAvatar: data['fromUserAvatar'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type == ActivityType.liked ? 'liked' : 'matched',
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserAvatar': fromUserAvatar,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}
