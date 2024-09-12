import 'dart:convert';

TypeIssue typeIssueFromJson(String str) => TypeIssue.fromJson(json.decode(str));

String typeIssueToJson(TypeIssue data) => json.encode(data.toJson());

class TypeIssue {
  final int? typeCdId;
  final int? classTypeId;
  final String? desc;
  final String? tableName;
  final String? columnName;
  final int? sortOrder;
  final bool? isActive;
  final int? createdByUserId;
  final String? createdDate;
  final int? updatedByUserId;
  final String? updatedDate;

  TypeIssue({
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

  factory TypeIssue.fromJson(Map<String, dynamic> json) => TypeIssue(
        typeCdId: json["typeCdId"],
        classTypeId: json["classTypeId"],
        desc: json["desc"],
        tableName: json["tableName"],
        columnName: json["columnName"],
        sortOrder: json["sortOrder"],
        isActive: json["isActive"],
        createdByUserId: json["createdByUserId"],
        createdDate: json["createdDate"],
        updatedByUserId: json["updatedByUserId"],
        updatedDate: json["updatedDate"],
      );

  Map<String, dynamic> toJson() => {
        "typeCdId": typeCdId,
        "classTypeId": classTypeId,
        "desc": desc,
        "tableName": tableName,
        "columnName": columnName,
        "sortOrder": sortOrder,
        "isActive": isActive,
        "createdByUserId": createdByUserId,
        "createdDate": createdDate,
        "updatedByUserId": updatedByUserId,
        "updatedDate": updatedDate,
      };
}
