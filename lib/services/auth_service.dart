import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createHealthLog(String uid, {required String reason}) async {
    final now = DateTime.now();
    final logDate = now.toIso8601String().split('T').first; // เช่น "2025-10-28"
    final r = Random();

    final calories = 1500 + r.nextInt(1200); // 1500–2700 kcal
    final exerciseMinutes = 20 + r.nextInt(81); // 20–100 นาที
    final sleepHours = 5 + r.nextInt(5); // 5–9 ชม.
    final steps = (exerciseMinutes * (100 + r.nextInt(51)))
        .toInt(); // 100–150 ก้าวต่อนาที

    final logsRef =
        _firestore.collection('users').doc(uid).collection('healthLogs');

    // 🔍 ตรวจว่ามี log ของวันนี้หรือยัง
    final existing =
        await logsRef.where('logDate', isEqualTo: logDate).limit(1).get();

    if (existing.docs.isNotEmpty) {
      // มีแล้ว → ไม่สร้างซ้ำ
      print('⏩ Health log already exists for $logDate (skip create)');
      return;
    }

    // 🆕 ยังไม่มี → สร้างใหม่
    await logsRef.add({
      'calories': calories,
      'exerciseMinutes': exerciseMinutes,
      'sleepHours': sleepHours,
      'steps': steps,
      'logDate': logDate,
      'createdAt': FieldValue.serverTimestamp(),
      'source': reason, // 'register' หรือ 'login'
    });

    print('✅ Created new health log for $logDate');
  }

  /// ✅ Register (Sign Up)
  Future<User?> register(
    String email,
    String password, {
    required String firstName,
    required String lastName,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'firstname': firstName,
        'lastname': lastName,
        'email': email,
        'role': 'free',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await result.user!.updateDisplayName("$firstName $lastName");
      await _createHealthLog(result.user!.uid, reason: 'register');

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
      await _createHealthLog(result.user!.uid, reason: 'login');
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
