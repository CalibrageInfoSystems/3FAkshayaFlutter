class ResponseModel {
  final Result result;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;
  final List<dynamic> validationErrors;
  final dynamic exception;

  ResponseModel({
    required this.result,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
    required this.validationErrors,
    this.exception,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      result: Result.fromJson(json['result']),
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      endUserMessage: json['endUserMessage'],
      validationErrors: List<dynamic>.from(json['validationErrors']),
      exception: json['exception'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.toJson(),
      'isSuccess': isSuccess,
      'affectedRecords': affectedRecords,
      'endUserMessage': endUserMessage,
      'validationErrors': validationErrors,
      'exception': exception,
    };
  }
}

class Result {
  final List<FarmerDetails> farmerDetails;
  final dynamic bannerDetails;
  final List<CategoryDetails> categoriesDetails;

  Result({
    required this.farmerDetails,
    this.bannerDetails,
    required this.categoriesDetails,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      farmerDetails: List<FarmerDetails>.from(
        json['farmerDetails'].map((x) => FarmerDetails.fromJson(x)),
      ),
      bannerDetails: json['bannerDetails'],
      categoriesDetails: List<CategoryDetails>.from(
        json['categoriesDetails'].map((x) => CategoryDetails.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'farmerDetails': farmerDetails.map((x) => x.toJson()).toList(),
      'bannerDetails': bannerDetails,
      'categoriesDetails': categoriesDetails.map((x) => x.toJson()).toList(),
    };
  }
}

class FarmerDetails {
  final String code;
  final int id;
  final String title;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String guardianName;
  final String motherName;
  final String contactNumber;
  final String? mobileNumber;
  final String contactNumbers;
  final DateTime dob;
  final int age;
  final String? email;
  final String villageName;
  final int pinCode;
  final String mandalName;
  final String districtName;
  final String stateName;
  final String stateCode;
  final int stateId;
  final int moduleTypeId;
  final String farmerPictureLocation;
  final String addressLine1;
  final String addressLine2;
  final String? addressLine3;
  final String landmark;
  final String address;
  final int clusterId;
  final String clusterName;
  final int villageId;
  final int districtId;

  FarmerDetails({
    required this.code,
    required this.id,
    required this.title,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.guardianName,
    required this.motherName,
    required this.contactNumber,
    this.mobileNumber,
    required this.contactNumbers,
    required this.dob,
    required this.age,
    this.email,
    required this.villageName,
    required this.pinCode,
    required this.mandalName,
    required this.districtName,
    required this.stateName,
    required this.stateCode,
    required this.stateId,
    required this.moduleTypeId,
    required this.farmerPictureLocation,
    required this.addressLine1,
    required this.addressLine2,
    this.addressLine3,
    required this.landmark,
    required this.address,
    required this.clusterId,
    required this.clusterName,
    required this.villageId,
    required this.districtId,
  });

  factory FarmerDetails.fromJson(Map<String, dynamic> json) {
    return FarmerDetails(
      code: json['code'],
      id: json['id'],
      title: json['title'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      guardianName: json['guardianName'],
      motherName: json['motherName'],
      contactNumber: json['contactNumber'],
      mobileNumber: json['mobileNumber'],
      contactNumbers: json['contactNumbers'],
      dob: DateTime.parse(json['dob']),
      age: json['age'],
      email: json['email'],
      villageName: json['villageName'],
      pinCode: json['pinCode'],
      mandalName: json['mandalName'],
      districtName: json['districtName'],
      stateName: json['stateName'],
      stateCode: json['stateCode'],
      stateId: json['stateId'],
      moduleTypeId: json['moduleTypeId'],
      farmerPictureLocation: json['farmerPictureLocation'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      addressLine3: json['addressLine3'],
      landmark: json['landmark'],
      address: json['address'],
      clusterId: json['clusterId'],
      clusterName: json['clusterName'],
      villageId: json['villageId'],
      districtId: json['districtId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'id': id,
      'title': title,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'guardianName': guardianName,
      'motherName': motherName,
      'contactNumber': contactNumber,
      'mobileNumber': mobileNumber,
      'contactNumbers': contactNumbers,
      'dob': dob.toIso8601String(),
      'age': age,
      'email': email,
      'villageName': villageName,
      'pinCode': pinCode,
      'mandalName': mandalName,
      'districtName': districtName,
      'stateName': stateName,
      'stateCode': stateCode,
      'stateId': stateId,
      'moduleTypeId': moduleTypeId,
      'farmerPictureLocation': farmerPictureLocation,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'addressLine3': addressLine3,
      'landmark': landmark,
      'address': address,
      'clusterId': clusterId,
      'clusterName': clusterName,
      'villageId': villageId,
      'districtId': districtId,
    };
  }
}

class CategoryDetails {
  final int id;
  final String name;
  final String teluguName;
  final String hindiName;
  final String remarks;
  final bool isActive;
  final int createdByUserId;
  final DateTime createdDate;
  final int updatedByUserId;
  final DateTime updatedDate;
  final String kannadaName;

  CategoryDetails({
    required this.id,
    required this.name,
    required this.teluguName,
    required this.hindiName,
    required this.remarks,
    required this.isActive,
    required this.createdByUserId,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedDate,
    required this.kannadaName,
  });

  factory CategoryDetails.fromJson(Map<String, dynamic> json) {
    return CategoryDetails(
      id: json['id'],
      name: json['name'],
      teluguName: json['teluguName'],
      hindiName: json['hindiName'],
      remarks: json['remarks'],
      isActive: json['isActive'],
      createdByUserId: json['createdByUserId'],
      createdDate: DateTime.parse(json['createdDate']),
      updatedByUserId: json['updatedByUserId'],
      updatedDate: DateTime.parse(json['updatedDate']),
      kannadaName: json['kannadaName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teluguName': teluguName,
      'hindiName': hindiName,
      'remarks': remarks,
      'isActive': isActive,
      'createdByUserId': createdByUserId,
      'createdDate': createdDate.toIso8601String(),
      'updatedByUserId': updatedByUserId,
      'updatedDate': updatedDate.toIso8601String(),
      'kannadaName': kannadaName,
    };
  }
}
