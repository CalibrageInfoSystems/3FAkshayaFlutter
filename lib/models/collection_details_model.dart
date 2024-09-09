import 'dart:convert';

CollectionDetails collectionDetailsFromJson(String str) =>
    CollectionDetails.fromJson(json.decode(str));

String collectionDetailsToJson(CollectionDetails data) =>
    json.encode(data.toJson());

class CollectionDetails {
  final String? collectionId;
  final double? collectionQuantity;
  final String? date;
  final double? quantity;
  final double? quickPayRate; // ffbFlatCharge
  final double? quickPayCost; // ffbCost
  final double? transactionFee; // convenienceCharge
  final double? dues; // closingBalance
  final double? quickPay;
  final double? total;

  CollectionDetails({
    this.collectionId,
    this.collectionQuantity,
    this.date,
    this.quantity,
    this.quickPayRate,
    this.quickPayCost,
    this.transactionFee,
    this.dues,
    this.quickPay,
    this.total,
  });

  factory CollectionDetails.fromJson(Map<String, dynamic> json) =>
      CollectionDetails(
        collectionId: json["collectionId"],
        collectionQuantity: json["collection_quantity"]?.toDouble(),
        date: json["date"],
        quantity: json["quantity"]?.toDouble(),
        quickPayRate: json["quickPayRate"]?.toDouble(),
        quickPayCost: json["quickPayCost"]?.toDouble(),
        transactionFee: json["transactionFee"]?.toDouble(),
        dues: json["dues"]?.toDouble(),
        quickPay: json["quickPay"]?.toDouble(),
        total: json["total"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "collectionId": collectionId,
        "collection_quantity": collectionQuantity,
        "date": date,
        "quantity": quantity,
        "quickPayRate": quickPayRate,
        "quickPayCost": quickPayCost,
        "transactionFee": transactionFee,
        "dues": dues,
        "quickPay": quickPay,
        "total": total,
      };
}
