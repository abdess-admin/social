import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _firestore.collection('posts');

  Stream<List<PostModel>> getPostsStream() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  Future<List<PostModel>> getPosts({int limit = 20}) async {
    final snapshot = await _postsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }

  Future<PostModel?> getPost(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (doc.exists) {
      return PostModel.fromFirestore(doc);
    }
    return null;
  }

  Future<String> createPost(PostModel post) async {
    final docRef = await _postsCollection.add(post.toFirestore());
    return docRef.id;
  }

  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }

  Future<bool> isPostLikedByUser(String postId, String userId) async {
    final likeDoc = await _postsCollection
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .get();
    return likeDoc.exists;
  }

  Stream<bool> isPostLikedByUserStream(String postId, String userId) {
    return _postsCollection
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> likePost(String postId, String userId) async {
    final batch = _firestore.batch();

    final likeRef = _postsCollection.doc(postId).collection('likes').doc(userId);
    batch.set(likeRef, {
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final postRef = _postsCollection.doc(postId);
    batch.update(postRef, {
      'likesCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> unlikePost(String postId, String userId) async {
    final batch = _firestore.batch();

    final likeRef = _postsCollection.doc(postId).collection('likes').doc(userId);
    batch.delete(likeRef);

    final postRef = _postsCollection.doc(postId);
    batch.update(postRef, {
      'likesCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  Future<void> toggleLike(String postId, String userId) async {
    final isLiked = await isPostLikedByUser(postId, userId);
    if (isLiked) {
      await unlikePost(postId, userId);
    } else {
      await likePost(postId, userId);
    }
  }

  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20}) async {
    final snapshot = await _postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }

  Stream<List<PostModel>> getUserPostsStream(String userId) {
    return _postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }
}
