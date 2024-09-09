class LabourRequest {
  final int typeCdId;
  final int classTypeId;
  final String desc;
  final String tableName;
  final String columnName;
  final int sortOrder;
  final bool isActive;
  final int createdByUserId;
  final DateTime createdDate;
  final int updatedByUserId;
  final DateTime updatedDate;

  LabourRequest({
    required this.typeCdId,
    required this.classTypeId,
    required this.desc,
    required this.tableName,
    required this.columnName,
    required this.sortOrder,
    required this.isActive,
    required this.createdByUserId,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedDate,
  });

  factory LabourRequest.fromJson(Map<String, dynamic> json) {
    return LabourRequest(
      typeCdId: json['typeCdId'],
      classTypeId: json['classTypeId'],
      desc: json['desc'],
      tableName: json['tableName'],
      columnName: json['columnName'],
      sortOrder: json['sortOrder'],
      isActive: json['isActive'],
      createdByUserId: json['createdByUserId'],
      createdDate: DateTime.parse(json['createdDate']),
      updatedByUserId: json['updatedByUserId'],
      updatedDate: DateTime.parse(json['updatedDate']),
    );
  }
}

class Api_Response {
  final List<LabourRequest> listResult;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;

  Api_Response({
    required this.listResult,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
  });

  factory Api_Response.fromJson(Map<String, dynamic> json) {
    var list = json['listResult'] as List;
    List<LabourRequest> requestList =
    list.map((i) => LabourRequest.fromJson(i)).toList();

    return Api_Response(
      listResult: requestList,
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      endUserMessage: json['endUserMessage'],
    );
  }
}
