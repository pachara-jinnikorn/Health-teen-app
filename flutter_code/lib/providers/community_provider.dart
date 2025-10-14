import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';

class CommunityProvider extends ChangeNotifier {
  List<Post> _posts = [];
  
  List<Post> get posts => _posts;

  CommunityProvider() {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedPosts = prefs.getString('posts');
    
    if (savedPosts != null) {
      try {
        final List<dynamic> decoded = jsonDecode(savedPosts);
        _posts = decoded.map((p) => Post.fromJson(p)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading posts: $e');
        _initializeDefaultPosts();
      }
    } else {
      _initializeDefaultPosts();
    }
  }

  void _initializeDefaultPosts() {
    _posts = [
      Post(
        id: '1',
        author: 'Liam',
        avatar: '👤',
        content: 'Just finished a great workout! Feeling energized and ready to tackle the day. #fitness #healthylifestyle',
        time: '2h',
        likes: 23,
        comments: 5,
      ),
      Post(
        id: '2',
        author: 'Sophia',
        avatar: '👤',
        content: 'Made a delicious and nutritious smoothie this morning. Packed with fruits and veggies! #healthyfood #smoothierecipe',
        time: '4h',
        likes: 32,
        comments: 8,
      ),
      Post(
        id: '3',
        author: 'Nathan',
        avatar: '👤',
        content: 'Took some time for mindfulness and meditation today. Feeling calm and focused. #mentalhealth #mindfulness',
        time: '5h',
        likes: 15,
        comments: 2,
      ),
    ];
    _savePosts();
    notifyListeners();
  }

  Future<void> _savePosts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'posts',
      jsonEncode(_posts.map((p) => p.toJson()).toList()),
    );
  }

  void toggleLike(String postId) {
    final post = _posts.firstWhere((p) => p.id == postId);
    post.isLiked = !post.isLiked;
    post.likes += post.isLiked ? 1 : -1;
    notifyListeners();
    _savePosts();
  }

  void addPost(String content) {
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: 'You',
      avatar: '👤',
      content: content,
      time: 'Just now',
      likes: 0,
      comments: 0,
    );
    _posts.insert(0, newPost);
    notifyListeners();
    _savePosts();
  }
}
