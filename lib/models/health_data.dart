import 'package:cloud_firestore/cloud_firestore.dart';

/// หนึ่งแถวของ health log ใน Firestore
class HealthLog {
  final String id; // doc id
  final DateTime logDate; // จาก "YYYY-MM-DD"
  final int calories; // kcal
  final int exerciseMinutes; // นาที
  final int sleepHours; // ชั่วโมง (int ตามสคีมา)
  final int steps; // ✅ จำนวนก้าว (ใหม่)
  final String source; // 'register' | 'login' | etc.
  final DateTime? createdAt; // serverTimestamp

  const HealthLog({
    required this.id,
    required this.logDate,
    required this.calories,
    required this.exerciseMinutes,
    required this.sleepHours,
    required this.steps,
    required this.source,
    required this.createdAt,
  });

  /// แปลงจาก Firestore
  factory HealthLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};

    // logDate เก็บรูปแบบ "YYYY-MM-DD"
    final String dateStr = (d['logDate'] ?? '') as String;
    final parts = dateStr.split('-');
    final date = (parts.length == 3)
        ? DateTime(
            int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]))
        : DateTime.now();

    // ✅ ถ้าเอกสารเก่าไม่มี 'steps' ให้ประมาณจาก exerciseMinutes * 120
    final exMin = (d['exerciseMinutes'] ?? 0) as int;
    final stepsFromDocOrEstimate = (d['steps'] ?? (exMin * 120)) as int;

    return HealthLog(
      id: doc.id,
      logDate: date,
      calories: (d['calories'] ?? 0) as int,
      exerciseMinutes: exMin,
      sleepHours: (d['sleepHours'] ?? 0) as int,
      steps: stepsFromDocOrEstimate,
      source: (d['source'] ?? '') as String,
      createdAt: d['createdAt'] is Timestamp
          ? (d['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// สำหรับเก็บลง local หรือส่งต่อภายในแอป
  Map<String, dynamic> toJson() => {
        'id': id,
        'logDate':
            logDate.toIso8601String().split('T').first, // คงรูปแบบ YYYY-MM-DD
        'calories': calories,
        'exerciseMinutes': exerciseMinutes,
        'sleepHours': sleepHours,
        'steps': steps, // ✅
        'source': source,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory HealthLog.fromJson(Map<String, dynamic> json) => HealthLog(
        id: json['id'] ?? '',
        logDate: DateTime.parse('${json['logDate']}T00:00:00.000Z'),
        calories: json['calories'] ?? 0,
        exerciseMinutes: json['exerciseMinutes'] ?? 0,
        sleepHours: json['sleepHours'] ?? 0,
        steps:
            json['steps'] ?? (json['exerciseMinutes'] ?? 0) * 120, // ✅ fallback
        source: json['source'] ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : null,
      );
}

/// สรุปสถานะปัจจุบัน + คลัง logs ของผู้ใช้
class HealthData {
  /// ค่า “ปัจจุบัน” สำหรับการ์ดบนแดชบอร์ด (อาจคำนวณจาก log ล่าสุด)
  int steps; // จำนวนก้าววันนี้
  double sleep; // ชั่วโมงวันนี้ (double เพื่อโชว์ทศนิยมสวย ๆ)
  int calories; // kcal วันนี้

  /// คลัง health logs จาก Firestore
  List<HealthLog> logs;

  HealthData({
    required this.steps,
    required this.sleep,
    required this.calories,
    required this.logs,
  });

  /// ค่าเริ่มต้น (ไม่มี log)
  factory HealthData.initial() => HealthData(
        steps: 0,
        sleep: 0,
        calories: 0,
        logs: const [],
      );

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'sleep': sleep,
        'calories': calories,
        'logs': logs.map((e) => e.toJson()).toList(),
      };

  factory HealthData.fromJson(Map<String, dynamic> json) => HealthData(
        steps: json['steps'] ?? 0,
        sleep: (json['sleep'] ?? 0.0).toDouble(),
        calories: json['calories'] ?? 0,
        logs: (json['logs'] as List<dynamic>? ?? [])
            .map((e) => HealthLog.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  // --------- Helpers สำหรับกราฟ 7 วันล่าสุด ---------

  /// วันที่ย้อนหลัง 7 วัน (เรียงเก่าสุด -> ล่าสุด)
  List<DateTime> get last7Days {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    return List.generate(7, (i) => base.subtract(Duration(days: 6 - i)));
  }

  /// map: YYYY-MM-DD -> HealthLog (เลือกล่าสุดของวันนั้นถ้ามีหลายรายการ)
  Map<String, HealthLog> get _logByDateKey {
    final map = <String, HealthLog>{};
    for (final l in logs) {
      final key = _dateKey(l.logDate);
      // ถ้ามีหลาย log วันเดียวกัน เลือก createdAt ล่าสุด
      final existing = map[key];
      if (existing == null ||
          (l.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)).isAfter(
              existing.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))) {
        map[key] = l;
      }
    }
    return map;
  }

  /// series: calories 7 วัน
  List<int> get weeklyCalories {
    final byKey = _logByDateKey;
    return last7Days.map((d) => byKey[_dateKey(d)]?.calories ?? 0).toList();
  }

  /// series: sleep (ชั่วโมง) 7 วัน
  List<double> get weeklySleep {
    final byKey = _logByDateKey;
    return last7Days
        .map((d) => (byKey[_dateKey(d)]?.sleepHours ?? 0).toDouble())
        .toList();
  }

  /// series: exercise minutes 7 วัน
  List<int> get weeklyExerciseMinutes {
    final byKey = _logByDateKey;
    return last7Days
        .map((d) => byKey[_dateKey(d)]?.exerciseMinutes ?? 0)
        .toList();
  }

  /// ✅ series: steps 7 วัน (ใช้ค่าจาก log จริง; ถ้าไม่มีให้ fallback จาก exerciseMinutes*120)
  List<int> get weeklySteps {
    final byKey = _logByDateKey;
    return last7Days.map((d) {
      final log = byKey[_dateKey(d)];
      if (log == null) return 0;
      return log.steps != 0 ? log.steps : log.exerciseMinutes * 120;
    }).toList();
  }

  /// อัปเดตค่า “ปัจจุบัน” จาก log ล่าสุด (ถ้ามี)
  void hydrateFromLatest() {
    if (logs.isEmpty) return;
    logs.sort((a, b) => b.logDate.compareTo(a.logDate));
    final latest = logs.first;
    calories = latest.calories;
    sleep = latest.sleepHours.toDouble();
    steps = latest.steps != 0 ? latest.steps : latest.exerciseMinutes * 120;
  }

  static String _dateKey(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }
}
