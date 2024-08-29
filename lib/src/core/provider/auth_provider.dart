import 'package:activator_app/src/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  User? _user;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;

  AuthProvider(this._supabaseService);

  Future<void> loginUser(String email, String password) async {
    try {
      AuthResponse authResponse = await _supabaseService.login(email, password);
      _user = authResponse.user;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _user = null;
      _isAuthenticated = false;
      rethrow;
    }
  }

  Future<void> registerUser(String email, String password, String name) async {
    try {
      AuthResponse authResponse =
          await _supabaseService.register(email, password, name);
      _user = authResponse.user;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    try {
      await _supabaseService.logout();
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkSession() async {
    try {
      UserResponse? userResponse = await _supabaseService.getCurrentUser();
      if (userResponse.user != null) {
        _user = userResponse.user;
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _user = null;
      }
      notifyListeners();
    } catch (e) {
      User? cachedUser = _supabaseService.currentUser;
      if (cachedUser != null) {
        _user = cachedUser;
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _user = null;
      }
      notifyListeners();
    }
  }

  Future<void> updateName(String name) async {
    try {
      UserResponse userResponse = await _supabaseService
          .updateUser(UserAttributes(data: {'display_name': name}));
      _user = userResponse.user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmail(String email) async {
    try {
      UserResponse userResponse =
          await _supabaseService.updateUser(UserAttributes(email: email));
      _user = userResponse.user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      UserResponse userResponse =
          await _supabaseService.updateUser(UserAttributes(password: password));
      _user = userResponse.user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
