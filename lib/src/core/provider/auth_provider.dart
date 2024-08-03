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

  Future<void> registerUser(String email, String password, String name) async {
    try {
      await _supabaseService.register(email, password, name);
      _user = await _supabaseService.getCurrentUser();
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await _supabaseService.login(email, password);
      _user = await _supabaseService.getCurrentUser();
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      _user = null;
      _isAuthenticated = false;
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
      _user = await _supabaseService.getCurrentUser();
      _isAuthenticated = _user != null;
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
    }
  }

  Future<void> updateName(String name) async {
    try {
      await _supabaseService
          .updateUser(UserAttributes(data: {'display_name': name}));
      _user = await _supabaseService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser() async {
    _user = await _supabaseService.getCurrentUser();
    notifyListeners();
  }

  Future<void> updateEmail(String email) async {
    try {
      await _supabaseService.updateUser(UserAttributes(email: email));
      _user = await _supabaseService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      await _supabaseService.updateUser(UserAttributes(password: password));
      _user = await _supabaseService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
