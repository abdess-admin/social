import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _commentsCollection(String postId) {
    return _firestore.collection('posts').doc(postId).collection('comments');
  }

  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _commentsCollection(postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc, postId))
            .toList());
  }

  Future<List<CommentModel>> getComments(String postId, {int limit = 50}) async {
    final snapshot = await _commentsCollection(postId)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CommentModel.fromFirestore(doc, postId))
        .toList();
  }

  Future<String> addComment({
    required String postId,
    required String userId,
    required String username,
    required String text,
    String? userAvatarUrl,
  }) async {
    final batch = _firestore.batch();

    final commentRef = _commentsCollection(postId).doc();
    batch.set(commentRef, {
      'userId': userId,
      'username': username,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'likesCount': 0,
      'userAvatarUrl': userAvatarUrl,
    });

    final postRef = _firestore.collection('posts').doc(postId);
    batch.update(postRef, {
      'commentsCount': FieldValue.increment(1),
    });

    await batch.commit();
    return commentRef.id;
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final batch = _firestore.batch();

    final commentRef = _commentsCollection(postId).doc(commentId);
    batch.delete(commentRef);

    final postRef = _firestore.collection('posts').doc(postId);
    batch.update(postRef, {
      'commentsCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  Future<int> getCommentsCount(String postId) async {
    final snapshot = await _commentsCollection(postId).count().get();
    return snapshot.count ?? 0;
  }

  Stream<int> getCommentsCountStream(String postId) {
    return _commentsCollection(postId).snapshots().map((snapshot) => snapshot.docs.length);
  }
}
