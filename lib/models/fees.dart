class FeeBreakdown {
  final String feeType;
  final double amount;

  FeeBreakdown({required this.feeType, required this.amount});

  factory FeeBreakdown.fromJson(Map<String, dynamic> json) {
    return FeeBreakdown(
      feeType: json['feeType'],
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feeType': feeType,
      'amount': amount,
    };
  }

  // New method to create a copy with modified fields
  FeeBreakdown copyWith({String? feeType, double? amount}) {
    return FeeBreakdown(
      feeType: feeType ?? this.feeType,
      amount: amount ?? this.amount,
    );
  }
}

class ClassFees {
  final double totalFees;
  final List<FeeBreakdown> breakdown;

  ClassFees({required this.totalFees, required this.breakdown});

  factory ClassFees.fromJson(Map<String, dynamic> json) {
    return ClassFees(
      totalFees: json['totalFees'].toDouble(),
      breakdown: (json['breakdown'] as List)
          .map((item) => FeeBreakdown.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFees': totalFees,
      'breakdown': breakdown.map((e) => e.toJson()).toList(),
    };
  }

  // Method to calculate total fees dynamically
  double calculateTotalFees() {
    return breakdown.fold(0, (sum, item) => sum + item.amount);
  }
}

class AcademicYearFees {
  final Map<String, ClassFees> classFees;

  AcademicYearFees({required this.classFees});

  factory AcademicYearFees.fromJson(Map<String, dynamic> json) {
    return AcademicYearFees(
      classFees: json.map((key, value) => MapEntry(key, ClassFees.fromJson(value))),
    );
  }

  Map<String, dynamic> toJson() {
    return classFees.map((key, value) => MapEntry(key, value.toJson()));
  }
}
