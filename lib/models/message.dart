import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  String id;
  String senderId;
  String senderName;
  String content;
  DateTime timestamp;
  bool isMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, String currentUserId) {
    final senderId = json['senderId'] ?? '';
    
    return ChatMessage(
      id: json['id'] ?? '',
      senderId: senderId,
      senderName: json['senderName'] ?? '',
      content: json['content'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isMe: senderId == currentUserId,
    );
  }
}

class Conversation {
  String id;
  String name;
  String avatar;
  String lastMessage;
  DateTime timestamp;
  bool isAI;
  bool isPremiumAI; // ✅ ADDED
  List<String> participants;

  Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    this.isAI = false,
    this.isPremiumAI = false, // ✅ ADDED
    this.participants = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'lastMessage': lastMessage,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAI': isAI,
      'isPremiumAI': isPremiumAI, // ✅ ADDED
      'participants': participants,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '👤',
      lastMessage: json['lastMessage'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAI: json['isAI'] ?? false,
      isPremiumAI: json['isPremiumAI'] ?? false, // ✅ ADDED
      participants: List<String>.from(json['participants'] ?? []),
    );
  }
}