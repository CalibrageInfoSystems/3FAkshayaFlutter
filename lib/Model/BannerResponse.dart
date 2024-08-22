class BannerResponse {
  final List<BannerDetails> listResult;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;
  final List<dynamic> validationErrors;
  final dynamic exception;

  BannerResponse({
    required this.listResult,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
    required this.validationErrors,
    this.exception,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      listResult: List<BannerDetails>.from(
        json['listResult'].map((x) => BannerDetails.fromJson(x)),
      ),
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      endUserMessage: json['endUserMessage'],
      validationErrors: List<dynamic>.from(json['validationErrors']),
      exception: json['exception'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listResult': listResult.map((x) => x.toJson()).toList(),
      'isSuccess': isSuccess,
      'affectedRecords': affectedRecords,
      'endUserMessage': endUserMessage,
      'validationErrors': validationErrors,
      'exception': exception,
    };
  }
}

class BannerDetails {
  final int id;
  final String imageName;
  final String description;
  final String stateCode;
  final bool isActive;

  BannerDetails({
    required this.id,
    required this.imageName,
    required this.description,
    required this.stateCode,
    required this.isActive,
  });

  factory BannerDetails.fromJson(Map<String, dynamic> json) {
    return BannerDetails(
      id: json['id'],
      imageName: json['imageName'],
      description: json['description'],
      stateCode: json['stateCode'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageName': imageName,
      'description': description,
      'stateCode': stateCode,
      'isActive': isActive,
    };
  }
}
