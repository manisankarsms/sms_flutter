class IssuedBook {
  final String id;
  final String bookId;
  final String userId;
  final String issuedDate;
  final String dueDate;
  final bool isReturned;

  IssuedBook({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.issuedDate,
    required this.dueDate,
    required this.isReturned,
  });

  factory IssuedBook.fromJson(Map<String, dynamic> json) {
    return IssuedBook(
      id: json['id'],
      bookId: json['bookId'],
      userId: json['userId'],
      issuedDate: json['issuedDate'],
      dueDate: json['dueDate'],
      isReturned: json['isReturned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'issuedDate': issuedDate,
      'dueDate': dueDate,
      'isReturned': isReturned,
    };
  }
}
