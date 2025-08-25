import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final List<String> imageUrls;
  final String creatorId;
  final List<String> members;
  final bool isInviteOnly;
  final Timestamp createdAt;
  final String whoFor;
  final String whatToGain;
  final String rules;
  final DocumentSnapshot originalDoc;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.creatorId,
    required this.members,
    required this.isInviteOnly,
    required this.createdAt,
    required this.whoFor,
    required this.whatToGain,
    required this.rules,
    required this.originalDoc,
  });

  factory Community.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Community(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      creatorId: data['creatorId'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      isInviteOnly: data['isInviteOnly'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      whoFor: data['whoFor'] ?? '',
      whatToGain: data['whatToGain'] ?? '',
      rules: data['rules'] ?? '',
      originalDoc: doc,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
      'creatorId': creatorId,
      'members': members,
      'isInviteOnly': isInviteOnly,
      'createdAt': createdAt,
      'whoFor': whoFor,
      'whatToGain': whatToGain,
      'rules': rules,
    };
  }
}

class Post {
  final String id;
  final String authorId;
  final String? communityId; // null for personal feed
  final String content;
  final String? imageUrl;
  final String? videoUrl;
  final Timestamp timestamp;
  final Map<String, bool> likes;
  final int commentCount;
  final DocumentSnapshot originalDoc;

  Post({
    required this.id,
    required this.authorId,
    this.communityId,
    required this.content,
    this.imageUrl,
    this.videoUrl,
    required this.timestamp,
    required this.likes,
    required this.commentCount,
    required this.originalDoc,
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      communityId: data['communityId'],
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: Map<String, bool>.from(data['likes'] ?? {}),
      commentCount: data['commentCount'] ?? 0,
      originalDoc: doc,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'communityId': communityId,
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'timestamp': timestamp,
      'likes': likes,
      'commentCount': commentCount,
    };
  }
}

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String text;
  final Timestamp timestamp;
  final Map<String, bool> likes;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.text,
    required this.timestamp,
    required this.likes,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      postId: data['postId'] ?? '',
      authorId: data['authorId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: Map<String, bool>.from(data['likes'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      'text': text,
      'timestamp': timestamp,
      'likes': likes,
    };
  }
}
