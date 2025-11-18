import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isAuthenticated = false;
  bool isLoading = true;
  User? currentUser;
  Map<String, dynamic>? _userData; // ✅ ADD THIS

  // ✅ ADD THIS GETTER
  bool get isPremium {
    if (_userData == null) return false;
    return _userData!['role'] == 'premium';
  }

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _auth.authStateChanges().listen((user) async {
      currentUser = user;
      isAuthenticated = user != null;
      
      // ✅ Load user data when logged in
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _userData = null;
      }
      
      isLoading = false;
      notifyListeners();
    });
  }

  // ✅ ADD THIS METHOD
  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        _userData = doc.data();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
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
        'role': 'free', // Default: free user
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ Load user data after signup
      await _loadUserData(result.user!.uid);
      
      notifyListeners();
    } catch (e) {
      debugPrint("SignUp error: $e");
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // ✅ Load user data after login
      if (result.user != null) {
        await _loadUserData(result.user!.uid);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Login error: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    isAuthenticated = false;
    currentUser = null;
    _userData = null; // ✅ Clear user data
    notifyListeners();
  }

  // ✅ ADD THIS METHOD - Upgrade to Premium
  Future<void> upgradeToPremium() async {
    if (currentUser == null) return;
    
    try {
      await _db.collection('users').doc(currentUser!.uid).update({
        'role': 'premium',
        'premiumActivatedAt': FieldValue.serverTimestamp(),
      });
      
      // Reload user data
      await _loadUserData(currentUser!.uid);
      
      debugPrint('✅ Upgraded to Premium');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error upgrading to premium: $e');
      rethrow;
    }
  }

  // ✅ ADD THIS METHOD - Downgrade to Free
  Future<void> downgradeToFree() async {
    if (currentUser == null) return;
    
    try {
      await _db.collection('users').doc(currentUser!.uid).update({
        'role': 'free',
        'premiumCancelledAt': FieldValue.serverTimestamp(),
      });
      
      // Reload user data
      await _loadUserData(currentUser!.uid);
      
      debugPrint('✅ Downgraded to Free');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error downgrading to free: $e');
      rethrow;
    }
  }

  // ✅ ADD THIS HELPER - Get user role
  String get userRole {
    if (_userData == null) return 'free';
    return _userData!['role'] ?? 'free';
  }
}