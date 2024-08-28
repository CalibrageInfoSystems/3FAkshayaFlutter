import 'dart:convert';

PlotDetailsModel plotDetailsModelFromJson(String str) =>
    PlotDetailsModel.fromJson(json.decode(str));

String plotDetailsModelToJson(PlotDetailsModel data) =>
    json.encode(data.toJson());

class PlotDetailsModel {
  final String? plotcode;
  final String? farmerCode;
  final double? palmArea;
  final double? plotArea;
  final double? plotAreainAcres;
  final double? palmAreainAcres;
  final String? dateOfPlanting;
  final String? landMark;
  final int? villageId;
  final String? villageCode;
  final String? villageName;
  final int? mandalId;
  final String? mandalCode;
  final String? mandalName;
  final int? districtId;
  final String? districtCoe;
  final String? districtName;
  final int? stateId;
  final String? stateCode;
  final String? stateName;
  final int? statusTypeId;
  final String? statusType;
  final int? age;
  final int? clusterId;
  final String? clusterName;
  final String? surveyNumber;
  final String? farmerName;
  final String? contactNumber;
  final dynamic mobileNumber;
  final dynamic interCrops;

  PlotDetailsModel({
    this.plotcode,
    this.farmerCode,
    this.palmArea,
    this.plotArea,
    this.plotAreainAcres,
    this.palmAreainAcres,
    this.dateOfPlanting,
    this.landMark,
    this.villageId,
    this.villageCode,
    this.villageName,
    this.mandalId,
    this.mandalCode,
    this.mandalName,
    this.districtId,
    this.districtCoe,
    this.districtName,
    this.stateId,
    this.stateCode,
    this.stateName,
    this.statusTypeId,
    this.statusType,
    this.age,
    this.clusterId,
    this.clusterName,
    this.surveyNumber,
    this.farmerName,
    this.contactNumber,
    this.mobileNumber,
    this.interCrops,
  });

  factory PlotDetailsModel.fromJson(Map<String, dynamic> json) =>
      PlotDetailsModel(
        plotcode: json["plotcode"],
        farmerCode: json["farmerCode"],
        palmArea: json["palmArea"]?.toDouble(),
        plotArea: json["plotArea"]?.toDouble(),
        plotAreainAcres: json["plotAreainAcres"]?.toDouble(),
        palmAreainAcres: json["palmAreainAcres"]?.toDouble(),
        dateOfPlanting: json["dateOfPlanting"],
        landMark: json["landMark"],
        villageId: json["villageId"],
        villageCode: json["villageCode"],
        villageName: json["villageName"],
        mandalId: json["mandalId"],
        mandalCode: json["mandalCode"],
        mandalName: json["mandalName"],
        districtId: json["districtId"],
        districtCoe: json["districtCoe"],
        districtName: json["districtName"],
        stateId: json["stateId"],
        stateCode: json["stateCode"],
        stateName: json["stateName"],
        statusTypeId: json["statusTypeId"],
        statusType: json["statusType"],
        age: json["age"],
        clusterId: json["clusterId"],
        clusterName: json["clusterName"],
        surveyNumber: json["surveyNumber"],
        farmerName: json["farmerName"],
        contactNumber: json["contactNumber"],
        mobileNumber: json["mobileNumber"],
        interCrops: json["interCrops"],
      );

  Map<String, dynamic> toJson() => {
        "plotcode": plotcode,
        "farmerCode": farmerCode,
        "palmArea": palmArea,
        "plotArea": plotArea,
        "plotAreainAcres": plotAreainAcres,
        "palmAreainAcres": palmAreainAcres,
        "dateOfPlanting": dateOfPlanting,
        "landMark": landMark,
        "villageId": villageId,
        "villageCode": villageCode,
        "villageName": villageName,
        "mandalId": mandalId,
        "mandalCode": mandalCode,
        "mandalName": mandalName,
        "districtId": districtId,
        "districtCoe": districtCoe,
        "districtName": districtName,
        "stateId": stateId,
        "stateCode": stateCode,
        "stateName": stateName,
        "statusTypeId": statusTypeId,
        "statusType": statusType,
        "age": age,
        "clusterId": clusterId,
        "clusterName": clusterName,
        "surveyNumber": surveyNumber,
        "farmerName": farmerName,
        "contactNumber": contactNumber,
        "mobileNumber": mobileNumber,
        "interCrops": interCrops,
      };
}
