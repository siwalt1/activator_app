import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:activator_app/src/core/services/appwrite_service.dart';

class AuthProvider with ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();
  User? _user;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  User? get user => _user;

  Future<void> registerUser(String email, String password, String name) async {
    try {
      await _appwriteService.register(email, password, name);
      await loginUser(email, password);
      _user = (await _appwriteService.getCurrentUser()) as User?;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      await _appwriteService.login(email, password);
      _user = (await _appwriteService.getCurrentUser()) as User?;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    try {
      await _appwriteService.logout();
      _isAuthenticated = false;
      _user = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkSession() async {
    try {
      _user = (await _appwriteService.getCurrentUser()) as User?;
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
      _user = await _appwriteService.updateName(name);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser() async {
    User current = await _appwriteService.getCurrentUser();
    _user = current as User?;
    notifyListeners();
  }

  Future<void> updateEmail(String email, String password) async {
    try {
      _user = await _appwriteService.updateEmail(email, password);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePassword(String password, String oldPassword) async {
    try {
      await _appwriteService.updatePassword(password, oldPassword);
      _user = (await _appwriteService.getCurrentUser()) as User?;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
