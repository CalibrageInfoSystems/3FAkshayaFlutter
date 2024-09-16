class ViewLoanRequest {
  final String? requestCode;
  final String? farmerName;
  final String? farmerCode;
  final String? stateName;
  final String? reqCreatedDate;
  final int? totalCost;
  final String? comments;
  final String? createdBy;

  ViewLoanRequest({
    this.requestCode,
    this.farmerName,
    this.farmerCode,
    this.stateName,
    this.reqCreatedDate,
    this.totalCost,
    this.comments,
    this.createdBy,
  });

  factory ViewLoanRequest.fromJson(Map<String, dynamic> json) =>
      ViewLoanRequest(
        requestCode: json["requestCode"],
        farmerName: json["farmerName"],
        farmerCode: json["farmerCode"],
        stateName: json["stateName"],
        reqCreatedDate: json["reqCreatedDate"],
        totalCost: json["totalCost"],
        comments: json["comments"],
        createdBy: json["createdBy"],
      );

  Map<String, dynamic> toJson() => {
        "requestCode": requestCode,
        "farmerName": farmerName,
        "farmerCode": farmerCode,
        "stateName": stateName,
        "reqCreatedDate": reqCreatedDate,
        "totalCost": totalCost,
        "comments": comments,
        "createdBy": createdBy,
      };
}
