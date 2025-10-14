import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';
import '../models/achievement_badge.dart';

class HealthDataProvider extends ChangeNotifier {
  HealthData _healthData = HealthData.initial();
  int _currentStreak = 5; // Demo streak
  DateTime _lastLogDate = DateTime.now();
  
  HealthData get healthData => _healthData;
  int get currentStreak => _currentStreak;
  
  HealthDataProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('healthData');
    
    if (savedData != null) {
      try {
        _healthData = HealthData.fromJson(jsonDecode(savedData));
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading health data: $e');
      }
    }
    
    // Load streak
    _currentStreak = prefs.getInt('currentStreak') ?? 5;
    final lastLog = prefs.getString('lastLogDate');
    if (lastLog != null) {
      _lastLogDate = DateTime.parse(lastLog);
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('healthData', jsonEncode(_healthData.toJson()));
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setString('lastLogDate', _lastLogDate.toIso8601String());
  }

  void updateSteps(int steps) {
    _healthData.steps = steps;
    _updateTodayHistory();
    _checkAndUpdateStreak();
    notifyListeners();
    _saveData();
  }

  void updateSleep(double hours) {
    _healthData.sleep = hours;
    _updateTodayHistory();
    _checkAndUpdateStreak();
    notifyListeners();
    _saveData();
  }

  void updateCalories(int calories) {
    _healthData.calories = calories;
    _updateTodayHistory();
    _checkAndUpdateStreak();
    notifyListeners();
    _saveData();
  }

  void _updateTodayHistory() {
    if (_healthData.history.isNotEmpty) {
      final today = _healthData.history.last;
      today.steps = _healthData.steps;
      today.sleep = _healthData.sleep;
      today.calories = _healthData.calories;
    }
  }

  void _checkAndUpdateStreak() {
    final now = DateTime.now();
    final difference = now.difference(_lastLogDate).inDays;
    
    if (difference == 0) {
      // Same day, streak continues
      return;
    } else if (difference == 1) {
      // Next day, increment streak
      _currentStreak++;
      _lastLogDate = now;
    } else {
      // Streak broken
      _currentStreak = 1;
      _lastLogDate = now;
    }
  }

  double get averageSleep {
    if (_healthData.history.isEmpty) return 0;
    final total = _healthData.history.fold<double>(
      0,
      (sum, day) => sum + day.sleep,
    );
    return total / _healthData.history.length;
  }

  int get averageSteps {
    if (_healthData.history.isEmpty) return 0;
    final total = _healthData.history.fold<int>(
      0,
      (sum, day) => sum + day.steps,
    );
    return total ~/ _healthData.history.length;
  }

  // Goal completion percentages
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

  // Get health insights
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
}