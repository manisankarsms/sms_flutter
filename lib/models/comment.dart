class Comment {
  final String comment;
  final String commentedBy;
  final String commentedAt;

  Comment({
    required this.comment,
    required this.commentedBy,
    required this.commentedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      comment: json['comment'],
      commentedBy: json['commentedBy'],
      commentedAt: json['commentedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'commentedBy': commentedBy,
      'commentedAt': commentedAt,
    };
  }
}
