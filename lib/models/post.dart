class Post {
  final int? id;
  final String title;
  final String content;
  final String createdAt;
  final String author;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      createdAt: (json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'createdAt': createdAt,
    };
  }
}