class QuickpayRequest {
  final String requestCode;
  final String farmerName;
  final String farmerCode;
  final String requestType;
  final String stateName;
  final String? clusterCategory;
  final String? reqCreatedDate;
  final int statusTypeId;
  final String statusType;
  final DateTime? approvedDate;
  final double totalCost;
  final String? createdBy;
  final String? comments;
  final bool? weighbridgeSlipVerified;
  final bool? requestsVerified;
  final bool? duesVerified;
  final DateTime updatedDate;
  final double netWeight;
  final String stateCode;
  final String districtName;

  QuickpayRequest({
    required this.requestCode,
    required this.farmerName,
    required this.farmerCode,
    required this.requestType,
    required this.stateName,
    this.clusterCategory,
    required this.reqCreatedDate,
    required this.statusTypeId,
    required this.statusType,
    this.approvedDate,
    required this.totalCost,
    this.createdBy,
    this.comments,
    this.weighbridgeSlipVerified,
    this.requestsVerified,
    this.duesVerified,
    required this.updatedDate,
    required this.netWeight,
    required this.stateCode,
    required this.districtName,
  });

  // Factory method to create object from JSON
  factory QuickpayRequest.fromJson(Map<String, dynamic> json) {
    return QuickpayRequest(
      requestCode: json['requestCode'],
      farmerName: json['farmerName'],
      farmerCode: json['farmerCode'],
      requestType: json['requestType'],
      stateName: json['stateName'],
      clusterCategory: json['clusterCategory'],
      reqCreatedDate: json['reqCreatedDate'],
      statusTypeId: json['statusTypeId'],
      statusType: json['statusType'],
      approvedDate: json['approvedDate'] != null
          ? DateTime.parse(json['approvedDate'])
          : null,
      totalCost: json['totalCost'].toDouble(),
      createdBy: json['createdBy'],
      comments: json['comments'],
      weighbridgeSlipVerified: json['weighbridgeSlipVerified'],
      requestsVerified: json['requestsVerified'],
      duesVerified: json['duesVerified'],
      updatedDate: DateTime.parse(json['updatedDate']),
      netWeight: json['netWeight'].toDouble(),
      stateCode: json['stateCode'],
      districtName: json['districtName'],
    );
  }

  // Method to convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'requestCode': requestCode,
      'farmerName': farmerName,
      'farmerCode': farmerCode,
      'requestType': requestType,
      'stateName': stateName,
      'clusterCategory': clusterCategory,
      'reqCreatedDate': reqCreatedDate,
      'statusTypeId': statusTypeId,
      'statusType': statusType,
      'approvedDate': approvedDate?.toIso8601String(),
      'totalCost': totalCost,
      'createdBy': createdBy,
      'comments': comments,
      'weighbridgeSlipVerified': weighbridgeSlipVerified,
      'requestsVerified': requestsVerified,
      'duesVerified': duesVerified,
      'updatedDate': updatedDate.toIso8601String(),
      'netWeight': netWeight,
      'stateCode': stateCode,
      'districtName': districtName,
    };
  }
}