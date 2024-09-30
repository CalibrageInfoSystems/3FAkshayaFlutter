
class ServiceResponse {
  final List<Service> listResult;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;
  final List<dynamic> validationErrors;
  final dynamic exception;

  ServiceResponse({
    required this.listResult,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
    required this.validationErrors,
    this.exception,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
      listResult: (json['listResult'] as List<dynamic>)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList(),
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      endUserMessage: json['endUserMessage'],
      validationErrors: json['validationErrors'] as List<dynamic>,
      exception: json['exception'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listResult': listResult.map((e) => e.toJson()).toList(),
      'isSuccess': isSuccess,
      'affectedRecords': affectedRecords,
      'endUserMessage': endUserMessage,
      'validationErrors': validationErrors,
      'exception': exception,
    };
  }
}

class Service {
  final int serviceTypeId;
  final String desc;
  final Map<String, double> costs;

  Service({
    required this.serviceTypeId,
    required this.desc,
    required this.costs,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    final costs = <String, double>{};
    for (var key in json.keys) {
      if (key.startsWith('c')) {
        costs[key] = (json[key] as num).toDouble();
      }
    }
    return Service(
      serviceTypeId: json['serviceTypeId'],
      desc: json['desc'],
      costs: costs,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'serviceTypeId': serviceTypeId,
      'desc': desc,
    };
    data.addAll(costs.map((key, value) => MapEntry(key, value)));
    return data;
  }
}
