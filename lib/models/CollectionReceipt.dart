class CollectionReceipt {
  final String code;
  final String collectionCenterCode;
  final String collectionCenter;
  final String vehicleNumber;
  final String driverName;
  final double grossWeight;
  final double tareWeight;
  final double netWeight;
  final DateTime receiptGeneratedDate;
  final String receiptImg;
  final String operatorName;
  final String comments;
  final int totalBunches;
  final int acceptedBunches;
  final int rejectedBunches;
  final String graderName;
  final String receiptCode;

  CollectionReceipt({
    required this.code,
    required this.collectionCenterCode,
    required this.collectionCenter,
    required this.vehicleNumber,
    required this.driverName,
    required this.grossWeight,
    required this.tareWeight,
    required this.netWeight,
    required this.receiptGeneratedDate,
    required this.receiptImg,
    required this.operatorName,
    required this.comments,
    required this.totalBunches,
    required this.acceptedBunches,
    required this.rejectedBunches,
    required this.graderName,
    required this.receiptCode,
  });

  factory CollectionReceipt.fromJson(Map<String, dynamic> json) {
    return CollectionReceipt(
      code: json['code'],
      collectionCenterCode: json['collectionCenterCode'],
      collectionCenter: json['collectionCenter'],
      vehicleNumber: json['vehicleNumber'],
      driverName: json['driverName'],
      grossWeight: json['grossWeight'].toDouble(),
      tareWeight: json['tareWeight'].toDouble(),
      netWeight: json['netWeight'].toDouble(),
      receiptGeneratedDate: DateTime.parse(json['receiptGeneratedDate']),
      receiptImg: json['receiptImg'],
      operatorName: json['operatorName'],
      comments: json['comments'] ?? '',
      totalBunches: json['totalBunches'],
      acceptedBunches: json['acceptedBunches'],
      rejectedBunches: json['rejectedBunches'],
      graderName: json['graderName'],
      receiptCode: json['receiptCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'collectionCenterCode': collectionCenterCode,
      'collectionCenter': collectionCenter,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'grossWeight': grossWeight,
      'tareWeight': tareWeight,
      'netWeight': netWeight,
      'receiptGeneratedDate': receiptGeneratedDate.toIso8601String(),
      'receiptImg': receiptImg,
      'operatorName': operatorName,
      'comments': comments,
      'totalBunches': totalBunches,
      'acceptedBunches': acceptedBunches,
      'rejectedBunches': rejectedBunches,
      'graderName': graderName,
      'receiptCode': receiptCode,
    };
  }
}
