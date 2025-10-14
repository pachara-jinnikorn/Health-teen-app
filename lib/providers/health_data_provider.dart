import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_data.dart';
import '../models/achievement_badge.dart'; // Import AchievementBadge model

class HealthDataProvider extends ChangeNotifier {
  HealthData _healthData = HealthData.initial();
  
  HealthData get healthData => _healthData;
  
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
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('healthData', jsonEncode(_healthData.toJson()));
  }

  void updateSteps(int steps) {
    _healthData.steps = steps;
    _updateTodayHistory();
    notifyListeners();
    _saveData();
  }

  void updateSleep(double hours) {
    _healthData.sleep = hours;
    _updateTodayHistory();
    notifyListeners();
    _saveData();
  }

  void updateCalories(int calories) {
    _healthData.calories = calories;
    _updateTodayHistory();
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
    ];
  }
}
