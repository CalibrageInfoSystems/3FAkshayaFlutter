class LearningModel {
  final int? id;
  final String? name;
  final String? teluguName;
  final String? hindiName;
  final String? kannadaName;
  final String? remarks;
  final bool? isActive;
  final int? createdByUserId;
  final String? createdBy;
  final DateTime? createdDate;
  final int? updatedByUserId;
  final String? updatedBy;
  final DateTime? updatedDate;

  LearningModel({
    this.id,
    this.name,
    this.teluguName,
    this.hindiName,
    this.kannadaName,
    this.remarks,
    this.isActive,
    this.createdByUserId,
    this.createdBy,
    this.createdDate,
    this.updatedByUserId,
    this.updatedBy,
    this.updatedDate,
  });

  factory LearningModel.fromJson(Map<String, dynamic> json) => LearningModel(
        id: json["id"],
        name: json["name"],
        teluguName: json["teluguName"],
        hindiName: json["hindiName"],
        kannadaName: json["kannadaName"],
        remarks: json["remarks"],
        isActive: json["isActive"],
        createdByUserId: json["createdByUserId"],
        createdBy: json["createdBy"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]),
        updatedByUserId: json["updatedByUserId"],
        updatedBy: json["updatedBy"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "teluguName": teluguName,
        "hindiName": hindiName,
        "kannadaName": kannadaName,
        "remarks": remarks,
        "isActive": isActive,
        "createdByUserId": createdByUserId,
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedByUserId": updatedByUserId,
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
      };
}
