import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post.dart';

class CommunityProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Post> _posts = [];
  final bool _isLoading = false;
  
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  CommunityProvider() {
    _loadPosts();
  }

  /// ✅ Load posts from Firestore in real-time
  void _loadPosts() {
    final currentUserId = _auth.currentUser?.uid ?? '';
    
    _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      _posts = snapshot.docs
          .map((doc) => Post.fromJson(doc.data(), currentUserId))
          .toList();
      notifyListeners();
    });
  }

  /// ✅ Add a new post to Firestore
  Future<void> addPost(String content) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final firstName = userData?['firstname'] ?? 'User';
      final lastName = userData?['lastname'] ?? '';
      final displayName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      final postId = _firestore.collection('posts').doc().id;
      
      final newPost = Post(
        id: postId,
        author: displayName,
        authorId: user.uid,
        avatar: '👤',
        content: content,
        timestamp: DateTime.now(),
        likes: 0,
        comments: 0,
        likedBy: [],
      );

      await _firestore.collection('posts').doc(postId).set(newPost.toJson());
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding post: $e');
      rethrow;
    }
  }

  /// ✅ Toggle like on a post
  Future<void> toggleLike(String postId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) return;

      final data = postDoc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final isLiked = likedBy.contains(userId);

      if (isLiked) {
        // Unlike
        likedBy.remove(userId);
        await postRef.update({
          'likedBy': likedBy,
          'likes': FieldValue.increment(-1),
        });
      } else {
        // Like
        likedBy.add(userId);
        await postRef.update({
          'likedBy': likedBy,
          'likes': FieldValue.increment(1),
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  /// ✅ Delete a post (only if user is the author)
  Future<void> deletePost(String postId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final postRef = _firestore.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) return;

      final authorId = postDoc.data()?['authorId'];
      if (authorId == userId) {
        await postRef.delete();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting post: $e');
    }
  }
}