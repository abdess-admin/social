import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String text;
  final DateTime createdAt;
  final int likesCount;
  final String? userAvatarUrl;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
    this.userAvatarUrl,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc, String postId) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: postId,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: data['likesCount'] ?? 0,
      userAvatarUrl: data['userAvatarUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'likesCount': likesCount,
      'userAvatarUrl': userAvatarUrl,
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? username,
    String? text,
    DateTime? createdAt,
    int? likesCount,
    String? userAvatarUrl,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
    );
  }
}
