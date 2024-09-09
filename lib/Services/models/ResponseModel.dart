class ResponseModel {
  final double harvestCost;
  final double prunningCost;
  final double pruningWithIntercropCost;
  final double harvestingWithIntercropCost;
  final double servicePercentage;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;
  final List<dynamic> validationErrors;
  final dynamic exception;

  ResponseModel({
    required this.harvestCost,
    required this.prunningCost,
    required this.pruningWithIntercropCost,
    required this.harvestingWithIntercropCost,
    required this.servicePercentage,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
    required this.validationErrors,
    this.exception,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      harvestCost: json['result']['harvestCost'],
      prunningCost: json['result']['prunningCost'],
      pruningWithIntercropCost: json['result']['pruningWithIntercropCost'],
      harvestingWithIntercropCost: json['result']['harvestingWithIntercropCost'],
      servicePercentage: json['result']['servicePercentage'],
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      endUserMessage: json['endUserMessage'],
      validationErrors: List<dynamic>.from(json['validationErrors']),
      exception: json['exception'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': {
        'harvestCost': harvestCost,
        'prunningCost': prunningCost,
        'pruningWithIntercropCost': pruningWithIntercropCost,
        'harvestingWithIntercropCost': harvestingWithIntercropCost,
        'servicePercentage': servicePercentage,
      },
      'isSuccess': isSuccess,
      'affectedRecords': affectedRecords,
      'endUserMessage': endUserMessage,
      'validationErrors': validationErrors,
      'exception': exception,
    };
  }
}
