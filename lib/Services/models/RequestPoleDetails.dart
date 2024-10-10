class RequestPoleDetails {
  final int productId;
  final int quantity;
  final double bagCost;
  final double? size;
  final double ?gstPersentage;
  final String productCode;


  RequestPoleDetails({
    required this.productId,
    required this.quantity,
    required this.bagCost,
    required this.size,
    required this.gstPersentage,
    required this.productCode,

  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'bagCost': bagCost,
    'size': size,
    'gstPersentage': gstPersentage,
    'productCode': productCode,

  };
}

class FertilizerRequest {
  final int id;
  final int requestTypeId;
  final String farmerCode;
  final String farmerName;
  final String? plotCode;
  final String requestCreatedDate;
  final bool isFarmerRequest;
  final int? createdByUserId; // Nullable
  final String createdDate;
  final int? updatedByUserId; // Nullable
  final String updatedDate;
  final int godownId;
  final int paymentModeType;
  final bool? isImmediatePayment;
  final String? fileName; // Nullable
  final String? fileLocation; // Nullable
  final String? fileExtension; // Nullable
  final double totalCost;
  final double? subcidyAmount;
  final double? paybleAmount;
  final double? transportPayableAmount;
  final String? comments; // Nullable
  final DateTime? cropMaintainceDate; // Nullable
  final int? issueTypeId; // Nullable
  final String godownCode;
  final List<RequestPoleDetails> requestProductDetails;
  final int clusterId;
  final String stateCode;
  final String stateName;

  FertilizerRequest({
    required this.id,
    required this.requestTypeId,
    required this.farmerCode,
    required this.farmerName,
    required this.plotCode,
    required this.requestCreatedDate,
    required this.isFarmerRequest,
    this.createdByUserId,
    required this.createdDate,
    this.updatedByUserId,
    required this.updatedDate,
    required this.godownId,
    required this.paymentModeType,
    required this.isImmediatePayment,
    this.fileName,
    this.fileLocation,
    this.fileExtension,
    required this.totalCost,
    required this.subcidyAmount,
    required this.paybleAmount,
    required this.transportPayableAmount,
    this.comments,
    this.cropMaintainceDate,
    this.issueTypeId,
    required this.godownCode,
    required this.requestProductDetails,
    required this.clusterId,
    required this.stateCode,
    required this.stateName,
  });



  Map<String, dynamic> toJson() => {
    'id': id,
    'requestTypeId': requestTypeId,
    'farmerCode': farmerCode,
    'farmerName': farmerName,
    'plotCode': plotCode,
    'requestCreatedDate': requestCreatedDate,
    'isFarmerRequest': isFarmerRequest,
    'createdByUserId': createdByUserId,
    'createdDate': createdDate,
    'updatedByUserId': updatedByUserId,
    'updatedDate': updatedDate,
    'godownId': godownId,
    'paymentModeType': paymentModeType,
    'isImmediatePayment': isImmediatePayment,
    'fileName': fileName,
    'fileLocation': fileLocation,
    'fileExtension': fileExtension,
    'totalCost': totalCost,
    'subcidyAmount': subcidyAmount,
    'paybleAmount': paybleAmount,
    'transportPayableAmount': transportPayableAmount,
    'comments': comments,
    'cropMaintainceDate': cropMaintainceDate,
    'issueTypeId': issueTypeId,
    'godownCode': godownCode,
    'requestProductDetails':
    requestProductDetails.map((e) => e.toJson()).toList(),
    'clusterId': clusterId,
    'stateCode': stateCode,
    'stateName': stateName,
  };
}
