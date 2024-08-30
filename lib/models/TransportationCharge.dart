import 'package:intl/intl.dart';

class TransportationCharge {
  final String collectionCode;
  final String farmerCode;
  final String farmerName;
  final double tonnageCost;
  final double rate;
  final double qty;
  final DateTime receiptGeneratedDate;

  TransportationCharge({
    required this.collectionCode,
    required this.farmerCode,
    required this.farmerName,
    required this.tonnageCost,
    required this.rate,
    required this.qty,
    required this.receiptGeneratedDate,
  });

  factory TransportationCharge.fromJson(Map<String, dynamic> json) {
    return TransportationCharge(
      collectionCode: json['collectionCode'],
      farmerCode: json['farmerCode'],
      farmerName: json['farmerName'],
      tonnageCost: json['tonnageCost'].toDouble(),
      rate: json['rate'].toDouble(),
      qty: json['qty'].toDouble(),
      receiptGeneratedDate: DateTime.parse(json['receiptGeneratedDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collectionCode': collectionCode,
      'farmerCode': farmerCode,
      'farmerName': farmerName,
      'tonnageCost': tonnageCost,
      'rate': rate,
      'qty': qty,
      'receiptGeneratedDate': receiptGeneratedDate.toIso8601String(),
    };
  }
}

class TransportRate {
  final String farmerCode;
  final String village;
  final String mandal;
  final String rate;

  TransportRate({
    required this.farmerCode,
    required this.village,
    required this.mandal,
    required this.rate,
  });

  factory TransportRate.fromJson(Map<String, dynamic> json) {
    return TransportRate(
      farmerCode: json['farmerCode'],
      village: json['village'],
      mandal: json['mandal'],
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmerCode': farmerCode,
      'village': village,
      'mandal': mandal,
      'rate': rate,
    };
  }
}
class ApiResponse {
  final List<TransportationCharge> transportationCharges;
  final List<TransportRate> transportRates;

  ApiResponse({
    required this.transportationCharges,
    required this.transportRates,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var listTransportationCharges = json['transpotationCharges'] as List;
    var listTransportRates = json['trasportRates'] as List;

    List<TransportationCharge> transportationChargesList = listTransportationCharges.map((i) => TransportationCharge.fromJson(i)).toList();
    List<TransportRate> transportRatesList = listTransportRates.map((i) => TransportRate.fromJson(i)).toList();

    return ApiResponse(
      transportationCharges: transportationChargesList,
      transportRates: transportRatesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transpotationCharges': transportationCharges.map((e) => e.toJson()).toList(),
      'trasportRates': transportRates.map((e) => e.toJson()).toList(),
    };
  }
}
