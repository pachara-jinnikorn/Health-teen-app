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
    _loadConversations();
    _createAIConversationIfNeeded();
  }

  /// ✅ Load conversations from Firestore
  void _loadConversations() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _conversations = snapshot.docs
          .map((doc) => Conversation.fromJson(doc.data()))
          .toList();
      notifyListeners();
    });
  }

  /// ✅ Create AI conversation if it doesn't exist
  Future<void> _createAIConversationIfNeeded() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final aiConvId = 'ai_$userId';
    final aiConvRef = _firestore.collection('conversations').doc(aiConvId);
    final aiConvDoc = await aiConvRef.get();

    if (!aiConvDoc.exists) {
      final aiConversation = Conversation(
        id: aiConvId,
        name: 'Dr. Wellness',
        avatar: '👨‍⚕️',
        lastMessage: 'Hi! I\'m Dr. Wellness, your AI health coach.',
        timestamp: DateTime.now(),
        isAI: true,
        participants: [userId],
      );

      await aiConvRef.set(aiConversation.toJson());

      // Add welcome message
      final welcomeMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: 'ai',
        senderName: 'Dr. Wellness',
        content: 'Hi! I\'m Dr. Wellness, your AI health coach. How can I help you today?',
        timestamp: DateTime.now(),
        isMe: false,
      );

      await _firestore
          .collection('conversations')
          .doc(aiConvId)
          .collection('messages')
          .doc(welcomeMessage.id)
          .set(welcomeMessage.toJson());
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
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data(), currentUserId))
            .toList());
  }

  /// ✅ Send a regular message (non-AI)
  Future<void> sendMessage(String conversationId, String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final firstName = userData?['firstname'] ?? 'User';
      final lastName = userData?['lastname'] ?? '';
      final displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final newMessage = ChatMessage(
        id: messageId,
        senderId: user.uid,
        senderName: displayName,
        content: content,
        timestamp: DateTime.now(),
        isMe: true,
      );

      // Add message to subcollection
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .set(newMessage.toJson());

      // Update conversation last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error sending message: $e');
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

      // Get user data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final firstName = userData?['firstname'] ?? 'User';
      final lastName = userData?['lastname'] ?? '';
      final displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      // Add user message
      final userMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      final userMessage = ChatMessage(
        id: userMessageId,
        senderId: user.uid,
        senderName: displayName,
        content: content,
        timestamp: DateTime.now(),
        isMe: true,
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(userMessageId)
          .set(userMessage.toJson());

      // Update conversation
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'timestamp': Timestamp.fromDate(DateTime.now()),
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
      final aiMessage = ChatMessage(
        id: aiMessageId,
        senderId: 'ai',
        senderName: 'Dr. Wellness',
        content: aiResponse,
        timestamp: DateTime.now(),
        isMe: false,
      );

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(aiMessageId)
          .set(aiMessage.toJson());

      // Update conversation
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': aiResponse,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });

      _isAITyping = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error sending AI message: $e');
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
          return doc.id; // Return existing conversation
        }
      }

      // Create new conversation
      final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
      final otherUserData = otherUserDoc.data();
      final firstName = otherUserData?['firstname'] ?? 'User';
      final lastName = otherUserData?['lastname'] ?? '';
      final displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      final convId = _firestore.collection('conversations').doc().id;
      final newConversation = Conversation(
        id: convId,
        name: displayName,
        avatar: '👤',
        lastMessage: 'Start a conversation',
        timestamp: DateTime.now(),
        isAI: false,
        participants: [currentUserId, otherUserId],
      );

      await _firestore
          .collection('conversations')
          .doc(convId)
          .set(newConversation.toJson());

      return convId;
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      return null;
    }
  }
}