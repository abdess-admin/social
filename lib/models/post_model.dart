import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String videoUrl;
  final String caption;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final String? userAvatarUrl;
  final String? thumbnailUrl;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.videoUrl,
    required this.caption,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.userAvatarUrl,
    this.thumbnailUrl,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      caption: data['caption'] ?? '',
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userAvatarUrl: data['userAvatarUrl'],
      thumbnailUrl: data['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'videoUrl': videoUrl,
      'caption': caption,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'userAvatarUrl': userAvatarUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? videoUrl,
    String? caption,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    String? userAvatarUrl,
    String? thumbnailUrl,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      videoUrl: videoUrl ?? this.videoUrl,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}
