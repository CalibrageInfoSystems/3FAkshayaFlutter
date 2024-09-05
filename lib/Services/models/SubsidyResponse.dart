class SubsidyResponse {
  final Result result;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;

  SubsidyResponse({
    required this.result,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
  });

  factory SubsidyResponse.fromJson(Map<String, dynamic> json) {
    return SubsidyResponse(
      result: Result.fromJson(json['result']),
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      endUserMessage: json['endUserMessage'],
    );
  }
}

class Result {
  final double totalSubsidyAmount;
  final double usedSubsidyAmount;
  final double remainingAmount;
  final double expectedBenchmark;
  final double currentNetWeight;
  final double previousNetWeight;

  Result({
    required this.totalSubsidyAmount,
    required this.usedSubsidyAmount,
    required this.remainingAmount,
    required this.expectedBenchmark,
    required this.currentNetWeight,
    required this.previousNetWeight,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      totalSubsidyAmount: json['totalSubsidyAmount'],
      usedSubsidyAmount: json['usedSubsidyAmount'],
      remainingAmount: json['remainingAmount'],
      expectedBenchmark: json['expectedBenchmark'],
      currentNetWeight: json['currentNetWeight'],
      previousNetWeight: json['previousNetWeight'],
    );
  }
}
