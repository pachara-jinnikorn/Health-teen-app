import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../models/health_data.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService();
  
  List<Conversation> _conversations = [];
  bool _isAITyping = false;

  List<Conversation> get conversations => _conversations;
  bool get isAITyping => _isAITyping;

  ChatProvider() {
    _initializeChat();
  }

  /// ✅ Initialize chat by creating AI conversation first
  Future<void> _initializeChat() async {
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

    _firestore
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
      final aiConvRef = _firestore.collection('conversations').doc(aiConvId);
      final aiConvDoc = await aiConvRef.get();

      if (!aiConvDoc.exists) {
        debugPrint('✅ Creating AI conversation for user: $userId');
        
        final now = DateTime.now();
        
        // Create AI conversation document
        await aiConvRef.set({
          'id': aiConvId,
          'name': 'Dr. Wellness',
          'avatar': '👨‍⚕️',
          'lastMessage': 'Hi! I\'m Dr. Wellness, your AI health coach.',
          'timestamp': Timestamp.fromDate(now),
          'isAI': true,
          'participants': [userId],
        });

        debugPrint('✅ AI conversation document created');

        // Wait a moment for Firestore to process
        await Future.delayed(const Duration(milliseconds: 300));

        // Add welcome message
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
          'content': 'Hi! I\'m Dr. Wellness, your AI health coach. How can I help you today?',
          'timestamp': Timestamp.fromDate(now),
        });

        debugPrint('✅ Welcome message added');
      } else {
        debugPrint('✅ AI conversation already exists');
      }
    } catch (e) {
      debugPrint('❌ Error creating AI conversation: $e');
      // Try again after a delay
      await Future.delayed(const Duration(seconds: 2));
      await ensureAIConversationExists();
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
          debugPrint('📨 Got ${snapshot.docs.length} messages for conversation: $conversationId');
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
      final displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

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
      final displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

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

  /// ✅ Create a new conversation with another user
  Future<String?> createConversation(String otherUserId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) return null;

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
      final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
      final otherUserData = otherUserDoc.data();
      final firstName = otherUserData?['firstname'] ?? 'User';
      final lastName = otherUserData?['lastname'] ?? '';
      final displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

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
}