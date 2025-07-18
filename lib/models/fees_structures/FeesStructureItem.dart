class FeesStructureItem {
  final String name;
  final String amount;
  final bool isMandatory;

  FeesStructureItem({
    required this.name,
    required this.amount,
    this.isMandatory = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'isMandatory': isMandatory,
    };
  }
}