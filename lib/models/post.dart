import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String author;
  String authorId; // ✅ Add user ID
  String avatar;
  String content;
  DateTime timestamp; // ✅ Changed from 'time' string to DateTime
  int likes;
  int comments;
  bool isLiked;
  List<String> likedBy; // ✅ Track who liked the post

  Post({
    required this.id,
    required this.author,
    required this.authorId,
    required this.avatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    this.likedBy = const [],
  });

  // ✅ Convert to Firestore format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'authorId': authorId,
      'avatar': avatar,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
    };
  }

  // ✅ Create from Firestore document
  factory Post.fromJson(Map<String, dynamic> json, String currentUserId) {
    final likedBy = List<String>.from(json['likedBy'] ?? []);
    
    return Post(
      id: json['id'] ?? '',
      author: json['author'] ?? '',
      authorId: json['authorId'] ?? '',
      avatar: json['avatar'] ?? '👤',
      content: json['content'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isLiked: likedBy.contains(currentUserId),
      likedBy: likedBy,
    );
  }

  // ✅ Helper to get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}