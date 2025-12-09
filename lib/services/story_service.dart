import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story_model.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userStoriesCollection(String userId) {
    return _firestore.collection('stories').doc(userId).collection('items');
  }

  Stream<List<UserStories>> getActiveStoriesByUserStream() {
    final now = DateTime.now();
    
    return _firestore
        .collectionGroup('items')
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
          final stories = snapshot.docs
              .map((doc) => StoryModel.fromFirestore(doc))
              .where((story) => !story.isExpired)
              .toList();
          
          return _groupStoriesByUser(stories);
        });
  }

  Future<List<UserStories>> getActiveStoriesByUser() async {
    final now = DateTime.now();
    
    final snapshot = await _firestore
        .collectionGroup('items')
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt')
        .orderBy('createdAt')
        .get();
    
    final stories = snapshot.docs
        .map((doc) => StoryModel.fromFirestore(doc))
        .where((story) => !story.isExpired)
        .toList();
    
    return _groupStoriesByUser(stories);
  }

  List<UserStories> _groupStoriesByUser(List<StoryModel> stories) {
    final Map<String, List<StoryModel>> storiesByUser = {};
    
    for (final story in stories) {
      storiesByUser.putIfAbsent(story.userId, () => []);
      storiesByUser[story.userId]!.add(story);
    }
    
    for (final userId in storiesByUser.keys) {
      storiesByUser[userId]!.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    
    return storiesByUser.entries.map((entry) {
      final userStories = entry.value;
      final firstStory = userStories.first;
      return UserStories(
        userId: entry.key,
        username: firstStory.username,
        userAvatarUrl: firstStory.userAvatarUrl,
        stories: userStories,
      );
    }).toList();
  }

  Stream<List<StoryModel>> getUserStoriesStream(String userId) {
    final now = DateTime.now();
    
    return _userStoriesCollection(userId)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StoryModel.fromFirestore(doc))
            .where((story) => !story.isExpired)
            .toList());
  }

  Future<List<StoryModel>> getUserStories(String userId) async {
    final now = DateTime.now();
    
    final snapshot = await _userStoriesCollection(userId)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('expiresAt')
        .orderBy('createdAt')
        .get();
    
    return snapshot.docs
        .map((doc) => StoryModel.fromFirestore(doc))
        .where((story) => !story.isExpired)
        .toList();
  }

  Future<String> createStory({
    required String userId,
    required String username,
    String? userAvatarUrl,
    required String mediaUrl,
    required String mediaType,
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 24));
    
    final docRef = await _userStoriesCollection(userId).add({
      'userId': userId,
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'viewsCount': 0,
    });
    
    return docRef.id;
  }

  Future<void> deleteStory({
    required String userId,
    required String storyId,
  }) async {
    await _userStoriesCollection(userId).doc(storyId).delete();
  }

  Future<void> incrementViewCount({
    required String userId,
    required String storyId,
  }) async {
    await _userStoriesCollection(userId).doc(storyId).update({
      'viewsCount': FieldValue.increment(1),
    });
  }

  Future<bool> hasActiveStories(String userId) async {
    final stories = await getUserStories(userId);
    return stories.isNotEmpty;
  }
}
