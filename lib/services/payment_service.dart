import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentService {
  PaymentService._();
  static final instance = PaymentService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// คืนรูปแบบวันที่ "YYYY-MM-DD"
  String _yyyyMmDd(DateTime dt) {
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    return '${dt.year}-$mm-$dd';
  }

  /// ชำระเงิน (จำลอง): สร้าง subscription + สร้าง payment + set role=premium
  Future<void> createMockPayment({
    required int amountTHB,
    required String currency,
    required String provider,
    int days = 30, // อายุแพ็กเกจ
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No logged-in user');
    }

    final uid = user.uid;
    final now = DateTime.now();
    final start = _yyyyMmDd(now);
    final end = _yyyyMmDd(now.add(Duration(days: days)));

    final userRef = _db.collection('users').doc(uid);
    final subsRef = userRef.collection('subscriptions');

    await _db.runTransaction((txn) async {
      // 1) สร้าง subscription ใหม่ (active)
      final newSubRef = subsRef.doc(); // random id
      txn.set(newSubRef, {
        'plan': 'premium',
        'status': 'active',
        'startDate': start,
        'endDate': end,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2) สร้าง payment ใต้ subscription
      final payRef = newSubRef.collection('payments').doc();
      txn.set(payRef, {
        'amount': amountTHB,
        'currency': currency,
        'provider': provider,
        'paidAt': FieldValue.serverTimestamp(),
        'reference':
            'PMT-${DateTime.now().millisecondsSinceEpoch}', // เลขอ้างอิง mock
      });

      // 3) อัปเดต role ผู้ใช้
      txn.update(userRef, {'role': 'premium'});
    });
  }

  /// ยกเลิกแพ็กเกจ: set status=cancelled ของ subscription ล่าสุด + role=free
  Future<void> cancelPremium() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No logged-in user');

    final uid = user.uid;
    final userRef = _db.collection('users').doc(uid);
    final subsRef = userRef.collection('subscriptions');

    // หา subscription ล่าสุดด้วย createdAt (หรือ endDate)
    final last =
        await subsRef.orderBy('createdAt', descending: true).limit(1).get();

    await _db.runTransaction((txn) async {
      if (last.docs.isNotEmpty) {
        txn.update(last.docs.first.reference, {'status': 'cancelled'});
      }
      txn.update(userRef, {'role': 'free'});
    });
  }
}
