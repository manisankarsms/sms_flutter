class Complaint {
  final String id;
  final String subject;
  final String description;
  final String category;
  final String status;
  final bool isAnonymous;

  Complaint({
    required this.id,
    required this.subject,
    required this.description,
    required this.category,
    this.status = "Pending",
    this.isAnonymous = false,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      subject: json['subject'],
      description: json['description'],
      category: json['category'],
      status: json['status'],
      isAnonymous: json['isAnonymous'] ?? false,
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
    };
  }

  Complaint copyWith({String? status}) {
    return Complaint(
      id: id,
      subject: subject,
      description: description,
      category: category,
      status: status ?? this.status,
      isAnonymous: isAnonymous,
    );
  }
}
