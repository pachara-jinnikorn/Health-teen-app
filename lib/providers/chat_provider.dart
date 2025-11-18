import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../models/health_data.dart';
import 'dart:async';
import '../services/premium_ai_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService();

  List<Conversation> _conversations = [];
  bool _isAITyping = false;
  StreamSubscription? _conversationsSubscription; // ✅ Track subscription
  String? _currentUserId; // ✅ Track current user

  List<Conversation> get conversations => _conversations;
  bool get isAITyping => _isAITyping;

  ChatProvider() {
    _initializeChat();
  }

  /// ✅ Initialize chat and listen to auth changes
  Future<void> _initializeChat() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        // User logged out - clear everything
        _clearData();
      } else if (_currentUserId != user.uid) {
        // Different user logged in - reload data
        _currentUserId = user.uid;
        _reloadData();
      }
    });

    // Initial load if user is already logged in
    final user = _auth.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      await ensureAIConversationExists();
      _loadConversations();
    }
  }

  /// ✅ Clear all data when user logs out
  void _clearData() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = null;
    _conversations.clear();
    _isAITyping = false;
    _currentUserId = null;
    notifyListeners();
  }

  /// ✅ Reload data for new user
  Future<void> _reloadData() async {
    _clearData();
    await ensureAIConversationExists();
    _loadConversations();
  }

  /// ✅ Load conversations from Firestore
  void _loadConversations() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      debugPrint('❌ No user logged in');
      return;
    }

    debugPrint('✅ Loading conversations for user: $userId');

    // Cancel previous subscription if exists
    _conversationsSubscription?.cancel();

    _conversationsSubscription = _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      debugPrint('📨 Got ${snapshot.docs.length} conversations');

      _conversations = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              debugPrint('📋 Conversation data: $data');
              return Conversation.fromJson(data);
            } catch (e) {
              debugPrint('❌ Error parsing conversation: $e');
              return null;
            }
          })
          .where((conv) => conv != null)
          .cast<Conversation>()
          .toList();

      // Sort by timestamp (newest first)
      _conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint('✅ Loaded ${_conversations.length} conversations');
      notifyListeners();
    }, onError: (error) {
      debugPrint('❌ Error loading conversations: $error');
    });
  }

  /// ✅ PUBLIC method to ensure AI conversation exists
  Future<void> ensureAIConversationExists() async {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      debugPrint('❌ No user logged in');
      return;
    }

    try {
      final aiConvId = 'ai_$userId';
      debugPrint('🔍 Checking AI conversation: $aiConvId');

      final aiConvRef = _firestore.collection('conversations').doc(aiConvId);
      final aiConvDoc = await aiConvRef.get();

      if (!aiConvDoc.exists) {
        debugPrint('✅ Creating AI conversation...');

        final now = DateTime.now();

        // Create AI conversation document
        try {
          await aiConvRef.set({
            'id': aiConvId,
            'name': 'Dr. Wellness',
            'avatar': '👨‍⚕️',
            'lastMessage': 'Hi! I\'m Dr. Wellness, your AI health coach.',
            'timestamp': Timestamp.fromDate(now),
            'isAI': true,
            'participants': [userId],
          });

          debugPrint('✅ AI conversation created successfully');
        } catch (e) {
          debugPrint('❌ Failed to create AI conversation: $e');
          rethrow; // ให้ error ออกมา
        }

        await Future.delayed(const Duration(milliseconds: 500));

        // Add welcome message
        final welcomeMessageId = now.millisecondsSinceEpoch.toString();

        try {
          await _firestore
              .collection('conversations')
              .doc(aiConvId)
              .collection('messages')
              .doc(welcomeMessageId)
              .set({
            'id': welcomeMessageId,
            'senderId': 'ai',
            'senderName': 'Dr. Wellness',
            'content':
                'Hi! I\'m Dr. Wellness, your AI health coach. How can I help you today?',
            'timestamp': Timestamp.fromDate(now),
          });

          debugPrint('✅ Welcome message added');
        } catch (e) {
          debugPrint('❌ Failed to add welcome message: $e');
          // ไม่ throw เพราะ conversation สร้างสำเร็จแล้ว
        }
      } else {
        debugPrint('✅ AI conversation already exists');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in ensureAIConversationExists: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// ✅ Get messages stream for a conversation
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    final currentUserId = _auth.currentUser?.uid ?? '';

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      debugPrint(
          '📨 Got ${snapshot.docs.length} messages for conversation: $conversationId');
      return snapshot.docs
          .map((doc) {
            try {
              return ChatMessage.fromJson(doc.data(), currentUserId);
            } catch (e) {
              debugPrint('❌ Error parsing message: $e');
              return null;
            }
          })
          .where((msg) => msg != null)
          .cast<ChatMessage>()
          .toList();
    });
  }

  /// ✅ Send a regular message (non-AI)
  Future<void> sendMessage(String conversationId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final firstName = userData?['firstname'] ?? 'User';
      final lastName = userData?['lastname'] ?? '';
      final displayName =
          lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      final messageId = DateTime.now().millisecondsSinceEpoch.toString();

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .set({
        'id': messageId,
        'senderId': user.uid,
        'senderName': displayName,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
    }
  }

  /// ✅ Send a message to AI chatbot and get response
  Future<void> sendAIMessage(
    String conversationId,
    String content,
    HealthData? healthData,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final firstName = userData?['firstname'] ?? 'User';
      final lastName = userData?['lastname'] ?? '';
      final displayName =
          lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      // Add user message
      final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(userMessageId)
          .set({
        'id': userMessageId,
        'senderId': user.uid,
        'senderName': displayName,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show typing indicator
      _isAITyping = true;
      notifyListeners();

      // Get AI response
      final aiResponse = await _aiService.sendMessage(
        conversationId: conversationId,
        message: content,
        userHealthData: healthData,
      );

      // Add AI message
      final aiMessageId = DateTime.now().millisecondsSinceEpoch.toString();

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(aiMessageId)
          .set({
        'id': aiMessageId,
        'senderId': 'ai',
        'senderName': 'Dr. Wellness',
        'content': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _isAITyping = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error sending AI message: $e');
      _isAITyping = false;
      notifyListeners();
    }
  }

  /// ✅ Create a new conversation with another user (with Privacy check)
  Future<String?> createConversation(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

      // ✅ ตรวจสอบ privacy ก่อน (เพิ่มส่วนนี้)
      final otherUserDoc =
          await _firestore.collection('users').doc(otherUserId).get();

      if (!otherUserDoc.exists) {
        debugPrint('❌ User not found');
        return null;
      }

      final otherUserData = otherUserDoc.data();

      // ตรวจสอบว่า user อนุญาตให้ส่งข้อความได้ไหม
      final privacy =
          otherUserData?['privacySettings'] as Map<String, dynamic>?;
      final allowMessages = privacy?['allowMessages'] ?? true; // default true

      if (!allowMessages) {
        debugPrint('🔒 User has disabled messages');
        return null;
      }

      // Check if conversation already exists
      final existingConv = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .where('isAI', isEqualTo: false)
          .get();

      for (var doc in existingConv.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }

      // Create new conversation
      final firstName = otherUserData?['firstname'] ?? 'User';
      final lastName = otherUserData?['lastname'] ?? '';
      final displayName =
          lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      final convId = _firestore.collection('conversations').doc().id;

      await _firestore.collection('conversations').doc(convId).set({
        'id': convId,
        'name': displayName,
        'avatar': '👤',
        'lastMessage': 'Start a conversation',
        'timestamp': FieldValue.serverTimestamp(),
        'isAI': false,
        'participants': [currentUserId, otherUserId],
      });

      return convId;
    } catch (e) {
      debugPrint('❌ Error creating conversation: $e');
      return null;
    }
  }

  // ✅ Method 1: Create Premium AI conversation
  Future<String?> getOrCreatePremiumAIConversation() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final premiumAIConvId = 'premium_ai_$userId';
      final premiumAIConvRef =
          _firestore.collection('conversations').doc(premiumAIConvId);
      final premiumAIConvDoc = await premiumAIConvRef.get();

      if (!premiumAIConvDoc.exists) {
        final now = DateTime.now();

        await premiumAIConvRef.set({
          'id': premiumAIConvId,
          'name': 'Health Guru',
          'avatar': '🤖',
          'lastMessage': 'Hi! I\'m Health Guru ✨',
          'timestamp': Timestamp.fromDate(now),
          'isAI': true,
          'isPremiumAI': true,
          'participants': [userId],
        });

        await Future.delayed(const Duration(milliseconds: 500));

        final welcomeMessageId = now.millisecondsSinceEpoch.toString();
        await _firestore
            .collection('conversations')
            .doc(premiumAIConvId)
            .collection('messages')
            .doc(welcomeMessageId)
            .set({
          'id': welcomeMessageId,
          'senderId': 'premium_ai',
          'senderName': 'Health Guru',
          'content':
              'Hello! I\'m Health Guru, your Premium AI Assistant! 🤖✨\n\nI can help with personalized health advice. What would you like to discuss?',
          'timestamp': Timestamp.fromDate(now),
        });
      }

      return premiumAIConvId;
    } catch (e) {
      debugPrint('❌ Error: $e');
      return null;
    }
  }

  // ✅ Method 2: Send message to Premium AI
  Future<void> sendPremiumAIMessage(
      String conversationId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final firstName = userData?['firstname'] ?? 'User';
      final lastName = userData?['lastname'] ?? '';
      final displayName =
          lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      // Add user message
      final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(userMessageId)
          .set({
        'id': userMessageId,
        'senderId': user.uid,
        'senderName': displayName,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show typing
      _isAITyping = true;
      notifyListeners();

      // Get conversation history
      final historySnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

   final conversationHistory = historySnapshot.docs.map((doc) {
  final data = doc.data();
  final senderId = data['senderId'] ?? '';
  final content = data['content'] ?? '';
  return {
    'role': (senderId == 'premium_ai') ? 'assistant' : 'user',
    'content': content,
  };
}).toList().reversed.toList().cast<Map<String, String>>(); // ✅ ADD .cast<Map<String, String>>()

      // Get AI response
      final aiResponse = await PremiumAIService.sendMessage(
        content,
        conversationHistory: conversationHistory,
      );

      // Add AI message
      final aiMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(aiMessageId)
          .set({
        'id': aiMessageId,
        'senderId': 'premium_ai',
        'senderName': 'Health Guru',
        'content': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': aiResponse,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _isAITyping = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error: $e');
      _isAITyping = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel(); // ✅ Clean up subscription
    super.dispose();
  }
}
