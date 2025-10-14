import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../services/ai_service.dart';
import '../models/health_data.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AIService _aiService = AIService();
  
  final List<Conversation> _conversations = [
    Conversation(
      id: '1',
      name: 'Liam',
      avatar: '👤',
      lastMessage: 'See you at the gym tomorrow!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Conversation(
      id: '2',
      name: 'Nathan',
      avatar: '👤',
      lastMessage: 'Thanks for the recipe!',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Conversation(
      id: '3',
      name: 'Dr. Wellness',
      avatar: '👨‍⚕️',
      lastMessage: 'Keep up the great work!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isAI: true,
    ),
  ];

  final Map<String, List<ChatMessage>> _messages = {
    '1': [
      ChatMessage(
        id: '1',
        sender: 'Liam',
        content: 'Hey! How was your workout today?',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isMe: false,
      ),
      ChatMessage(
        id: '2',
        sender: 'You',
        content: 'It was great! Did 30 minutes of cardio.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        isMe: true,
      ),
      ChatMessage(
        id: '3',
        sender: 'Liam',
        content: 'Awesome! See you at the gym tomorrow!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: false,
      ),
    ],
    '3': [
      ChatMessage(
        id: '1',
        sender: 'Dr. Wellness',
        content: 'Hi! I\'m Dr. Wellness, your AI health coach. How can I help you today?',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isMe: false,
      ),
    ],
  };

  bool _isAITyping = false;

  List<Conversation> get conversations => _conversations;
  bool get isAITyping => _isAITyping;
  
  List<ChatMessage> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  /// Send a regular message (non-AI)
  void sendMessage(String conversationId, String content) {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'You',
      content: content,
      timestamp: DateTime.now(),
      isMe: true,
    );
    
    _messages[conversationId]?.add(newMessage);
    
    // Update conversation last message
    final conv = _conversations.firstWhere((c) => c.id == conversationId);
    conv.lastMessage = content;
    conv.timestamp = DateTime.now();
    
    notifyListeners();
  }

  /// Send a message to AI chatbot and get response
  Future<void> sendAIMessage(
    String conversationId,
    String content,
    HealthData? healthData,
  ) async {
    // Add user message immediately
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'You',
      content: content,
      timestamp: DateTime.now(),
      isMe: true,
    );
    
    _messages[conversationId]?.add(userMessage);
    
    // Update conversation
    final conv = _conversations.firstWhere((c) => c.id == conversationId);
    conv.lastMessage = content;
    conv.timestamp = DateTime.now();
    
    // Show typing indicator
    _isAITyping = true;
    notifyListeners();

    try {
      // Call AI service
      final aiResponse = await _aiService.sendMessage(
        conversationId: conversationId,
        message: content,
        userHealthData: healthData,
      );

      // Add AI response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'Dr. Wellness',
        content: aiResponse,
        timestamp: DateTime.now(),
        isMe: false,
      );
      
      _messages[conversationId]?.add(aiMessage);
      
      // Update conversation
      conv.lastMessage = aiResponse;
      conv.timestamp = DateTime.now();
      
    } catch (e) {
      print('Error sending AI message: $e');
      
      // Add error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'Dr. Wellness',
        content: 'Sorry, I\'m having trouble responding right now. Please try again.',
        timestamp: DateTime.now(),
        isMe: false,
      );
      
      _messages[conversationId]?.add(errorMessage);
    } finally {
      _isAITyping = false;
      notifyListeners();
    }
  }

  /// Load messages from Firestore (for persistence)
  Future<void> loadMessagesFromFirestore(String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage.fromJson(data);
      }).toList();

      _messages[conversationId] = messages;
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }
}
