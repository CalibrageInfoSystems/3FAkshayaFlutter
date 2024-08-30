class FarmerInfo {
  final String farmerCode;
  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String branchName;
  final String ifscCode;
  final String guardianName;
  final String state;
  final String district;
  final String mandal;
  final String village;

  FarmerInfo({
    required this.farmerCode,
    required this.accountHolderName,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
    required this.ifscCode,
    required this.guardianName,
    required this.state,
    required this.district,
    required this.mandal,
    required this.village,
  });

  factory FarmerInfo.fromJson(Map<String, dynamic> json) {
    return FarmerInfo(
      farmerCode: json['farmerCode'],
      accountHolderName: json['accountHolderName'],
      accountNumber: json['accountNumber'],
      bankName: json['bankName'],
      branchName: json['branchName'],
      ifscCode: json['ifscCode'],
      guardianName: json['guardianName'],
      state: json['state'],
      district: json['district'],
      mandal: json['mandal'],
      village: json['village'],
    );
  }
}