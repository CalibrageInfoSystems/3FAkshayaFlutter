class FertilizerRecommendation {
  final String fertilizer;
  final String uom;
  final int quantity;
  final String remarks;

  FertilizerRecommendation({
    required this.fertilizer,
    required this.uom,
    required this.quantity,
    required this.remarks,
  });

  factory FertilizerRecommendation.fromJson(Map<String, dynamic> json) {
    return FertilizerRecommendation(
      fertilizer: json['fertilizer'] ?? '',
      uom: json['uoM'] ?? '',
      // Handling potential parsing issues
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity'].toString()) ?? 0,
      remarks: json['remarks'] ?? '',
    );
  }
}

