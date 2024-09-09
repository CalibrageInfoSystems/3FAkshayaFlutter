import 'dart:convert';

UnpaidCollection unpaidCollectionFromJson(String str) =>
    UnpaidCollection.fromJson(json.decode(str));

String unpaidCollectionToJson(UnpaidCollection data) =>
    json.encode(data.toJson());

class UnpaidCollection {
  final String? uColnid;
  final String? uFarcode;
  final String? uPlotid;
  final String? docStatus;
  final String? docDate;
  final String? whsCode;
  final String? whsName;
  final double? quantity;
  final dynamic uApaystat;
  final String? canceled;
  final String? stateCode;
  final String? stateName;
  final int? districtId;
  final String? districtName;
  final bool? isCollectionBlocked;

  UnpaidCollection({
    this.uColnid,
    this.uFarcode,
    this.uPlotid,
    this.docStatus,
    this.docDate,
    this.whsCode,
    this.whsName,
    this.quantity,
    this.uApaystat,
    this.canceled,
    this.stateCode,
    this.stateName,
    this.districtId,
    this.districtName,
    this.isCollectionBlocked,
  });

  factory UnpaidCollection.fromJson(Map<String, dynamic> json) =>
      UnpaidCollection(
        uColnid: json["u_colnid"],
        uFarcode: json["u_farcode"],
        uPlotid: json["u_plotid"],
        docStatus: json["docStatus"],
        docDate: json["docDate"],
        whsCode: json["whsCode"],
        whsName: json["whsName"],
        quantity: json["quantity"]?.toDouble(),
        uApaystat: json["u_apaystat"],
        canceled: json["canceled"],
        stateCode: json["stateCode"],
        stateName: json["stateName"],
        districtId: json["districtId"],
        districtName: json["districtName"],
        isCollectionBlocked: json["isCollectionBlocked"],
      );

  Map<String, dynamic> toJson() => {
        "u_colnid": uColnid,
        "u_farcode": uFarcode,
        "u_plotid": uPlotid,
        "docStatus": docStatus,
        "docDate": docDate,
        "whsCode": whsCode,
        "whsName": whsName,
        "quantity": quantity,
        "u_apaystat": uApaystat,
        "canceled": canceled,
        "stateCode": stateCode,
        "stateName": stateName,
        "districtId": districtId,
        "districtName": districtName,
        "isCollectionBlocked": isCollectionBlocked,
      };
}
