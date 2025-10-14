class HealthData {
  int steps;
  double sleep;
  int calories;
  List<DailyData> history;

  HealthData({
    required this.steps,
    required this.sleep,
    required this.calories,
    required this.history,
  });

  factory HealthData.initial() {
    return HealthData(
      steps: 6234,
      sleep: 7.5,
      calories: 1850,
      history: [
        DailyData(day: 'Mon', steps: 5200, sleep: 7.0, calories: 1650),
        DailyData(day: 'Tue', steps: 7800, sleep: 6.5, calories: 1900),
        DailyData(day: 'Wed', steps: 6100, sleep: 8.0, calories: 1750),
        DailyData(day: 'Thu', steps: 8900, sleep: 7.5, calories: 2100),
        DailyData(day: 'Fri', steps: 5600, sleep: 6.0, calories: 1600),
        DailyData(day: 'Sat', steps: 9200, sleep: 9.0, calories: 2200),
        DailyData(day: 'Sun', steps: 6234, sleep: 7.5, calories: 1850),
      ],
    );
  }

  // Helper getter for weekly steps data
  List<int> get weeklySteps {
    return history.map((day) => day.steps).toList();
  }

  // Helper getter for weekly sleep data
  List<double> get weeklySleep {
    return history.map((day) => day.sleep).toList();
  }

  // Helper getter for weekly calories data
  List<int> get weeklyCalories {
    return history.map((day) => day.calories).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'sleep': sleep,
      'calories': calories,
      'history': history.map((d) => d.toJson()).toList(),
    };
  }

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      steps: json['steps'] ?? 0,
      sleep: (json['sleep'] ?? 0.0).toDouble(),
      calories: json['calories'] ?? 0,
      history: (json['history'] as List?)
              ?.map((d) => DailyData.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class DailyData {
  String day;
  int steps;
  double sleep;
  int calories;

  DailyData({
    required this.day,
    required this.steps,
    required this.sleep,
    required this.calories,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'steps': steps,
      'sleep': sleep,
      'calories': calories,
    };
  }

  factory DailyData.fromJson(Map<String, dynamic> json) {
    return DailyData(
      day: json['day'] ?? '',
      steps: json['steps'] ?? 0,
      sleep: (json['sleep'] ?? 0.0).toDouble(),
      calories: json['calories'] ?? 0,
    );
  }
}