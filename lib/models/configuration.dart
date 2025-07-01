class Configuration {
  final int id;
  final String schoolName;
  final String address;
  final String? logoUrl;
  final String? email;
  final String? phoneNumber1;
  final String? phoneNumber2;
  final String? phoneNumber3;
  final String? phoneNumber4;
  final String? phoneNumber5;
  final String? website;

  Configuration({
    this.id = 1,
    required this.schoolName,
    required this.address,
    this.logoUrl,
    this.email,
    this.phoneNumber1,
    this.phoneNumber2,
    this.phoneNumber3,
    this.phoneNumber4,
    this.phoneNumber5,
    this.website,
  });

  factory Configuration.fromJson(Map<String, dynamic> json) {
    return Configuration(
      id: json['id'] ?? 1,
      schoolName: json['schoolName'] ?? '',
      address: json['address'] ?? '',
      logoUrl: json['logoUrl'],
      email: json['email'],
      phoneNumber1: json['phoneNumber1'],
      phoneNumber2: json['phoneNumber2'],
      phoneNumber3: json['phoneNumber3'],
      phoneNumber4: json['phoneNumber4'],
      phoneNumber5: json['phoneNumber5'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolName': schoolName,
      'address': address,
      'logoUrl': logoUrl,
      'email': email,
      'phoneNumber1': phoneNumber1,
      'phoneNumber2': phoneNumber2,
      'phoneNumber3': phoneNumber3,
      'phoneNumber4': phoneNumber4,
      'phoneNumber5': phoneNumber5,
      'website': website,
    };
  }
}
