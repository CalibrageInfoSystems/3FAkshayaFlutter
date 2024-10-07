import 'dart:convert';

PassbookTransportModel passbookTransportModelFromJson(String str) =>
    PassbookTransportModel.fromJson(json.decode(str));

String passbookTransportModelToJson(PassbookTransportModel data) =>
    json.encode(data.toJson());

class PassbookTransportModel {
  final List<TranspotationCharge>? transpotationCharges;
  final List<TrasportRate>? trasportRates;

  PassbookTransportModel({
    this.transpotationCharges,
    this.trasportRates,
  });

  factory PassbookTransportModel.fromJson(Map<String, dynamic> json) =>
      PassbookTransportModel(
        transpotationCharges: json["transpotationCharges"] == null
            ? []
            : List<TranspotationCharge>.from(json["transpotationCharges"]!
                .map((x) => TranspotationCharge.fromJson(x))),
        trasportRates: json["trasportRates"] == null
            ? []
            : List<TrasportRate>.from(
                json["trasportRates"]!.map((x) => TrasportRate.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "transpotationCharges": transpotationCharges == null
            ? []
            : List<dynamic>.from(transpotationCharges!.map((x) => x.toJson())),
        "trasportRates": trasportRates == null
            ? []
            : List<dynamic>.from(trasportRates!.map((x) => x.toJson())),
      };
}

class TranspotationCharge {
  final String? collectionCode;
  final String? farmerCode;
  final String? farmerName;
  final double? tonnageCost;
  final double? rate;
  final double? qty;
  final DateTime? receiptGeneratedDate;

  TranspotationCharge({
    this.collectionCode,
    this.farmerCode,
    this.farmerName,
    this.tonnageCost,
    this.rate,
    this.qty,
    this.receiptGeneratedDate,
  });

  factory TranspotationCharge.fromJson(Map<String, dynamic> json) =>
      TranspotationCharge(
        collectionCode: json["collectionCode"],
        farmerCode: json["farmerCode"],
        farmerName: json["farmerName"],
        tonnageCost: json["tonnageCost"]?.toDouble(),
        rate: json["rate"]?.toDouble(),
        qty: json["qty"]?.toDouble(),
        receiptGeneratedDate: json["receiptGeneratedDate"] == null
            ? null
            : DateTime.parse(json["receiptGeneratedDate"]),
      );

  Map<String, dynamic> toJson() => {
        "collectionCode": collectionCode,
        "farmerCode": farmerCode,
        "farmerName": farmerName,
        "tonnageCost": tonnageCost,
        "rate": rate,
        "qty": qty,
        "receiptGeneratedDate": receiptGeneratedDate?.toIso8601String(),
      };
}

class TrasportRate {
  final String? farmerCode;
  final String? village;
  final String? mandal;
  final String? rate;

  TrasportRate({
    this.farmerCode,
    this.village,
    this.mandal,
    this.rate,
  });

  factory TrasportRate.fromJson(Map<String, dynamic> json) => TrasportRate(
        farmerCode: json["farmerCode"],
        village: json["village"],
        mandal: json["mandal"],
        rate: json["rate"],
      );

  Map<String, dynamic> toJson() => {
        "farmerCode": farmerCode,
        "village": village,
        "mandal": mandal,
        "rate": rate,
      };
}
