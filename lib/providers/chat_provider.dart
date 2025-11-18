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
  StreamSubscription? _conversationsSubscription; 
  String? _currentUserId; 

  List<Conversation> get conversations => _conversations;
  bool get isAITyping => _isAITyping;

  ChatProvider() {
    _initializeChat();
  }

  /// ✅ Initialize chat and listen to auth changes
  Future<void> _initializeChat() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        _clearData();
      } else if (_currentUserId != user.uid) {
        _currentUserId = user.uid;
        _reloadData();
      }
    });

    final user = _auth.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      await ensureAIConversationExists();
      _loadConversations();
    }
  }

  void _clearData() {
    _conversationsSubscription?.cancel();
    _conversationsSubscription = null;
    _conversations.clear();
    _isAITyping = false;
    _currentUserId = null;
    notifyListeners();
  }

  Future<void> _reloadData() async {
    _clearData();
    await ensureAIConversationExists();
    _loadConversations();
  }

  void _loadConversations() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _conversationsSubscription?.cancel();

    _conversationsSubscription = _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      _conversations = snapshot.docs
          .map((doc) {
            try {
              return Conversation.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .where((conv) => conv != null)
          .cast<Conversation>()
          .toList();

      _conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    });
  }

  Future<void> ensureAIConversationExists() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final aiConvId = 'ai_$userId';
      final aiConvRef = _firestore.collection('conversations').doc(aiConvId);
      final aiConvDoc = await aiConvRef.get();

      if (!aiConvDoc.exists) {
        final now = DateTime.now();
        await aiConvRef.set({
          'id': aiConvId,
          'name': 'Dr. Wellness',
          'avatar': '👨‍⚕️',
          'lastMessage': 'Hi! I\'m Dr. Wellness, your AI health coach.',
          'timestamp': Timestamp.fromDate(now),
          'isAI': true,
          'participants': [userId],
        });

        await Future.delayed(const Duration(milliseconds: 500));
        
        final welcomeMessageId = now.millisecondsSinceEpoch.toString();
        await _firestore
            .collection('conversations')
            .doc(aiConvId)
            .collection('messages')
            .doc(welcomeMessageId)
            .set({
            'id': welcomeMessageId,
            'senderId': 'ai',
            'senderName': 'Dr. Wellness',
            'content': 'Hi! I\'m Dr. Wellness. How can I help you?',
            'timestamp': Timestamp.fromDate(now),
          });
      }
    } catch (e) {
      debugPrint('❌ Error in ensureAIConversationExists: $e');
    }
  }

  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    final currentUserId = _auth.currentUser?.uid ?? '';

    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return ChatMessage.fromJson(doc.data(), currentUserId);
            } catch (e) {
              return null;
            }
          })
          .where((msg) => msg != null)
          .cast<ChatMessage>()
          .toList();
    });
  }

  Future<void> sendMessage(String conversationId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final firstName = userData?['firstname'] ?? 'User';
      
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .set({
        'id': messageId,
        'senderId': user.uid,
        'senderName': firstName,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
    }
  }

  Future<void> sendAIMessage(String conversationId, String content, HealthData? healthData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // 1. Add User Message
      await sendMessage(conversationId, content);

      _isAITyping = true;
      notifyListeners();

      // 2. Get AI Response
      final aiResponse = await _aiService.sendMessage(
        conversationId: conversationId,
        message: content,
        userHealthData: healthData,
      );

      // 3. Add AI Message
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

  Future<String?> createConversation(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

      final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
      if (!otherUserDoc.exists) return null;

      // Check existing
      final existingConv = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: currentUserId)
          .get();

      for (var doc in existingConv.docs) {
        // Simple check for non-AI conversation with these 2 participants
        final data = doc.data();
        final participants = List<String>.from(data['participants']);
        if (participants.contains(otherUserId) && data['isAI'] == false) {
          return doc.id;
        }
      }

      // Create New
      final otherData = otherUserDoc.data();
      final name = otherData?['firstname'] ?? 'User';
      
      final convId = _firestore.collection('conversations').doc().id;
      await _firestore.collection('conversations').doc(convId).set({
        'id': convId,
        'name': name,
        'avatar': '👤',
        'lastMessage': 'Start chatting',
        'timestamp': FieldValue.serverTimestamp(),
        'isAI': false,
        'participants': [currentUserId, otherUserId],
      });

      return convId;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getOrCreatePremiumAIConversation() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      final premiumAIConvId = 'premium_ai_$userId';
      final premiumAIConvRef = _firestore.collection('conversations').doc(premiumAIConvId);
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
        
        // Welcome Msg
        final id = now.millisecondsSinceEpoch.toString();
        await _firestore
            .collection('conversations')
            .doc(premiumAIConvId)
            .collection('messages')
            .doc(id)
            .set({
          'id': id,
          'senderId': 'premium_ai',
          'senderName': 'Health Guru',
          'content': 'Hello! I\'m Health Guru. How can I help?',
          'timestamp': Timestamp.fromDate(now),
        });
      }
      return premiumAIConvId;
    } catch (e) {
      return null;
    }
  }

  // 🔴 THIS IS THE FUNCTION I FIXED
  Future<void> sendPremiumAIMessage(String conversationId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final firstName = userDoc.data()?['firstname'] ?? 'User';

      // 1. Save User Message
      final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(userMessageId)
          .set({
        'id': userMessageId,
        'senderId': user.uid,
        'senderName': firstName,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _isAITyping = true;
      notifyListeners();

      // 2. Get History (FIXED FOR WEB CRASH)
      final historySnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      // 👇👇👇 THE FIX IS HERE 👇👇👇
      // We convert to Map<String, dynamic> to satisfy the browser
      final List<Map<String, dynamic>> conversationHistory = historySnapshot.docs.map((doc) {
        final data = doc.data();
        final senderId = data['senderId'] ?? '';
        final msgContent = data['content'] ?? '';
        
        return {
          // If sender is premium_ai, role is 'model', else 'user'
          'role': (senderId == 'premium_ai') ? 'model' : 'user',
          'content': msgContent,
        };
      }).toList().reversed.toList().cast<Map<String, dynamic>>(); 

      // 3. Send to API
      final aiResponse = await PremiumAIService.sendMessage(
        content,
        conversationHistory: conversationHistory,
      );

      // 4. Save AI Response
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
    _conversationsSubscription?.cancel();
    super.dispose();
  }
}