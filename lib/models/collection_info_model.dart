// To parse this JSON data, do
//
//     final collectionInfo = collectionInfoFromJson(jsonString);

import 'dart:convert';

CollectionInfo collectionInfoFromJson(String str) =>
    CollectionInfo.fromJson(json.decode(str));

String collectionInfoToJson(CollectionInfo data) => json.encode(data.toJson());

class CollectionInfo {
  final String? code;
  final String? collectionCenterCode;
  final String? collectionCenter;
  final String? vehicleNumber;
  final String? driverName;
  final double? grossWeight;
  final double? tareWeight;
  final double? netWeight;
  final String? receiptGeneratedDate;
  final String? receiptImg;
  final String? operatorName;
  final String? comments;
  final int? totalBunches;
  final int? acceptedBunches;
  final int? rejectedBunches;
  final String? graderName;
  final String? receiptCode;

  CollectionInfo({
    this.code,
    this.collectionCenterCode,
    this.collectionCenter,
    this.vehicleNumber,
    this.driverName,
    this.grossWeight,
    this.tareWeight,
    this.netWeight,
    this.receiptGeneratedDate,
    this.receiptImg,
    this.operatorName,
    this.comments,
    this.totalBunches,
    this.acceptedBunches,
    this.rejectedBunches,
    this.graderName,
    this.receiptCode,
  });

  factory CollectionInfo.fromJson(Map<String, dynamic> json) => CollectionInfo(
        code: json["code"],
        collectionCenterCode: json["collectionCenterCode"],
        collectionCenter: json["collectionCenter"],
        vehicleNumber: json["vehicleNumber"],
        driverName: json["driverName"],
        grossWeight: json["grossWeight"]?.toDouble(),
        tareWeight: json["tareWeight"]?.toDouble(),
        netWeight: json["netWeight"]?.toDouble(),
        receiptGeneratedDate: json["receiptGeneratedDate"],
        receiptImg: json["receiptImg"],
        operatorName: json["operatorName"],
        comments: json["comments"],
        totalBunches: json["totalBunches"],
        acceptedBunches: json["acceptedBunches"],
        rejectedBunches: json["rejectedBunches"],
        graderName: json["graderName"],
        receiptCode: json["receiptCode"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "collectionCenterCode": collectionCenterCode,
        "collectionCenter": collectionCenter,
        "vehicleNumber": vehicleNumber,
        "driverName": driverName,
        "grossWeight": grossWeight,
        "tareWeight": tareWeight,
        "netWeight": netWeight,
        "receiptGeneratedDate": receiptGeneratedDate,
        "receiptImg": receiptImg,
        "operatorName": operatorName,
        "comments": comments,
        "totalBunches": totalBunches,
        "acceptedBunches": acceptedBunches,
        "rejectedBunches": rejectedBunches,
        "graderName": graderName,
        "receiptCode": receiptCode,
      };
}
