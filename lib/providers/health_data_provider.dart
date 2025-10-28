import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ โมเดลที่คุณแก้ไว้ให้เก็บ logs จาก Firestore
import '../models/health_data.dart';

// (ออปชัน) ถ้ามีระบบ badges แยกเป็นโมเดลไว้แล้วใช้ต่อได้เลย
import '../models/achievement_badge.dart';

// ✅ Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HealthDataProvider extends ChangeNotifier {
  // ---------------- State หลัก ----------------
  HealthData _healthData = HealthData.initial();
  int _currentStreak = 0;
  DateTime _lastLogDate = DateTime.now();

  HealthData get healthData => _healthData;
  int get currentStreak => _currentStreak;

  // ---------------- Firebase & Subscriptions ----------------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _logsSub;

  // ---------------- Ctor ----------------
  HealthDataProvider() {
    _loadLocalCache(); // อ่านค่าที่เคย cache ไว้ใน SharedPreferences
    _attachAuthListener(); // ฟังการล็อกอิน/ล็อกเอาท์ แล้ว subscribe logs
  }

  // ---------------- Local cache (optional) ----------------
  Future<void> _loadLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    // HealthData cache
    final String? saved = prefs.getString('healthData');
    if (saved != null) {
      try {
        _healthData = HealthData.fromJson(jsonDecode(saved));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading healthData cache: $e');
      }
    }
    // Streak cache
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    final lastLog = prefs.getString('lastLogDate');
    if (lastLog != null) {
      _lastLogDate = DateTime.tryParse(lastLog) ?? DateTime.now();
    }
  }

  Future<void> _saveLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('healthData', jsonEncode(_healthData.toJson()));
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setString('lastLogDate', _lastLogDate.toIso8601String());
  }

  // ---------------- Auth & Logs listeners ----------------
  void _attachAuthListener() {
    _authSub?.cancel();
    _authSub = _auth.authStateChanges().listen((user) {
      if (user == null) {
        _logsSub?.cancel();
        // เคลียร์ logs เมื่อออกจากระบบ
        _healthData = HealthData.initial();
        _currentStreak = 0;
        notifyListeners();
      } else {
        _listenUserLogs(user.uid);
      }
    });
  }

  void _listenUserLogs(String uid) {
    _logsSub?.cancel();
    _logsSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('healthLogs')
        .orderBy('logDate', descending: true)
        .limit(90)
        .snapshots()
        .listen((snap) {
      // ✅ แปลง log ทั้งหมดจาก Firestore
      final logs = snap.docs.map((d) => HealthLog.fromDoc(d)).toList();

      // ✅ เรียงซ้ำตาม createdAt ล่าสุดจริง
      logs.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime); // ล่าสุดอยู่ข้างหน้า
      });

      // ✅ เก็บใน HealthData
      _healthData.logs = logs;

      // ✅ อัปเดตค่าล่าสุด (steps / sleep / calories)
      _healthData.hydrateFromLatest();

      // ✅ บันทึก streak และ cache
      _recalculateStreakFromLogs();
      _saveLocalCache();

      // ✅ แจ้ง UI ให้รีเฟรช
      notifyListeners();

      // 🔍 (ออปชัน) Debug log ดูค่า log ล่าสุดใน console
      final latest = logs.isNotEmpty ? logs.first : null;
      if (latest != null) {
        debugPrint(
            '✅ Latest log: ${latest.source} | ${latest.logDate} | calories=${latest.calories} | steps=${latest.steps}');
      }
    }, onError: (e) {
      debugPrint('listen healthLogs error: $e');
    });
  }

  // ---------------- Streak จาก Firestore logs ----------------
  void _recalculateStreakFromLogs() {
    final logs = List<HealthLog>.from(_healthData.logs);
    if (logs.isEmpty) {
      _currentStreak = 0;
      return;
    }
    // เรียงล่าสุด -> เก่าสุด
    logs.sort((a, b) => b.logDate.compareTo(a.logDate));

    int streak = 1;
    DateTime prev = DateTime(logs.first.logDate.year, logs.first.logDate.month,
        logs.first.logDate.day);

    for (int i = 1; i < logs.length; i++) {
      final cur = DateTime(
          logs[i].logDate.year, logs[i].logDate.month, logs[i].logDate.day);
      final gap = prev.difference(cur).inDays;
      if (gap == 1) {
        streak++;
        prev = cur;
      } else if (gap > 1) {
        break; // ขาดช่วงแล้วหยุด
      } else {
        // gap == 0 (หลาย log วันเดียวกัน) → ข้ามไป
        prev = cur;
      }
    }

    _currentStreak = streak;
    _lastLogDate = logs.first.logDate;
  }

  // ---------------- Optional manual updates (local-only) ----------------
  // ถ้าคุณมี UI ให้ผู้ใช้แก้ค่าเองชั่วคราว สามารถใช้ฟังก์ชันนี้ได้
  // หมายเหตุ: ฟังก์ชันเหล่านี้จะไม่ไปแก้ Firestore
  void updateSteps(int steps) {
    _healthData.steps = steps;
    notifyListeners();
    _saveLocalCache();
  }

  void updateSleep(double hours) {
    _healthData.sleep = hours;
    notifyListeners();
    _saveLocalCache();
  }

  void updateCalories(int calories) {
    _healthData.calories = calories;
    notifyListeners();
    _saveLocalCache();
  }

  // ---------------- สรุป/ตัวชี้วัดสำหรับ UI ----------------
  double get averageSleep {
    final series = _healthData.weeklySleep; // จาก logs 7 วันล่าสุด
    if (series.isEmpty) return 0;
    final total = series.reduce((a, b) => a + b);
    return total / series.length;
  }

  int get averageSteps {
    // คิดจาก exerciseMinutes โดยประมาณ (ในโมเดลคูณ 120 ไว้แล้ว)
    final series = _healthData.weeklySteps;
    if (series.isEmpty) return 0;
    final total = series.fold<int>(0, (s, v) => s + v);
    return total ~/ series.length;
  }

  double get stepsGoalPercentage {
    return (_healthData.steps / 10000).clamp(0.0, 1.0);
  }

  double get sleepGoalPercentage {
    return (_healthData.sleep / 8).clamp(0.0, 1.0);
  }

  double get caloriesGoalPercentage {
    return (_healthData.calories / 2000).clamp(0.0, 1.0);
  }

  bool get hasMetDailyGoals {
    return _healthData.steps >= 10000 &&
        _healthData.sleep >= 8 &&
        _healthData.calories >= 1800;
  }

  List<AchievementBadge> get badges {
    return [
      AchievementBadge(
        title: 'Sleep Champion',
        description: '7 days of consistent sleep',
        icon: '🌙',
        color: const Color(0xFFA8B5A0),
      ),
      AchievementBadge(
        title: 'Healthy Eater',
        description: 'Tracked 50 meals',
        icon: '🥗',
        color: const Color(0xFFE8C4A0),
      ),
      AchievementBadge(
        title: 'Active Achiever',
        description: 'Completed 10 workouts',
        icon: '💪',
        color: const Color(0xFFA0C4E8),
      ),
      AchievementBadge(
        title: 'Streak Master',
        description: '$_currentStreak day streak',
        icon: '🔥',
        color: const Color(0xFFFF6B6B),
      ),
    ];
  }

  String get todayInsight {
    if (hasMetDailyGoals) {
      return "Amazing! You've met all your daily goals! 🎉";
    } else if (stepsGoalPercentage > 0.8) {
      return "Great job! You're almost at your step goal!";
    } else if (sleepGoalPercentage < 0.7) {
      return "Try to get more sleep tonight. Your body needs rest!";
    } else {
      return "Keep pushing! You're making progress!";
    }
  }

  // ---------------- lifecycle ----------------
  @override
  void dispose() {
    _authSub?.cancel();
    _logsSub?.cancel();
    super.dispose();
  }
}
