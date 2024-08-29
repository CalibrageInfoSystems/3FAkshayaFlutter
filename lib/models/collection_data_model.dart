import 'dart:convert';

CollectionData collectionDataFromJson(String str) =>
    CollectionData.fromJson(json.decode(str));

String collectionDataToJson(CollectionData data) => json.encode(data.toJson());

class CollectionData {
  final String? uColnid;
  final String? uFarcode;
  final String? uPlotid;
  final String? uApaystat;
  final String? canceled;
  final String? docStatus;
  final String? docDate;
  final String? whsCode;
  final String? whsName;
  final double? quantity;
  final int? docEntry;
  final String? updateDate;
  final String? farmerName;
  final String? vehicalNumber;
  final String? driverName;

  CollectionData({
    this.uColnid,
    this.uFarcode,
    this.uPlotid,
    this.uApaystat,
    this.canceled,
    this.docStatus,
    this.docDate,
    this.whsCode,
    this.whsName,
    this.quantity,
    this.docEntry,
    this.updateDate,
    this.farmerName,
    this.vehicalNumber,
    this.driverName,
  });

  factory CollectionData.fromJson(Map<String, dynamic> json) => CollectionData(
        uColnid: json["u_colnid"],
        uFarcode: json["u_farcode"],
        uPlotid: json["u_plotid"],
        uApaystat: json["u_apaystat"],
        canceled: json["canceled"],
        docStatus: json["docStatus"],
        docDate: json["docDate"],
        whsCode: json["whsCode"],
        whsName: json["whsName"],
        quantity: json["quantity"]?.toDouble(),
        docEntry: json["docEntry"],
        updateDate: json["updateDate"],
        farmerName: json["farmerName"],
        vehicalNumber: json["vehicalNumber"],
        driverName: json["driverName"],
      );

  Map<String, dynamic> toJson() => {
        "u_colnid": uColnid,
        "u_farcode": uFarcode,
        "u_plotid": uPlotid,
        "u_apaystat": uApaystat,
        "canceled": canceled,
        "docStatus": docStatus,
        "docDate": docDate,
        "whsCode": whsCode,
        "whsName": whsName,
        "quantity": quantity,
        "docEntry": docEntry,
        "updateDate": updateDate,
        "farmerName": farmerName,
        "vehicalNumber": vehicalNumber,
        "driverName": driverName,
      };
}
