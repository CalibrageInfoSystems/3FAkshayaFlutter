class FarmerResponseModel {
  String? result;
  bool? isSuccess;
  int? affectedRecords;
  String? endUserMessage;
  List<dynamic>? validationErrors;
  dynamic exception;

  FarmerResponseModel({
    this.result,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  // From JSON method
  factory FarmerResponseModel.fromJson(Map<String, dynamic> json) {
    return FarmerResponseModel(
      result: json['result'],
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      endUserMessage: json['endUserMessage'],
      validationErrors: json['validationErrors'] != null
          ? List<dynamic>.from(json['validationErrors'])
          : null,
      exception: json['exception'],
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'isSuccess': isSuccess,
      'affectedRecords': affectedRecords,
      'endUserMessage': endUserMessage,
      'validationErrors': validationErrors,
      'exception': exception,
    };
  }
}
