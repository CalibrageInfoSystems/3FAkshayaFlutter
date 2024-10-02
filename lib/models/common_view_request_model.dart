// To parse this JSON data, do
//
//     final commonViewRequestModel = commonViewRequestModelFromJson(jsonString);

import 'dart:convert';

CommonViewRequestModel commonViewRequestModelFromJson(String str) =>
    CommonViewRequestModel.fromJson(json.decode(str));

String commonViewRequestModelToJson(CommonViewRequestModel data) =>
    json.encode(data.toJson());

class CommonViewRequestModel {
  final String? requestCode;
  final int? requestTypeId;
  final int? godownId;
  final String? goDownName;
  final int? pin;
  final double? subsidyAmount;
  final double? paubleAmount;
  final double? transportPayableAmount;
  final double? totalAmount;
  final double? totalCost;
  final String? farmerCode;
  final String? farmerName;
  final bool? isImmediatePayment;
  final String? reqCreatedDate;
  final String? status;
  final int? paymentModeTypeId;
  final String? paymentMode;
  final double? headerTotalCost;
  final int? statusTypeId;
  final String? fileName;
  final String? fileLocation;
  final String? fileExtension;
  final String? imageUrl;
  final double? usageAmount;
  final double? maxLimit;
  final String? gstn;
  final String? createdBy;
  final String? productInfo;
  final String? godownAddress;
  final String? contactNumber;
  final String? closedDate;
  final String? stateCode;
  final String? stateName;

  CommonViewRequestModel({
    this.requestCode,
    this.requestTypeId,
    this.godownId,
    this.goDownName,
    this.pin,
    this.subsidyAmount,
    this.paubleAmount,
    this.transportPayableAmount,
    this.totalAmount,
    this.totalCost,
    this.farmerCode,
    this.farmerName,
    this.isImmediatePayment,
    this.reqCreatedDate,
    this.status,
    this.paymentModeTypeId,
    this.paymentMode,
    this.headerTotalCost,
    this.statusTypeId,
    this.fileName,
    this.fileLocation,
    this.fileExtension,
    this.imageUrl,
    this.usageAmount,
    this.maxLimit,
    this.gstn,
    this.createdBy,
    this.productInfo,
    this.godownAddress,
    this.contactNumber,
    this.closedDate,
    this.stateCode,
    this.stateName,
  });

  factory CommonViewRequestModel.fromJson(Map<String, dynamic> json) =>
      CommonViewRequestModel(
        requestCode: json["requestCode"],
        requestTypeId: json["requestTypeId"],
        godownId: json["godownId"],
        goDownName: json["goDownName"],
        pin: json["pin"],
        subsidyAmount: json["subsidyAmount"]?.toDouble(),
        paubleAmount: json["paubleAmount"]?.toDouble(),
        transportPayableAmount: json["transportPayableAmount"]?.toDouble(),
        totalAmount: json["totalAmount"]?.toDouble(),
        totalCost: json["totalCost"]?.toDouble(),
        farmerCode: json["farmerCode"],
        farmerName: json["farmerName"],
        isImmediatePayment: json["isImmediatePayment"],
        reqCreatedDate: json["reqCreatedDate"],
        status: json["status"],
        paymentModeTypeId: json["paymentModeTypeId"],
        paymentMode: json["paymentMode"],
        headerTotalCost: json["headerTotalCost"]?.toDouble(),
        statusTypeId: json["statusTypeId"],
        fileName: json["fileName"],
        fileLocation: json["fileLocation"],
        fileExtension: json["fileExtension"],
        imageUrl: json["imageUrl"],
        usageAmount: json["usageAmount"]?.toDouble(),
        maxLimit: json["maxLimit"]?.toDouble(),
        gstn: json["gstn"],
        createdBy: json["createdBy"],
        productInfo: json["productInfo"],
        godownAddress: json["godownAddress"],
        contactNumber: json["contactNumber"],
        closedDate: json["closedDate"],
        stateCode: json["stateCode"],
        stateName: json["stateName"],
      );

  Map<String, dynamic> toJson() => {
        "requestCode": requestCode,
        "requestTypeId": requestTypeId,
        "godownId": godownId,
        "goDownName": goDownName,
        "pin": pin,
        "subsidyAmount": subsidyAmount,
        "paubleAmount": paubleAmount,
        "transportPayableAmount": transportPayableAmount,
        "totalAmount": totalAmount,
        "totalCost": totalCost,
        "farmerCode": farmerCode,
        "farmerName": farmerName,
        "isImmediatePayment": isImmediatePayment,
        "reqCreatedDate": reqCreatedDate,
        "status": status,
        "paymentModeTypeId": paymentModeTypeId,
        "paymentMode": paymentMode,
        "headerTotalCost": headerTotalCost,
        "statusTypeId": statusTypeId,
        "fileName": fileName,
        "fileLocation": fileLocation,
        "fileExtension": fileExtension,
        "imageUrl": imageUrl,
        "usageAmount": usageAmount,
        "maxLimit": maxLimit,
        "gstn": gstn,
        "createdBy": createdBy,
        "productInfo": productInfo,
        "godownAddress": godownAddress,
        "contactNumber": contactNumber,
        "closedDate": closedDate,
        "stateCode": stateCode,
        "stateName": stateName,
      };
}
