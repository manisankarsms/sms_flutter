class Post {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String author;
  final String? imageUrl;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    this.imageUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}