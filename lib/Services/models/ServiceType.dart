class ServiceType {
  int? typeCdId;
  int? classTypeId;
  String? desc;
  String? tableName;
  String? columnName;
  int? sortOrder;
  bool? isActive;
  int? createdByUserId;
  DateTime? createdDate;
  int? updatedByUserId;
  DateTime? updatedDate;

  ServiceType({
    this.typeCdId,
    this.classTypeId,
    this.desc,
    this.tableName,
    this.columnName,
    this.sortOrder,
    this.isActive,
    this.createdByUserId,
    this.createdDate,
    this.updatedByUserId,
    this.updatedDate,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      typeCdId: json['typeCdId'],
      classTypeId: json['classTypeId'],
      desc: json['desc'],
      tableName: json['tableName'],
      columnName: json['columnName'],
      sortOrder: json['sortOrder'],
      isActive: json['isActive'],
      createdByUserId: json['createdByUserId'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      updatedByUserId: json['updatedByUserId'],
      updatedDate: json['updatedDate'] != null
          ? DateTime.parse(json['updatedDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'typeCdId': typeCdId,
      'classTypeId': classTypeId,
      'desc': desc,
      'tableName': tableName,
      'columnName': columnName,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdByUserId': createdByUserId,
      'createdDate': createdDate?.toIso8601String(),
      'updatedByUserId': updatedByUserId,
      'updatedDate': updatedDate?.toIso8601String(),
    };
  }
}

class ApiResponse {
  List<ServiceType>? result;
  bool? isSuccess;
  int? affectedRecords;
  String? endUserMessage;
  List<dynamic>? validationErrors;
  dynamic exception;

  ApiResponse({
    this.result,
    this.isSuccess,
    this.affectedRecords,
    this.endUserMessage,
    this.validationErrors,
    this.exception,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => ServiceType.fromJson(e as Map<String, dynamic>))
          .toList(),
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      endUserMessage: json['endUserMessage'],
      validationErrors: json['validationErrors'],
      exception: json['exception'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result?.map((e) => e.toJson()).toList(),
      'isSuccess': isSuccess,
      'affectedRecords': affectedRecords,
      'endUserMessage': endUserMessage,
      'validationErrors': validationErrors,
      'exception': exception,
    };
  }
}
