import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/challenge.dart';
import 'dart:async';

class ChallengeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Challenge> _allChallenges = [];
  List<UserChallenge> _activeChallenges = [];
  List<UserChallenge> _completedChallenges = [];
  
  bool _isLoading = false;
  StreamSubscription? _challengesSubscription;
  StreamSubscription? _userChallengesSubscription;
  String? _currentUserId;
  
  List<Challenge> get allChallenges => _allChallenges;
  List<UserChallenge> get activeChallenges => _activeChallenges;
  List<UserChallenge> get completedChallenges => _completedChallenges;
  bool get isLoading => _isLoading;

  ChallengeProvider() {
    _initializeChallenges();
  }

  void _initializeChallenges() {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        _clearData();
      } else if (_currentUserId != user.uid) {
        _currentUserId = user.uid;
        _loadChallenges();
        _loadUserChallenges();
      }
    });

    final user = _auth.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      _loadChallenges();
      _loadUserChallenges();
    }
  }

  void _clearData() {
    _challengesSubscription?.cancel();
    _userChallengesSubscription?.cancel();
    _challengesSubscription = null;
    _userChallengesSubscription = null;
    _allChallenges.clear();
    _activeChallenges.clear();
    _completedChallenges.clear();
    _isLoading = false;
    _currentUserId = null;
    notifyListeners();
  }

  // Load all available challenges from Firebase
  void _loadChallenges() {
    _challengesSubscription?.cancel();
    
    _challengesSubscription = _firestore
        .collection('challenges')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _allChallenges = snapshot.docs
          .map((doc) => Challenge.fromJson(doc.data()))
          .toList();
      
      // Sort by participants (most popular first)
      _allChallenges.sort((a, b) => b.participants.compareTo(a.participants));
      
      notifyListeners();
    }, onError: (error) {
      debugPrint('❌ Error loading challenges: $error');
    });
  }

  // Load user's challenges
  void _loadUserChallenges() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _userChallengesSubscription?.cancel();
    
    _userChallengesSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('userChallenges')
        .snapshots()
        .listen((snapshot) {
      final allUserChallenges = snapshot.docs
          .map((doc) => UserChallenge.fromJson(doc.data()))
          .toList();

      // Separate active and completed
      _activeChallenges = allUserChallenges
          .where((uc) => uc.status == 'active')
          .toList();
      
      _completedChallenges = allUserChallenges
          .where((uc) => uc.status == 'completed')
          .toList();

      // Sort by end date
      _activeChallenges.sort((a, b) => a.endDate.compareTo(b.endDate));
      _completedChallenges.sort((a, b) => b.completedDate!.compareTo(a.completedDate!));
      
      notifyListeners();
    }, onError: (error) {
      debugPrint('❌ Error loading user challenges: $error');
    });
  }

  // Get challenge by ID
  Challenge? getChallengeById(String challengeId) {
    try {
      return _allChallenges.firstWhere((c) => c.id == challengeId);
    } catch (e) {
      return null;
    }
  }

  // Check if user has joined a challenge
  bool hasJoinedChallenge(String challengeId) {
    return _activeChallenges.any((uc) => uc.challengeId == challengeId);
  }

  // Join a challenge
  Future<void> joinChallenge(Challenge challenge) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Check if already joined
      if (hasJoinedChallenge(challenge.id)) {
        throw Exception('You have already joined this challenge');
      }

      final now = DateTime.now();
      final endDate = now.add(Duration(days: challenge.durationDays));
      
      final userChallengeId = _firestore
          .collection('users')
          .doc(userId)
          .collection('userChallenges')
          .doc()
          .id;

      final userChallenge = UserChallenge(
        id: userChallengeId,
        challengeId: challenge.id,
        userId: userId,
        startDate: now,
        endDate: endDate,
        progress: 0.0,
        status: 'active',
        currentValue: 0,
        targetValue: _getTargetValue(challenge),
      );

      // Save user challenge
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('userChallenges')
          .doc(userChallengeId)
          .set(userChallenge.toJson());

      // Increment participants count
      await _firestore
          .collection('challenges')
          .doc(challenge.id)
          .update({
        'participants': FieldValue.increment(1),
      });

      debugPrint('✅ Joined challenge: ${challenge.title}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error joining challenge: $e');
      rethrow;
    }
  }

  // Get target value based on challenge
  int _getTargetValue(Challenge challenge) {
    // Customize based on challenge type
    if (challenge.title.contains('10,000 Steps')) {
      return 7; // 7 days of 10k steps
    } else if (challenge.title.contains('Sleep')) {
      return 7; // 7 days of 8h sleep
    } else if (challenge.title.contains('Hydration')) {
      return 7; // 7 days of 8 glasses
    }
    return 7; // Default: 7 days
  }

  // Update challenge progress
Future<void> updateChallengeProgress(
  String userChallengeId,
  int currentValue,
) async {
  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Find the user challenge
    final userChallenge = _activeChallenges.firstWhere(
      (uc) => uc.id == userChallengeId,
    );

    final progress = (currentValue / userChallenge.targetValue).clamp(0.0, 1.0);
    final isCompleted = progress >= 1.0;

    // ✅ FIXED: Use proper type for updates map
    final Map<String, dynamic> updates = {
      'currentValue': currentValue,
      'progress': progress,
    };

    if (isCompleted) {
      updates['status'] = 'completed';
      updates['completedDate'] = FieldValue.serverTimestamp();
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('userChallenges')
        .doc(userChallengeId)
        .update(updates);

    debugPrint('✅ Updated challenge progress: $progress');
    notifyListeners();
  } catch (e) {
    debugPrint('❌ Error updating challenge progress: $e');
  }
}

  // Leave/quit a challenge
  Future<void> leaveChallenge(String userChallengeId, String challengeId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('userChallenges')
          .doc(userChallengeId)
          .delete();

      // Decrement participants count
      await _firestore
          .collection('challenges')
          .doc(challengeId)
          .update({
        'participants': FieldValue.increment(-1),
      });

      debugPrint('✅ Left challenge');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error leaving challenge: $e');
    }
  }

  // Initialize default challenges (call this once to populate database)
  Future<void> initializeDefaultChallenges() async {
    final defaultChallenges = [
      Challenge(
        id: 'challenge_steps_10k',
        title: '10,000 Steps Challenge',
        description: 'Walk 10,000 steps every day for a week',
        difficulty: 'Medium',
        duration: '1 week',
        durationDays: 7,
        participants: 0,
        reward: '50 points',
        rewardPoints: 50,
        category: 'Fitness',
        icon: '🚶',
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: 'challenge_hydration',
        title: 'Hydration Hero',
        description: 'Drink 8 glasses of water daily',
        difficulty: 'Easy',
        duration: '1 week',
        durationDays: 7,
        participants: 0,
        reward: '30 points',
        rewardPoints: 30,
        category: 'Nutrition',
        icon: '💧',
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: 'challenge_sleep',
        title: 'Sleep Champion',
        description: 'Get 8 hours of sleep for 7 days',
        difficulty: 'Hard',
        duration: '1 week',
        durationDays: 7,
        participants: 0,
        reward: '75 points',
        rewardPoints: 75,
        category: 'Sleep',
        icon: '😴',
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: 'challenge_meditation',
        title: 'Mindful Minutes',
        description: 'Meditate for 10 minutes daily',
        difficulty: 'Easy',
        duration: '1 week',
        durationDays: 7,
        participants: 0,
        reward: '40 points',
        rewardPoints: 40,
        category: 'Mental Health',
        icon: '🧘',
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: 'challenge_yoga',
        title: 'Yoga Journey',
        description: 'Practice yoga for 30 minutes, 5 days a week',
        difficulty: 'Medium',
        duration: '2 weeks',
        durationDays: 14,
        participants: 0,
        reward: '120 points',
        rewardPoints: 120,
        category: 'Fitness',
        icon: '🧘‍♀️',
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: 'challenge_fruits_veggies',
        title: 'Fruit & Veggie Power',
        description: 'Eat 5 servings of fruits and vegetables daily',
        difficulty: 'Easy',
        duration: '1 week',
        durationDays: 7,
        participants: 0,
        reward: '50 points',
        rewardPoints: 50,
        category: 'Nutrition',
        icon: '🥗',
        createdAt: DateTime.now(),
      ),
      Challenge(
        id: 'challenge_no_sugar',
        title: 'No Sugar Week',
        description: 'Avoid added sugars for 7 days',
        difficulty: 'Hard',
        duration: '1 week',
        durationDays: 7,
        participants: 0,
        reward: '150 points',
        rewardPoints: 150,
        category: 'Nutrition',
        icon: '🍬',
        createdAt: DateTime.now(),
      ),
    ];

    for (var challenge in defaultChallenges) {
      try {
        await _firestore
            .collection('challenges')
            .doc(challenge.id)
            .set(challenge.toJson());
        debugPrint('✅ Created challenge: ${challenge.title}');
      } catch (e) {
        debugPrint('❌ Error creating challenge ${challenge.title}: $e');
      }
    }
  }

  @override
  void dispose() {
    _challengesSubscription?.cancel();
    _userChallengesSubscription?.cancel();
    super.dispose();
  }
}