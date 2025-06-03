import 'comment.dart';

class Complaint {
  final String id;
  final String author;
  final String title;
  final String content;
  final String category;
  final String status;
  final bool isAnonymous;
  final String createdAt;
  final List<Comment> comments; // Updated to store `Comment` objects

  Complaint({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.category,
    this.status = "Open",
    this.isAnonymous = false,
    required this.createdAt,
    this.comments = const [],
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      author: json['author'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      status: json['status'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: json['createdAt'],
      comments: (json['comments'] as List<dynamic>?)
          ?.map((commentJson) => Comment.fromJson(commentJson))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'content': content,
      'category': category,
      'status': status,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  Complaint copyWith({String? status, List<Comment>? comments}) {
    return Complaint(
      id: id,
      author: author,
      title: title,
      content: content,
      category: category,
      status: status ?? this.status,
      isAnonymous: isAnonymous,
      createdAt: createdAt,
      comments: comments ?? this.comments,
    );
  }
}
