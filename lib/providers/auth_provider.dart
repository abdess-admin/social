import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isLoading => _isLoading;
  String? get userId => _firebaseUser?.uid;
  String? get userEmail => _firebaseUser?.email;
  String? get userName => _userModel?.username;
  String? get userPhotoUrl => _userModel?.avatarUrl;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        _userModel = await _userService.getUser(user.uid);
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    try {
      final credential = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _userService.createUser(
          uid: credential.user!.uid,
          username: username,
          email: email,
        );
        _userModel = await _userService.getUser(credential.user!.uid);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<void> refreshUserData() async {
    if (_firebaseUser != null) {
      _userModel = await _userService.getUser(_firebaseUser!.uid);
      notifyListeners();
    }
  }
}
