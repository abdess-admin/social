import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final DateTime createdAt;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final String? bio;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
    this.avatarUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.bio,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      avatarUrl: data['avatarUrl'],
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      bio: data['bio'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'avatarUrl': avatarUrl,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'bio': bio,
    };
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    DateTime? createdAt,
    String? avatarUrl,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    String? bio,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      bio: bio ?? this.bio,
    );
  }
}
