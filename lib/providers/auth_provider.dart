import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? currentUser;
  String? role;
  bool isLoading = false;

  AuthProvider() {
    // Begin with auth state 
    _authService.userChanges.listen((user) async {
      currentUser = user;
      if (user != null) {
        role = await _authService.getUserRole(user.uid);
      } else {
        role = null;
      }
      notifyListeners();
    });
  }

  // ✅ Login
  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();
      await _authService.login(email, password);
    } catch (e) {
      debugPrint("Login error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Register
  Future<void> register(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();
      await _authService.register(email, password);
    } catch (e) {
      debugPrint("Register error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Logout
  Future<void> logout() async {
    await _authService.logout();
  }

  // ✅ Helper for UI
  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => role == 'admin';
  bool get isPremium => role == 'premium';
  bool get isFree => role == 'free';
}
