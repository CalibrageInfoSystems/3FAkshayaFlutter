import 'dart:convert';

ViewLabourModel viewLabourModelFromJson(String str) =>
    ViewLabourModel.fromJson(json.decode(str));

String viewLabourModelToJson(ViewLabourModel data) =>
    json.encode(data.toJson());

class ViewLabourModel {
  final String? requestCode;
  final int? requestTypeId;
  final String? requestType;
  final String? farmerCode;
  final String? farmerName;
  final String? plotCode;
  final String? plotVillage;
  final double? palmArea;
  final DateTime? reqCreatedDate;
  final int? statusTypeId;
  final String? statusType;
  final bool? isFarmerRequest;
  final DateTime? startDate;
  final int? durationId;
  final String? duration;
  final int? leaderId;
  final String? ownPole;
  final String? leader;
  final int? pin;
  final String? jobDoneDate;
  final int? createdByUserId;
  final String? createdBy;
  final DateTime? createdDate;
  final int? updatedByUserId;
  final String? updatedBy;
  final DateTime? updatedDate;
  final double? totalNetWeight;
  final double? netWeight;
  final double? netWeightIntercrop;
  final double? totalCost;
  final String? collectionIds;
  final String? collectionswithDate;
  final String? isIntercrop;
  final String? comments;
  final double? harvestingAmount;
  final double? pruningAmount;
  final double? pruningWithIntercropAmount;
  final double? harvestingWithIntercropAmount;
  final int? treesCount;
  final String? serviceTypes;
  final String? serviceTypeIds;
  final double? serviceChargePercentage;
  final String? assignedDate;
  final int? treesCountWithIntercrop;
  final DateTime? yearofPlanting;
  final double? harvestingAmountWithCharge;
  final double? pruningAmountWithChange;
  final double? pruningWithIntercropAmountAndCharge;
  final double? harvestingWithIntercropAmountAndCharge;
  final int? expectedBunches;
  final double? expectedNetWeight;
  final int? clusterId;
  final double? actualPrice;
  final double? paidHarvestingAmount;
  final double? miscellaneousIncome;
  final double? harvestingFund;
  final String? peakSeasonCharge;
  final String? labours;
  final String? labourIds;
  final double? serviceChargeAmount;
  final double? totalCostWithoutServiceCharge;
  final String? closedDate;
  final String? recoveryFarmerCode;
  final String? recoveryFarmerName;
  final int? packageDiscount;

  ViewLabourModel({
    this.requestCode,
    this.requestTypeId,
    this.requestType,
    this.farmerCode,
    this.farmerName,
    this.plotCode,
    this.plotVillage,
    this.palmArea,
    this.reqCreatedDate,
    this.statusTypeId,
    this.statusType,
    this.isFarmerRequest,
    this.startDate,
    this.durationId,
    this.duration,
    this.leaderId,
    this.ownPole,
    this.leader,
    this.pin,
    this.jobDoneDate,
    this.createdByUserId,
    this.createdBy,
    this.createdDate,
    this.updatedByUserId,
    this.updatedBy,
    this.updatedDate,
    this.totalNetWeight,
    this.netWeight,
    this.netWeightIntercrop,
    this.totalCost,
    this.collectionIds,
    this.collectionswithDate,
    this.isIntercrop,
    this.comments,
    this.harvestingAmount,
    this.pruningAmount,
    this.pruningWithIntercropAmount,
    this.harvestingWithIntercropAmount,
    this.treesCount,
    this.serviceTypes,
    this.serviceTypeIds,
    this.serviceChargePercentage,
    this.assignedDate,
    this.treesCountWithIntercrop,
    this.yearofPlanting,
    this.harvestingAmountWithCharge,
    this.pruningAmountWithChange,
    this.pruningWithIntercropAmountAndCharge,
    this.harvestingWithIntercropAmountAndCharge,
    this.expectedBunches,
    this.expectedNetWeight,
    this.clusterId,
    this.actualPrice,
    this.paidHarvestingAmount,
    this.miscellaneousIncome,
    this.harvestingFund,
    this.peakSeasonCharge,
    this.labours,
    this.labourIds,
    this.serviceChargeAmount,
    this.totalCostWithoutServiceCharge,
    this.closedDate,
    this.recoveryFarmerCode,
    this.recoveryFarmerName,
    this.packageDiscount,
  });

  factory ViewLabourModel.fromJson(Map<String, dynamic> json) =>
      ViewLabourModel(
        requestCode: json["requestCode"],
        requestTypeId: json["requestTypeId"],
        requestType: json["requestType"],
        farmerCode: json["farmerCode"],
        farmerName: json["farmerName"],
        plotCode: json["plotCode"],
        plotVillage: json["plotVillage"],
        palmArea: json["palmArea"]?.toDouble(),
        reqCreatedDate: json["reqCreatedDate"] == null
            ? null
            : DateTime.parse(json["reqCreatedDate"]),
        statusTypeId: json["statusTypeId"],
        statusType: json["statusType"],
        isFarmerRequest: json["isFarmerRequest"],
        startDate: json["startDate"] == null
            ? null
            : DateTime.parse(json["startDate"]),
        durationId: json["durationId"],
        duration: json["duration"],
        leaderId: json["leaderId"],
        ownPole: json["ownPole"],
        leader: json["leader"],
        pin: json["pin"],
        jobDoneDate: json["jobDoneDate"],
        createdByUserId: json["createdByUserId"],
        createdBy: json["createdBy"],
        createdDate: json["createdDate"] == null
            ? null
            : DateTime.parse(json["createdDate"]),
        updatedByUserId: json["updatedByUserId"],
        updatedBy: json["updatedBy"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
        totalNetWeight: json["totalNetWeight"]?.toDouble(),
        netWeight: json["netWeight"]?.toDouble(),
        netWeightIntercrop: json["netWeightIntercrop"]?.toDouble(),
        totalCost: json["totalCost"]?.toDouble(),
        collectionIds: json["collectionIds"],
        collectionswithDate: json["collectionswithDate"],
        isIntercrop: json["isIntercrop"],
        comments: json["comments"],
        harvestingAmount: json["harvestingAmount"]?.toDouble(),
        pruningAmount: json["pruningAmount"],
        pruningWithIntercropAmount:
            json["pruningWithIntercropAmount"]?.toDouble(),
        harvestingWithIntercropAmount:
            json["harvestingWithIntercropAmount"]?.toDouble(),
        treesCount: json["treesCount"],
        serviceTypes: json["serviceTypes"],
        serviceTypeIds: json["serviceTypeIds"],
        serviceChargePercentage: json["serviceChargePercentage"]?.toDouble(),
        assignedDate: json["assignedDate"],
        treesCountWithIntercrop: json["treesCountWithIntercrop"],
        yearofPlanting: json["yearofPlanting"] == null
            ? null
            : DateTime.parse(json["yearofPlanting"]),
        harvestingAmountWithCharge:
            json["harvestingAmountWithCharge"]?.toDouble(),
        pruningAmountWithChange: json["pruningAmountWithChange"]?.toDouble(),
        pruningWithIntercropAmountAndCharge:
            json["pruningWithIntercropAmountAndCharge"]?.toDouble(),
        harvestingWithIntercropAmountAndCharge:
            json["harvestingWithIntercropAmountAndCharge"]?.toDouble(),
        expectedBunches: json["expectedBunches"],
        expectedNetWeight: json["expectedNetWeight"]?.toDouble(),
        clusterId: json["clusterId"],
        actualPrice: json["actualPrice"]?.toDouble(),
        paidHarvestingAmount: json["paidHarvestingAmount"]?.toDouble(),
        miscellaneousIncome: json["miscellaneousIncome"]?.toDouble(),
        harvestingFund: json["harvestingFund"]?.toDouble(),
        peakSeasonCharge: json["peakSeasonCharge"],
        labours: json["labours"],
        labourIds: json["labourIds"],
        serviceChargeAmount: json["serviceChargeAmount"]?.toDouble(),
        totalCostWithoutServiceCharge:
            json["totalCostWithoutServiceCharge"]?.toDouble(),
        closedDate: json["closedDate"],
        recoveryFarmerCode: json["recoveryFarmerCode"],
        recoveryFarmerName: json["recoveryFarmerName"],
        packageDiscount: json["packageDiscount"],
      );

  Map<String, dynamic> toJson() => {
        "requestCode": requestCode,
        "requestTypeId": requestTypeId,
        "requestType": requestType,
        "farmerCode": farmerCode,
        "farmerName": farmerName,
        "plotCode": plotCode,
        "plotVillage": plotVillage,
        "palmArea": palmArea,
        "reqCreatedDate": reqCreatedDate?.toIso8601String(),
        "statusTypeId": statusTypeId,
        "statusType": statusType,
        "isFarmerRequest": isFarmerRequest,
        "startDate": startDate?.toIso8601String(),
        "durationId": durationId,
        "duration": duration,
        "leaderId": leaderId,
        "ownPole": ownPole,
        "leader": leader,
        "pin": pin,
        "jobDoneDate": jobDoneDate,
        "createdByUserId": createdByUserId,
        "createdBy": createdBy,
        "createdDate": createdDate?.toIso8601String(),
        "updatedByUserId": updatedByUserId,
        "updatedBy": updatedBy,
        "updatedDate": updatedDate?.toIso8601String(),
        "totalNetWeight": totalNetWeight,
        "netWeight": netWeight,
        "netWeightIntercrop": netWeightIntercrop,
        "totalCost": totalCost,
        "collectionIds": collectionIds,
        "collectionswithDate": collectionswithDate,
        "isIntercrop": isIntercrop,
        "comments": comments,
        "harvestingAmount": harvestingAmount,
        "pruningAmount": pruningAmount,
        "pruningWithIntercropAmount": pruningWithIntercropAmount,
        "harvestingWithIntercropAmount": harvestingWithIntercropAmount,
        "treesCount": treesCount,
        "serviceTypes": serviceTypes,
        "serviceTypeIds": serviceTypeIds,
        "serviceChargePercentage": serviceChargePercentage,
        "assignedDate": assignedDate,
        "treesCountWithIntercrop": treesCountWithIntercrop,
        "yearofPlanting": yearofPlanting?.toIso8601String(),
        "harvestingAmountWithCharge": harvestingAmountWithCharge,
        "pruningAmountWithChange": pruningAmountWithChange,
        "pruningWithIntercropAmountAndCharge":
            pruningWithIntercropAmountAndCharge,
        "harvestingWithIntercropAmountAndCharge":
            harvestingWithIntercropAmountAndCharge,
        "expectedBunches": expectedBunches,
        "expectedNetWeight": expectedNetWeight,
        "clusterId": clusterId,
        "actualPrice": actualPrice,
        "paidHarvestingAmount": paidHarvestingAmount,
        "miscellaneousIncome": miscellaneousIncome,
        "harvestingFund": harvestingFund,
        "peakSeasonCharge": peakSeasonCharge,
        "labours": labours,
        "labourIds": labourIds,
        "serviceChargeAmount": serviceChargeAmount,
        "totalCostWithoutServiceCharge": totalCostWithoutServiceCharge,
        "closedDate": closedDate,
        "recoveryFarmerCode": recoveryFarmerCode,
        "recoveryFarmerName": recoveryFarmerName,
        "packageDiscount": packageDiscount,
      };
}
