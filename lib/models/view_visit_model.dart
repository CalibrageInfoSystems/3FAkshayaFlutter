class ViewVisitModel {
  final String? requestCode;
  final String? farmerName;
  final String? farmerCode;
  final String? plotCode;
  final String? stateName;
  final String? reqCreatedDate;
  final int? statusTypeId;
  final String? statusType;
  final String? cropMaintainceDate;
  final String? updatedDate;
  final String? issueType;
  final String? comments;
  final String? createdBy;
  final String? isHavingImage;
  final String? isHavingAudio;
  final String? plotVillage;
  final double? palmArea;

  ViewVisitModel({
    this.requestCode,
    this.farmerName,
    this.farmerCode,
    this.plotCode,
    this.stateName,
    this.reqCreatedDate,
    this.statusTypeId,
    this.statusType,
    this.cropMaintainceDate,
    this.updatedDate,
    this.issueType,
    this.comments,
    this.createdBy,
    this.isHavingImage,
    this.isHavingAudio,
    this.plotVillage,
    this.palmArea,
  });

  factory ViewVisitModel.fromJson(Map<String, dynamic> json) => ViewVisitModel(
        requestCode: json["requestCode"],
        farmerName: json["farmerName"],
        farmerCode: json["farmerCode"],
        plotCode: json["plotCode"],
        stateName: json["stateName"],
        reqCreatedDate: json["reqCreatedDate"],
        statusTypeId: json["statusTypeId"],
        statusType: json["statusType"],
        cropMaintainceDate: json["cropMaintainceDate"],
        updatedDate: json["updatedDate"],
        issueType: json["issueType"],
        comments: json["comments"],
        createdBy: json["createdBy"],
        isHavingImage: json["isHavingImage"],
        isHavingAudio: json["isHavingAudio"],
        plotVillage: json["plotVillage"],
        palmArea: json["palmArea"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "requestCode": requestCode,
        "farmerName": farmerName,
        "farmerCode": farmerCode,
        "plotCode": plotCode,
        "stateName": stateName,
        "reqCreatedDate": reqCreatedDate,
        "statusTypeId": statusTypeId,
        "statusType": statusType,
        "cropMaintainceDate": cropMaintainceDate,
        "updatedDate": updatedDate,
        "issueType": issueType,
        "comments": comments,
        "createdBy": createdBy,
        "isHavingImage": isHavingImage,
        "isHavingAudio": isHavingAudio,
        "plotVillage": plotVillage,
        "palmArea": palmArea,
      };
}
