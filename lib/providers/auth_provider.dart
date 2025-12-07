import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  String? _userPhotoUrl;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userPhotoUrl => _userPhotoUrl;

  // Placeholder methods - will be implemented with Firebase in Step 2
  Future<void> signIn(String email, String password) async {
    // TODO: Implement Firebase Auth sign in
    _isAuthenticated = true;
    _userEmail = email;
    _userId = 'temp_user_id';
    _userName = email.split('@').first;
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String name) async {
    // TODO: Implement Firebase Auth sign up
    _isAuthenticated = true;
    _userEmail = email;
    _userId = 'temp_user_id';
    _userName = name;
    notifyListeners();
  }

  Future<void> signOut() async {
    // TODO: Implement Firebase Auth sign out
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    _userName = null;
    _userPhotoUrl = null;
    notifyListeners();
  }
}
