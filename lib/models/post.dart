class Post {
  String id;
  String author;
  String avatar;
  String content;
  String time;
  int likes;
  int comments;
  bool isLiked;

  Post({
    required this.id,
    required this.author,
    required this.avatar,
    required this.content,
    required this.time,
    required this.likes,
    required this.comments,
    this.isLiked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'avatar': avatar,
      'content': content,
      'time': time,
      'likes': likes,
      'comments': comments,
      'isLiked': isLiked,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      author: json['author'] ?? '',
      avatar: json['avatar'] ?? '',
      content: json['content'] ?? '',
      time: json['time'] ?? '',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }
}
