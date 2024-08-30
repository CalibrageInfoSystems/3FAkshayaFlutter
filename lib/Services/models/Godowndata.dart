//Godowndata
class Godowndata {
  final int? stateId;
  final String? stateName;
  final int? districtId;
  final String? districtName;
  final int? mandalId;
  final String? mandalName;
  final String? clusterName;
  final int? id;
  final String? name;
  final int? typeId;
  final String location;
  final String address;
  final String contactNumber;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final int createdByUserId;
  final DateTime? createdDate;
  final int updatedByUserId;
  final DateTime updatedDate;
  final String? stateCode;
  final String? code;
  final int? clusterId;
  final String? fertilizerLicenseNumber;
  final String? pesticideLicenseNumber;

  Godowndata({
    required this.stateId,
    required this.stateName,
    required this.districtId,
    this.districtName,
    required this.mandalId,
    this.mandalName,
    this.clusterName,
    required this.id,
    required this.name,
    required this.typeId,
    required this.location,
    required this.address,
    required this.contactNumber,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.createdByUserId,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedDate,
    required this.stateCode,
    required this.code,
    this.clusterId,
    this.fertilizerLicenseNumber,
    this.pesticideLicenseNumber,
  });

  factory Godowndata.fromJson(Map<String, dynamic> json) {
    return Godowndata(
      stateId: json['stateId'],
      stateName: json['stateName'],
      districtId: json['districtId'],
      districtName: json['districtName'],
      mandalId: json['mandalId'],
      mandalName: json['mandalName'],
      clusterName: json['clusterName'],
      id: json['id'],
      name: json['name'],
      typeId: json['typeId'],
      location: json['location'],
      address: json['address'],
      contactNumber: json['contactNumber'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      isActive: json['isActive'],
      createdByUserId: json['createdByUserId'],
      createdDate: DateTime.parse(json['createdDate']),
      updatedByUserId: json['updatedByUserId'],
      updatedDate: DateTime.parse(json['updatedDate']),
      stateCode: json['stateCode'],
      code: json['code'],
      clusterId: json['clusterId'],
      fertilizerLicenseNumber: json['fertilizerLicenseNumber'],
      pesticideLicenseNumber: json['pesticideLicenseNumber'],
    );
  }
}
