// To parse this JSON data, do
//
//     final plotHistory = plotHistoryFromJson(jsonString);

import 'dart:convert';

PlotHistory plotHistoryFromJson(String str) =>
    PlotHistory.fromJson(json.decode(str));

String plotHistoryToJson(PlotHistory data) => json.encode(data.toJson());

class PlotHistory {
  final HealthPlantationData? healthPlantationData;
  final List<NutrientDatum>? nutrientData;
  final UprootmentData? uprootmentData;
  final List<PestDatum>? pestData;
  final List<dynamic>? fertilizerRecommendationDetails;
  final List<DiseaseDatum>? diseaseData;
  final List<PlotIrrigation>? plotIrrigation;
  final int? frequencyOfHarvest;

  PlotHistory({
    this.healthPlantationData,
    this.nutrientData,
    this.uprootmentData,
    this.pestData,
    this.fertilizerRecommendationDetails,
    this.diseaseData,
    this.plotIrrigation,
    this.frequencyOfHarvest,
  });

  factory PlotHistory.fromJson(Map<String, dynamic> json) => PlotHistory(
        healthPlantationData: json["healthPlantationData"] == null
            ? null
            : HealthPlantationData.fromJson(json["healthPlantationData"]),
        nutrientData: json["nutrientData"] == null
            ? []
            : List<NutrientDatum>.from(
                json["nutrientData"]!.map((x) => NutrientDatum.fromJson(x))),
        uprootmentData: json["uprootmentData"] == null
            ? null
            : UprootmentData.fromJson(json["uprootmentData"]),
        pestData: json["pestData"] == null
            ? []
            : List<PestDatum>.from(
                json["pestData"]!.map((x) => PestDatum.fromJson(x))),
        fertilizerRecommendationDetails:
            json["fertilizerRecommendationDetails"] == null
                ? []
                : List<dynamic>.from(
                    json["fertilizerRecommendationDetails"]!.map((x) => x)),
        diseaseData: json["diseaseData"] == null
            ? []
            : List<DiseaseDatum>.from(
                json["diseaseData"]!.map((x) => DiseaseDatum.fromJson(x))),
        plotIrrigation: json["plotIrrigation"] == null
            ? []
            : List<PlotIrrigation>.from(
                json["plotIrrigation"]!.map((x) => PlotIrrigation.fromJson(x))),
        frequencyOfHarvest: json["frequencyOfHarvest"],
      );

  Map<String, dynamic> toJson() => {
        "healthPlantationData": healthPlantationData?.toJson(),
        "nutrientData": nutrientData == null
            ? []
            : List<dynamic>.from(nutrientData!.map((x) => x.toJson())),
        "uprootmentData": uprootmentData?.toJson(),
        "pestData": pestData == null
            ? []
            : List<dynamic>.from(pestData!.map((x) => x.toJson())),
        "fertilizerRecommendationDetails":
            fertilizerRecommendationDetails == null
                ? []
                : List<dynamic>.from(
                    fertilizerRecommendationDetails!.map((x) => x)),
        "diseaseData": diseaseData == null
            ? []
            : List<dynamic>.from(diseaseData!.map((x) => x.toJson())),
        "plotIrrigation": plotIrrigation == null
            ? []
            : List<dynamic>.from(plotIrrigation!.map((x) => x.toJson())),
        "frequencyOfHarvest": frequencyOfHarvest,
      };
}

class DiseaseDatum {
  final String? plotCode;
  final String? isDiseaseNoticedinPreviousVisit;
  final String? isProblemRectified;
  final dynamic problemRectifiedComments;
  final String? disease;
  final int? diseaseId;
  final dynamic chemical;
  final dynamic chemicalId;
  final String? isResultSeen;
  final dynamic comments;
  final String? isActive;
  final DateTime? updatedDate;
  final int? dosage;
  final dynamic uomName;
  final dynamic recommendedChemical;
  final String? cropMaintenanceCode;

  DiseaseDatum({
    this.plotCode,
    this.isDiseaseNoticedinPreviousVisit,
    this.isProblemRectified,
    this.problemRectifiedComments,
    this.disease,
    this.diseaseId,
    this.chemical,
    this.chemicalId,
    this.isResultSeen,
    this.comments,
    this.isActive,
    this.updatedDate,
    this.dosage,
    this.uomName,
    this.recommendedChemical,
    this.cropMaintenanceCode,
  });

  factory DiseaseDatum.fromJson(Map<String, dynamic> json) => DiseaseDatum(
        plotCode: json["plotCode"],
        isDiseaseNoticedinPreviousVisit:
            json["isDiseaseNoticedinPreviousVisit"],
        isProblemRectified: json["isProblemRectified"],
        problemRectifiedComments: json["problemRectifiedComments"],
        disease: json["disease"],
        diseaseId: json["diseaseId"],
        chemical: json["chemical"],
        chemicalId: json["chemicalId"],
        isResultSeen: json["isResultSeen"],
        comments: json["comments"],
        isActive: json["isActive"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
        dosage: json["dosage"],
        uomName: json["uomName"],
        recommendedChemical: json["recommendedChemical"],
        cropMaintenanceCode: json["cropMaintenanceCode"],
      );

  Map<String, dynamic> toJson() => {
        "plotCode": plotCode,
        "isDiseaseNoticedinPreviousVisit": isDiseaseNoticedinPreviousVisit,
        "isProblemRectified": isProblemRectified,
        "problemRectifiedComments": problemRectifiedComments,
        "disease": disease,
        "diseaseId": diseaseId,
        "chemical": chemical,
        "chemicalId": chemicalId,
        "isResultSeen": isResultSeen,
        "comments": comments,
        "isActive": isActive,
        "updatedDate": updatedDate?.toIso8601String(),
        "dosage": dosage,
        "uomName": uomName,
        "recommendedChemical": recommendedChemical,
        "cropMaintenanceCode": cropMaintenanceCode,
      };
}

class HealthPlantationData {
  final String? plotCode;
  final int? plantationStateTypeId;
  final String? plantationState;
  final int? treesAppearanceTypeId;
  final String? treesAppearance;
  final int? treeGirthTypeId;
  final String? treeGirth;
  final int? treeHeightTypeId;
  final String? treeHeight;
  final dynamic fruitColorTypeId;
  final dynamic fruitColor;
  final dynamic fruitSizeTypeId;
  final dynamic fruitSize;
  final int? fruitHyegieneTypeId;
  final String? fruitHyegiene;
  final int? plantationTypeId;
  final String? plantationType;
  final String? plantationPictureLocation;
  final String? isActive;
  final DateTime? updatedDate;
  final String? cropMaintenanceCode;

  HealthPlantationData({
    this.plotCode,
    this.plantationStateTypeId,
    this.plantationState,
    this.treesAppearanceTypeId,
    this.treesAppearance,
    this.treeGirthTypeId,
    this.treeGirth,
    this.treeHeightTypeId,
    this.treeHeight,
    this.fruitColorTypeId,
    this.fruitColor,
    this.fruitSizeTypeId,
    this.fruitSize,
    this.fruitHyegieneTypeId,
    this.fruitHyegiene,
    this.plantationTypeId,
    this.plantationType,
    this.plantationPictureLocation,
    this.isActive,
    this.updatedDate,
    this.cropMaintenanceCode,
  });

  factory HealthPlantationData.fromJson(Map<String, dynamic> json) =>
      HealthPlantationData(
        plotCode: json["plotCode"],
        plantationStateTypeId: json["plantationStateTypeId"],
        plantationState: json["plantationState"],
        treesAppearanceTypeId: json["treesAppearanceTypeId"],
        treesAppearance: json["treesAppearance"],
        treeGirthTypeId: json["treeGirthTypeId"],
        treeGirth: json["treeGirth"],
        treeHeightTypeId: json["treeHeightTypeId"],
        treeHeight: json["treeHeight"],
        fruitColorTypeId: json["fruitColorTypeId"],
        fruitColor: json["fruitColor"],
        fruitSizeTypeId: json["fruitSizeTypeId"],
        fruitSize: json["fruitSize"],
        fruitHyegieneTypeId: json["fruitHyegieneTypeId"],
        fruitHyegiene: json["fruitHyegiene"],
        plantationTypeId: json["plantationTypeId"],
        plantationType: json["plantationType"],
        plantationPictureLocation: json["plantationPictureLocation"],
        isActive: json["isActive"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
        cropMaintenanceCode: json["cropMaintenanceCode"],
      );

  Map<String, dynamic> toJson() => {
        "plotCode": plotCode,
        "plantationStateTypeId": plantationStateTypeId,
        "plantationState": plantationState,
        "treesAppearanceTypeId": treesAppearanceTypeId,
        "treesAppearance": treesAppearance,
        "treeGirthTypeId": treeGirthTypeId,
        "treeGirth": treeGirth,
        "treeHeightTypeId": treeHeightTypeId,
        "treeHeight": treeHeight,
        "fruitColorTypeId": fruitColorTypeId,
        "fruitColor": fruitColor,
        "fruitSizeTypeId": fruitSizeTypeId,
        "fruitSize": fruitSize,
        "fruitHyegieneTypeId": fruitHyegieneTypeId,
        "fruitHyegiene": fruitHyegiene,
        "plantationTypeId": plantationTypeId,
        "plantationType": plantationType,
        "plantationPictureLocation": plantationPictureLocation,
        "isActive": isActive,
        "updatedDate": updatedDate?.toIso8601String(),
        "cropMaintenanceCode": cropMaintenanceCode,
      };
}

class NutrientDatum {
  final String? plotCode;
  final String? isPreviousNutrientDeficiency;
  final String? isProblemRectified;
  final String? isCurrentNutrientDeficiency;
  final int? nutrientId;
  final String? nutrient;
  final dynamic chemicalId;
  final dynamic chemical;
  final dynamic applyNutrientFrequencyTypeId;
  final dynamic applyFertilizerFrequency;
  final String? isResultSeen;
  final dynamic comments;
  final String? isActive;
  final DateTime? updatedDate;
  final DateTime? registeredDate;
  final int? dosage;
  final dynamic uomName;
  final dynamic recommendedFertilizer;
  final String? cropMaintenanceCode;

  NutrientDatum({
    this.plotCode,
    this.isPreviousNutrientDeficiency,
    this.isProblemRectified,
    this.isCurrentNutrientDeficiency,
    this.nutrientId,
    this.nutrient,
    this.chemicalId,
    this.chemical,
    this.applyNutrientFrequencyTypeId,
    this.applyFertilizerFrequency,
    this.isResultSeen,
    this.comments,
    this.isActive,
    this.updatedDate,
    this.registeredDate,
    this.dosage,
    this.uomName,
    this.recommendedFertilizer,
    this.cropMaintenanceCode,
  });

  factory NutrientDatum.fromJson(Map<String, dynamic> json) => NutrientDatum(
        plotCode: json["plotCode"],
        isPreviousNutrientDeficiency: json["isPreviousNutrientDeficiency"],
        isProblemRectified: json["isProblemRectified"],
        isCurrentNutrientDeficiency: json["isCurrentNutrientDeficiency"],
        nutrientId: json["nutrientId"],
        nutrient: json["nutrient"],
        chemicalId: json["chemicalId"],
        chemical: json["chemical"],
        applyNutrientFrequencyTypeId: json["applyNutrientFrequencyTypeId"],
        applyFertilizerFrequency: json["applyFertilizerFrequency"],
        isResultSeen: json["isResultSeen"],
        comments: json["comments"],
        isActive: json["isActive"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
        registeredDate: json["registeredDate"] == null
            ? null
            : DateTime.parse(json["registeredDate"]),
        dosage: json["dosage"],
        uomName: json["uomName"],
        recommendedFertilizer: json["recommendedFertilizer"],
        cropMaintenanceCode: json["cropMaintenanceCode"],
      );

  Map<String, dynamic> toJson() => {
        "plotCode": plotCode,
        "isPreviousNutrientDeficiency": isPreviousNutrientDeficiency,
        "isProblemRectified": isProblemRectified,
        "isCurrentNutrientDeficiency": isCurrentNutrientDeficiency,
        "nutrientId": nutrientId,
        "nutrient": nutrient,
        "chemicalId": chemicalId,
        "chemical": chemical,
        "applyNutrientFrequencyTypeId": applyNutrientFrequencyTypeId,
        "applyFertilizerFrequency": applyFertilizerFrequency,
        "isResultSeen": isResultSeen,
        "comments": comments,
        "isActive": isActive,
        "updatedDate": updatedDate?.toIso8601String(),
        "registeredDate": registeredDate?.toIso8601String(),
        "dosage": dosage,
        "uomName": uomName,
        "recommendedFertilizer": recommendedFertilizer,
        "cropMaintenanceCode": cropMaintenanceCode,
      };
}

class PestDatum {
  final String? plotCode;
  final int? pestId;
  final String? pest;
  final dynamic pestChemicals;
  final String? isResultSeen;
  final dynamic comments;
  final String? isActive;
  final DateTime? updatedDate;
  final int? dosage;
  final dynamic uomName;
  final dynamic recommendedChemical;
  final String? cropMaintenanceCode;

  PestDatum({
    this.plotCode,
    this.pestId,
    this.pest,
    this.pestChemicals,
    this.isResultSeen,
    this.comments,
    this.isActive,
    this.updatedDate,
    this.dosage,
    this.uomName,
    this.recommendedChemical,
    this.cropMaintenanceCode,
  });

  factory PestDatum.fromJson(Map<String, dynamic> json) => PestDatum(
        plotCode: json["plotCode"],
        pestId: json["pestId"],
        pest: json["pest"],
        pestChemicals: json["pestChemicals"],
        isResultSeen: json["isResultSeen"],
        comments: json["comments"],
        isActive: json["isActive"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
        dosage: json["dosage"],
        uomName: json["uomName"],
        recommendedChemical: json["recommendedChemical"],
        cropMaintenanceCode: json["cropMaintenanceCode"],
      );

  Map<String, dynamic> toJson() => {
        "plotCode": plotCode,
        "pestId": pestId,
        "pest": pest,
        "pestChemicals": pestChemicals,
        "isResultSeen": isResultSeen,
        "comments": comments,
        "isActive": isActive,
        "updatedDate": updatedDate?.toIso8601String(),
        "dosage": dosage,
        "uomName": uomName,
        "recommendedChemical": recommendedChemical,
        "cropMaintenanceCode": cropMaintenanceCode,
      };
}

class PlotIrrigation {
  final String? plotCode;
  final String? name;
  final int? irrigationTypeId;
  final String? irrigaationType;
  final String? updatedBy;
  final DateTime? updatedbyDate;

  PlotIrrigation({
    this.plotCode,
    this.name,
    this.irrigationTypeId,
    this.irrigaationType,
    this.updatedBy,
    this.updatedbyDate,
  });

  factory PlotIrrigation.fromJson(Map<String, dynamic> json) => PlotIrrigation(
        plotCode: json["plotCode"],
        name: json["name"],
        irrigationTypeId: json["irrigationTypeId"],
        irrigaationType: json["irrigaationType"],
        updatedBy: json["updatedBy"],
        updatedbyDate: json["updatedbyDate"] == null
            ? null
            : DateTime.parse(json["updatedbyDate"]),
      );

  Map<String, dynamic> toJson() => {
        "plotCode": plotCode,
        "name": name,
        "irrigationTypeId": irrigationTypeId,
        "irrigaationType": irrigaationType,
        "updatedBy": updatedBy,
        "updatedbyDate": updatedbyDate?.toIso8601String(),
      };
}

class UprootmentData {
  final String? plotCode;
  final int? seedsPlanted;
  final int? plamsCount;
  final String? isTreesMissing;
  final int? missingTreesCount;
  final dynamic reasonType;
  final dynamic reasonTypeId;
  final dynamic comments;
  final String? isActive;
  final DateTime? updatedDate;
  final int? expectedPlamsCount;
  final String? cropMaintenancecode;

  UprootmentData({
    this.plotCode,
    this.seedsPlanted,
    this.plamsCount,
    this.isTreesMissing,
    this.missingTreesCount,
    this.reasonType,
    this.reasonTypeId,
    this.comments,
    this.isActive,
    this.updatedDate,
    this.expectedPlamsCount,
    this.cropMaintenancecode,
  });

  factory UprootmentData.fromJson(Map<String, dynamic> json) => UprootmentData(
        plotCode: json["plotCode"],
        seedsPlanted: json["seedsPlanted"],
        plamsCount: json["plamsCount"],
        isTreesMissing: json["isTreesMissing"],
        missingTreesCount: json["missingTreesCount"],
        reasonType: json["reasonType"],
        reasonTypeId: json["reasonTypeId"],
        comments: json["comments"],
        isActive: json["isActive"],
        updatedDate: json["updatedDate"] == null
            ? null
            : DateTime.parse(json["updatedDate"]),
        expectedPlamsCount: json["expectedPlamsCount"],
        cropMaintenancecode: json["cropMaintenancecode"],
      );

  Map<String, dynamic> toJson() => {
        "plotCode": plotCode,
        "seedsPlanted": seedsPlanted,
        "plamsCount": plamsCount,
        "isTreesMissing": isTreesMissing,
        "missingTreesCount": missingTreesCount,
        "reasonType": reasonType,
        "reasonTypeId": reasonTypeId,
        "comments": comments,
        "isActive": isActive,
        "updatedDate": updatedDate?.toIso8601String(),
        "expectedPlamsCount": expectedPlamsCount,
        "cropMaintenancecode": cropMaintenancecode,
      };
}
