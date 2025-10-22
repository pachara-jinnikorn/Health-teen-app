import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isAuthenticated = false;
  bool isLoading = true;
  User? currentUser;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _auth.authStateChanges().listen((user) {
      currentUser = user;
      isAuthenticated = user != null;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password, String displayName) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(result.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'role': 'free',
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      debugPrint("SignUp error: $e");
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
    } catch (e) {
      debugPrint("Login error: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    isAuthenticated = false;
    notifyListeners();
  }
}
