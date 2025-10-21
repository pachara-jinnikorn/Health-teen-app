import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Register user
  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore.collection('users').doc(result.user!.uid).set({
      'email': email,
      'role': 'free',
      'createdAt': DateTime.now(),
    });
    return result.user;
  }

  // ✅ Login user
  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // ✅ Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ✅ Get current user role
  Future<String> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] ?? 'free';
  }

  // ✅ Listen to auth changes
  Stream<User?> get userChanges => _auth.authStateChanges();
}
