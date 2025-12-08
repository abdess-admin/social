import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<void> createUser({
    required String uid,
    required String username,
    required String email,
  }) async {
    final user = UserModel(
      uid: uid,
      username: username,
      email: email,
      createdAt: DateTime.now(),
    );

    await _usersCollection.doc(uid).set(user.toFirestore());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersCollection.doc(uid).update(data);
  }

  Future<void> updateUsername(String uid, String username) async {
    await _usersCollection.doc(uid).update({'username': username});
  }

  Future<void> updateAvatar(String uid, String avatarUrl) async {
    await _usersCollection.doc(uid).update({'avatarUrl': avatarUrl});
  }

  Future<void> updateBio(String uid, String bio) async {
    await _usersCollection.doc(uid).update({'bio': bio});
  }

  Future<bool> isUsernameAvailable(String username) async {
    final query = await _usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await _usersCollection
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }
}
