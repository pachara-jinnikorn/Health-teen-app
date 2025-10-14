class ChatMessage {
  String id;
  String sender;
  String content;
  DateTime timestamp;
  bool isMe;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isMe': isMe,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      sender: json['sender'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] is String 
          ? DateTime.parse(json['timestamp'])
          : (json['timestamp'] as dynamic).toDate(),
      isMe: json['isMe'] ?? false,
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

  Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.timestamp,
    this.isAI = false,
  });
}
