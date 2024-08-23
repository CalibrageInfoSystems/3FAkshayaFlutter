import 'dart:convert';

FarmerModel farmerModelFromJson(String str) =>
    FarmerModel.fromJson(json.decode(str));

String farmerModelToJson(FarmerModel data) => json.encode(data.toJson());

class FarmerModel {
  final String? code;
  final int? id;
  final String? title;
  final String? firstName;
  final dynamic middleName;
  final String? lastName;
  final String? guardianName;
  final String? motherName;
  final String? contactNumber;
  final dynamic mobileNumber;
  final String? contactNumbers;
  final DateTime? dob;
  final int? age;
  final dynamic email;
  final String? villageName;
  final int? pinCode;
  final String? mandalName;
  final String? districtName;
  final String? stateName;
  final String? stateCode;
  final int? stateId;
  final int? moduleTypeId;
  final String? farmerPictureLocation;
  final String? addressLine1;
  final String? addressLine2;
  final dynamic addressLine3;
  final String? landmark;
  final String? address;
  final int? clusterId;
  final String? clusterName;
  final int? villageId;
  final int? districtId;

  FarmerModel({
    this.code,
    this.id,
    this.title,
    this.firstName,
    this.middleName,
    this.lastName,
    this.guardianName,
    this.motherName,
    this.contactNumber,
    this.mobileNumber,
    this.contactNumbers,
    this.dob,
    this.age,
    this.email,
    this.villageName,
    this.pinCode,
    this.mandalName,
    this.districtName,
    this.stateName,
    this.stateCode,
    this.stateId,
    this.moduleTypeId,
    this.farmerPictureLocation,
    this.addressLine1,
    this.addressLine2,
    this.addressLine3,
    this.landmark,
    this.address,
    this.clusterId,
    this.clusterName,
    this.villageId,
    this.districtId,
  });

  factory FarmerModel.fromJson(Map<String, dynamic> json) => FarmerModel(
        code: json["code"],
        id: json["id"],
        title: json["title"],
        firstName: json["firstName"],
        middleName: json["middleName"],
        lastName: json["lastName"],
        guardianName: json["guardianName"],
        motherName: json["motherName"],
        contactNumber: json["contactNumber"],
        mobileNumber: json["mobileNumber"],
        contactNumbers: json["contactNumbers"],
        dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
        age: json["age"],
        email: json["email"],
        villageName: json["villageName"],
        pinCode: json["pinCode"],
        mandalName: json["mandalName"],
        districtName: json["districtName"],
        stateName: json["stateName"],
        stateCode: json["stateCode"],
        stateId: json["stateId"],
        moduleTypeId: json["moduleTypeId"],
        farmerPictureLocation: json["farmerPictureLocation"],
        addressLine1: json["addressLine1"],
        addressLine2: json["addressLine2"],
        addressLine3: json["addressLine3"],
        landmark: json["landmark"],
        address: json["address"],
        clusterId: json["clusterId"],
        clusterName: json["clusterName"],
        villageId: json["villageId"],
        districtId: json["districtId"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "id": id,
        "title": title,
        "firstName": firstName,
        "middleName": middleName,
        "lastName": lastName,
        "guardianName": guardianName,
        "motherName": motherName,
        "contactNumber": contactNumber,
        "mobileNumber": mobileNumber,
        "contactNumbers": contactNumbers,
        "dob": dob?.toIso8601String(),
        "age": age,
        "email": email,
        "villageName": villageName,
        "pinCode": pinCode,
        "mandalName": mandalName,
        "districtName": districtName,
        "stateName": stateName,
        "stateCode": stateCode,
        "stateId": stateId,
        "moduleTypeId": moduleTypeId,
        "farmerPictureLocation": farmerPictureLocation,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "addressLine3": addressLine3,
        "landmark": landmark,
        "address": address,
        "clusterId": clusterId,
        "clusterName": clusterName,
        "villageId": villageId,
        "districtId": districtId,
      };
}
