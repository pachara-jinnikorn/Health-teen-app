 import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Register (Sign Up)
  Future<User?> register(String email, String password, {String? displayName}) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'displayName': displayName ?? 'Anonymous',
        'role': 'free',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await result.user!.updateDisplayName(displayName ?? 'Anonymous');

      return result.user;
    } on FirebaseAuthException catch (e) {
      print('🔥 FirebaseAuth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('⚠️ Register error: $e');
      rethrow;
    }
  }

  /// ✅ Login (Sign In)
  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('🔥 FirebaseAuth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('⚠️ Login error: $e');
      rethrow;
    }
  }

  /// ✅ Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('⚠️ Logout error: $e');
    }
  }

  /// ✅ Get current user's role from Firestore
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] ?? 'free';
    } catch (e) {
      print('⚠️ Get user role error: $e');
      return 'free';
    }
  }

  /// ✅ Stream: auth state changes (login/logout)
  Stream<User?> get userChanges => _auth.authStateChanges();
}
