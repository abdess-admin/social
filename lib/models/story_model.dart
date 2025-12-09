import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id;
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final String mediaUrl;
  final String mediaType; // "image" or "video"
  final DateTime createdAt;
  final DateTime expiresAt;
  final int viewsCount;

  StoryModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatarUrl,
    required this.mediaUrl,
    required this.mediaType,
    required this.createdAt,
    required this.expiresAt,
    this.viewsCount = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isImage => mediaType == 'image';
  bool get isVideo => mediaType == 'video';

  factory StoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userAvatarUrl: data['userAvatarUrl'],
      mediaUrl: data['mediaUrl'] ?? '',
      mediaType: data['mediaType'] ?? 'image',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      viewsCount: data['viewsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewsCount': viewsCount,
    };
  }

  StoryModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatarUrl,
    String? mediaUrl,
    String? mediaType,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewsCount,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewsCount: viewsCount ?? this.viewsCount,
    );
  }
}

class UserStories {
  final String userId;
  final String username;
  final String? userAvatarUrl;
  final List<StoryModel> stories;

  UserStories({
    required this.userId,
    required this.username,
    this.userAvatarUrl,
    required this.stories,
  });

  bool get hasStories => stories.isNotEmpty;
  StoryModel? get latestStory => stories.isNotEmpty ? stories.last : null;
}
