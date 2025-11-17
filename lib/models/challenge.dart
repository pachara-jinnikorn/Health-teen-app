import 'package:cloud_firestore/cloud_firestore.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final String duration; // e.g., '1 week', '2 weeks'
  final int durationDays;
  final int participants;
  final String reward;
  final int rewardPoints;
  final String category;
  final String icon;
  final DateTime createdAt;
  final bool isActive;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.durationDays,
    required this.participants,
    required this.reward,
    required this.rewardPoints,
    required this.category,
    required this.icon,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'duration': duration,
      'durationDays': durationDays,
      'participants': participants,
      'reward': reward,
      'rewardPoints': rewardPoints,
      'category': category,
      'icon': icon,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'Medium',
      duration: json['duration'] ?? '1 week',
      durationDays: json['durationDays'] ?? 7,
      participants: json['participants'] ?? 0,
      reward: json['reward'] ?? '0 points',
      rewardPoints: json['rewardPoints'] ?? 0,
      category: json['category'] ?? 'General',
      icon: json['icon'] ?? '🎯',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: json['isActive'] ?? true,
    );
  }
}

class UserChallenge {
  final String id;
  final String challengeId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double progress;
  final String status; // 'active', 'completed', 'failed'
  final DateTime? completedDate;
  final int currentValue;
  final int targetValue;

  UserChallenge({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.status,
    this.completedDate,
    required this.currentValue,
    required this.targetValue,
  });

  int get daysLeft {
    if (status == 'completed') return 0;
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeId': challengeId,
      'userId': userId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'progress': progress,
      'status': status,
      'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'currentValue': currentValue,
      'targetValue': targetValue,
    };
  }

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    return UserChallenge(
      id: json['id'] ?? '',
      challengeId: json['challengeId'] ?? '',
      userId: json['userId'] ?? '',
      startDate: (json['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (json['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      progress: (json['progress'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'active',
      completedDate: (json['completedDate'] as Timestamp?)?.toDate(),
      currentValue: json['currentValue'] ?? 0,
      targetValue: json['targetValue'] ?? 100,
    );
  }
}