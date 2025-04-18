class Configuration {
  final int? id;
  final String schoolName;
  final String address;
  final String contactEmail;
  final String contactPhone;
  final String logoUrl;

  Configuration({
    this.id,
    required this.schoolName,
    required this.address,
    required this.contactEmail,
    required this.contactPhone,
    required this.logoUrl,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      id: json['id'],
      schoolName: json['schoolName'] ?? '',
      address: json['address'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolName': schoolName,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'logoUrl': logoUrl,
    };
  }
}
