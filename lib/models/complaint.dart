import 'comment.dart';

class Complaint {
  final String id;
  final String subject;
  final String description;
  final String category;
  final String status;
  final bool isAnonymous;
  final List<Comment> comments; // Updated to store `Comment` objects

  Complaint({
    required this.id,
    required this.subject,
    required this.description,
    required this.category,
    this.status = "Pending",
    this.isAnonymous = false,
    this.comments = const [],
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      subject: json['subject'],
      description: json['description'],
      category: json['category'],
      status: json['status'],
      isAnonymous: json['isAnonymous'] ?? false,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((commentJson) => Comment.fromJson(commentJson))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'description': description,
      'category': category,
      'status': status,
      'isAnonymous': isAnonymous,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  Complaint copyWith({String? status, List<Comment>? comments}) {
    return Complaint(
      id: id,
      subject: subject,
      description: description,
      category: category,
      status: status ?? this.status,
      isAnonymous: isAnonymous,
      comments: comments ?? this.comments,
    );
  }
}
