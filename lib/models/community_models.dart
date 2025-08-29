import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
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
    required this.imageUrl,
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
      imageUrl: data['imageUrl'] ?? '',
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
      'imageUrl': imageUrl,
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

class Event {
  final String id;
  final String communityId;
  final String creatorId;
  final String title;
  final String description;
  final String imageUrl;
  final Timestamp eventDate;
  final String location;
  final List<String> interestedUserIds;
  final DocumentSnapshot originalDoc;

  Event({
    required this.id,
    required this.communityId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.eventDate,
    required this.location,
    required this.interestedUserIds,
    required this.originalDoc,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      communityId: data['communityId'] ?? '',
      creatorId: data['creatorId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      eventDate: data['eventDate'] ?? Timestamp.now(),
      location: data['location'] ?? '',
      interestedUserIds: List<String>.from(data['interestedUserIds'] ?? []),
      originalDoc: doc,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'communityId': communityId,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'eventDate': eventDate,
      'location': location,
      'interestedUserIds': interestedUserIds,
    };
  }
}

class Comment {
  final String id;
  final String postId;
  final String? parentId; // ID of the comment this is a reply to
  final String authorId;
  final String text;
  final Timestamp timestamp;
  final Map<String, bool> likes;
  final int replyCount;
  final DocumentSnapshot originalDoc;

  Comment({
    required this.id,
    required this.postId,
    this.parentId,
    required this.authorId,
    required this.text,
    required this.timestamp,
    required this.likes,
    this.replyCount = 0,
    required this.originalDoc,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      postId: data['postId'] ?? '',
      parentId: data['parentId'],
      authorId: data['authorId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: Map<String, bool>.from(data['likes'] ?? {}),
      replyCount: data['replyCount'] ?? 0,
      originalDoc: doc,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'parentId': parentId,
      'authorId': authorId,
      'text': text,
      'timestamp': timestamp,
      'likes': likes,
      'replyCount': replyCount,
    };
  }
}
