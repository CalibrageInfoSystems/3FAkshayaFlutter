
class CropData {
  final HealthPlantationData healthPlantationData;
  final List<NutrientData> nutrientData;
  final UprootmentData uprootmentData;
  final List<PestData> pestData;
  final List<dynamic> fertilizerRecommendationDetails;
  final List<DiseaseData> diseaseData;
  final List<PlotIrrigation> plotIrrigation;
  final double frequencyOfHarvest;

  CropData({
    required this.healthPlantationData,
    required this.nutrientData,
    required this.uprootmentData,
    required this.pestData,
    required this.fertilizerRecommendationDetails,
    required this.diseaseData,
    required this.plotIrrigation,
    required this.frequencyOfHarvest,
  });

  factory CropData.fromJson(Map<String, dynamic> json) {
    return CropData(
      healthPlantationData: HealthPlantationData.fromJson(json['healthPlantationData']),
      nutrientData: List<NutrientData>.from(json['nutrientData'].map((x) => NutrientData.fromJson(x))),
      uprootmentData: UprootmentData.fromJson(json['uprootmentData']),
      pestData: List<PestData>.from(json['pestData'].map((x) => PestData.fromJson(x))),
      fertilizerRecommendationDetails: List<dynamic>.from(json['fertilizerRecommendationDetails']),
      diseaseData: List<DiseaseData>.from(json['diseaseData'].map((x) => DiseaseData.fromJson(x))),
      plotIrrigation: List<PlotIrrigation>.from(json['plotIrrigation'].map((x) => PlotIrrigation.fromJson(x))),
      frequencyOfHarvest: json['frequencyOfHarvest'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'healthPlantationData': healthPlantationData.toJson(),
      'nutrientData': List<dynamic>.from(nutrientData.map((x) => x.toJson())),
      'uprootmentData': uprootmentData.toJson(),
      'pestData': List<dynamic>.from(pestData.map((x) => x.toJson())),
      'fertilizerRecommendationDetails': List<dynamic>.from(fertilizerRecommendationDetails.map((x) => x)),
      'diseaseData': List<dynamic>.from(diseaseData.map((x) => x.toJson())),
      'plotIrrigation': List<dynamic>.from(plotIrrigation.map((x) => x.toJson())),
      'frequencyOfHarvest': frequencyOfHarvest,
    };
  }
}

class HealthPlantationData {
  final String plotCode;
  final int plantationStateTypeId;
  final String plantationState;
  final int treesAppearanceTypeId;
  final String treesAppearance;
  final int treeGirthTypeId;
  final String treeGirth;
  final int treeHeightTypeId;
  final String treeHeight;
  final int? fruitColorTypeId;
  final String? fruitColor;
  final int? fruitSizeTypeId;
  final String? fruitSize;
  final int fruitHyegieneTypeId;
  final String fruitHyegiene;
  final int plantationTypeId;
  final String plantationType;
  final String plantationPictureLocation;
  final String isActive;
  final DateTime updatedDate;
  final String cropMaintenanceCode;

  HealthPlantationData({
    required this.plotCode,
    required this.plantationStateTypeId,
    required this.plantationState,
    required this.treesAppearanceTypeId,
    required this.treesAppearance,
    required this.treeGirthTypeId,
    required this.treeGirth,
    required this.treeHeightTypeId,
    required this.treeHeight,
    this.fruitColorTypeId,
    this.fruitColor,
    this.fruitSizeTypeId,
    this.fruitSize,
    required this.fruitHyegieneTypeId,
    required this.fruitHyegiene,
    required this.plantationTypeId,
    required this.plantationType,
    required this.plantationPictureLocation,
    required this.isActive,
    required this.updatedDate,
    required this.cropMaintenanceCode,
  });

  factory HealthPlantationData.fromJson(Map<String, dynamic> json) {
    return HealthPlantationData(
      plotCode: json['plotCode'],
      plantationStateTypeId: json['plantationStateTypeId'],
      plantationState: json['plantationState'],
      treesAppearanceTypeId: json['treesAppearanceTypeId'],
      treesAppearance: json['treesAppearance'],
      treeGirthTypeId: json['treeGirthTypeId'],
      treeGirth: json['treeGirth'],
      treeHeightTypeId: json['treeHeightTypeId'],
      treeHeight: json['treeHeight'],
      fruitColorTypeId: json['fruitColorTypeId'],
      fruitColor: json['fruitColor'],
      fruitSizeTypeId: json['fruitSizeTypeId'],
      fruitSize: json['fruitSize'],
      fruitHyegieneTypeId: json['fruitHyegieneTypeId'],
      fruitHyegiene: json['fruitHyegiene'],
      plantationTypeId: json['plantationTypeId'],
      plantationType: json['plantationType'],
      plantationPictureLocation: json['plantationPictureLocation'],
      isActive: json['isActive'],
      updatedDate: DateTime.parse(json['updatedDate']),
      cropMaintenanceCode: json['cropMaintenanceCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plotCode': plotCode,
      'plantationStateTypeId': plantationStateTypeId,
      'plantationState': plantationState,
      'treesAppearanceTypeId': treesAppearanceTypeId,
      'treesAppearance': treesAppearance,
      'treeGirthTypeId': treeGirthTypeId,
      'treeGirth': treeGirth,
      'treeHeightTypeId': treeHeightTypeId,
      'treeHeight': treeHeight,
      'fruitColorTypeId': fruitColorTypeId,
      'fruitColor': fruitColor,
      'fruitSizeTypeId': fruitSizeTypeId,
      'fruitSize': fruitSize,
      'fruitHyegieneTypeId': fruitHyegieneTypeId,
      'fruitHyegiene': fruitHyegiene,
      'plantationTypeId': plantationTypeId,
      'plantationType': plantationType,
      'plantationPictureLocation': plantationPictureLocation,
      'isActive': isActive,
      'updatedDate': updatedDate.toIso8601String(),
      'cropMaintenanceCode': cropMaintenanceCode,
    };
  }
}

class NutrientData {
  final String plotCode;
  final String isPreviousNutrientDeficiency;
  final String isProblemRectified;
  final String isCurrentNutrientDeficiency;
  final int nutrientId;
  final String nutrient;
  final int? chemicalId;
  final String? chemical;
  final int? applyNutrientFrequencyTypeId;
  final String? applyFertilizerFrequency;
  final String isResultSeen;
  final String? comments;
  final String isActive;
  final DateTime updatedDate;
  final DateTime registeredDate;
  final double dosage;
  final String? uomName;
  final String? recommendedFertilizer;
  final String cropMaintenanceCode;

  NutrientData({
    required this.plotCode,
    required this.isPreviousNutrientDeficiency,
    required this.isProblemRectified,
    required this.isCurrentNutrientDeficiency,
    required this.nutrientId,
    required this.nutrient,
    this.chemicalId,
    this.chemical,
    this.applyNutrientFrequencyTypeId,
    this.applyFertilizerFrequency,
    required this.isResultSeen,
    this.comments,
    required this.isActive,
    required this.updatedDate,
    required this.registeredDate,
    required this.dosage,
    this.uomName,
    this.recommendedFertilizer,
    required this.cropMaintenanceCode,
  });

  factory NutrientData.fromJson(Map<String, dynamic> json) {
    return NutrientData(
      plotCode: json['plotCode'],
      isPreviousNutrientDeficiency: json['isPreviousNutrientDeficiency'],
      isProblemRectified: json['isProblemRectified'],
      isCurrentNutrientDeficiency: json['isCurrentNutrientDeficiency'],
      nutrientId: json['nutrientId'],
      nutrient: json['nutrient'],
      chemicalId: json['chemicalId'],
      chemical: json['chemical'],
      applyNutrientFrequencyTypeId: json['applyNutrientFrequencyTypeId'],
      applyFertilizerFrequency: json['applyFertilizerFrequency'],
      isResultSeen: json['isResultSeen'],
      comments: json['comments'],
      isActive: json['isActive'],
      updatedDate: DateTime.parse(json['updatedDate']),
      registeredDate: DateTime.parse(json['registeredDate']),
      dosage: json['dosage'].toDouble(),
      uomName: json['uomName'],
      recommendedFertilizer: json['recommendedFertilizer'],
      cropMaintenanceCode: json['cropMaintenanceCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plotCode': plotCode,
      'isPreviousNutrientDeficiency': isPreviousNutrientDeficiency,
      'isProblemRectified': isProblemRectified,
      'isCurrentNutrientDeficiency': isCurrentNutrientDeficiency,
      'nutrientId': nutrientId,
      'nutrient': nutrient,
      'chemicalId': chemicalId,
      'chemical': chemical,
      'applyNutrientFrequencyTypeId': applyNutrientFrequencyTypeId,
      'applyFertilizerFrequency': applyFertilizerFrequency,
      'isResultSeen': isResultSeen,
      'comments': comments,
      'isActive': isActive,
      'updatedDate': updatedDate.toIso8601String(),
      'registeredDate': registeredDate.toIso8601String(),
      'dosage': dosage,
      'uomName': uomName,
      'recommendedFertilizer': recommendedFertilizer,
      'cropMaintenanceCode': cropMaintenanceCode,
    };
  }
}

class UprootmentData {
  final String plotCode;
  final int seedsPlanted;
  final int plamsCount;
  final String isTreesMissing;
  final int missingTreesCount;
  final String reasonType;
  final int reasonTypeId;
  final String comments;
  final String isActive;
  final DateTime updatedDate;
  final int expectedPlamsCount;
  final String cropMaintenanceCode;

  UprootmentData({
    required this.plotCode,
    required this.seedsPlanted,
    required this.plamsCount,
    required this.isTreesMissing,
    required this.missingTreesCount,
    required this.reasonType,
    required this.reasonTypeId,
    required this.comments,
    required this.isActive,
    required this.updatedDate,
    required this.expectedPlamsCount,
    required this.cropMaintenanceCode,
  });

  factory UprootmentData.fromJson(Map<String, dynamic> json) {
    return UprootmentData(
      plotCode: json['plotCode'],
      seedsPlanted: json['seedsPlanted'],
      plamsCount: json['plamsCount'],
      isTreesMissing: json['isTreesMissing'],
      missingTreesCount: json['missingTreesCount'],
      reasonType: json['reasonType'],
      reasonTypeId: json['reasonTypeId'],
      comments: json['comments'],
      isActive: json['isActive'],
      updatedDate: DateTime.parse(json['updatedDate']),
      expectedPlamsCount: json['expectedPlamsCount'],
      cropMaintenanceCode: json['cropMaintenancecode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plotCode': plotCode,
      'seedsPlanted': seedsPlanted,
      'plamsCount': plamsCount,
      'isTreesMissing': isTreesMissing,
      'missingTreesCount': missingTreesCount,
      'reasonType': reasonType,
      'reasonTypeId': reasonTypeId,
      'comments': comments,
      'isActive': isActive,
      'updatedDate': updatedDate.toIso8601String(),
      'expectedPlamsCount': expectedPlamsCount,
      'cropMaintenancecode': cropMaintenanceCode,
    };
  }
}

class PestData {
  final String plotCode;
  final int pestId;
  final String pest;
  final String? pestChemicals;
  final String isResultSeen;
  final String? comments;
  final String isActive;
  final DateTime updatedDate;
  final double dosage;
  final String? uomName;
  final String? recommendedChemical;
  final String cropMaintenanceCode;

  PestData({
    required this.plotCode,
    required this.pestId,
    required this.pest,
    this.pestChemicals,
    required this.isResultSeen,
    this.comments,
    required this.isActive,
    required this.updatedDate,
    required this.dosage,
    this.uomName,
    this.recommendedChemical,
    required this.cropMaintenanceCode,
  });

  factory PestData.fromJson(Map<String, dynamic> json) {
    return PestData(
      plotCode: json['plotCode'],
      pestId: json['pestId'],
      pest: json['pest'],
      pestChemicals: json['pestChemicals'],
      isResultSeen: json['isResultSeen'],
      comments: json['comments'],
      isActive: json['isActive'],
      updatedDate: DateTime.parse(json['updatedDate']),
      dosage: json['dosage'].toDouble(),
      uomName: json['uomName'],
      recommendedChemical: json['recommendedChemical'],
      cropMaintenanceCode: json['cropMaintenanceCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plotCode': plotCode,
      'pestId': pestId,
      'pest': pest,
      'pestChemicals': pestChemicals,
      'isResultSeen': isResultSeen,
      'comments': comments,
      'isActive': isActive,
      'updatedDate': updatedDate.toIso8601String(),
      'dosage': dosage,
      'uomName': uomName,
      'recommendedChemical': recommendedChemical,
      'cropMaintenanceCode': cropMaintenanceCode,
    };
  }
}

class DiseaseData {
  final String plotCode;
  final String isDiseaseNoticedinPreviousVisit;
  final String isProblemRectified;
  final String? problemRectifiedComments;
  final String disease;
  final int diseaseId;
  final String? chemical;
  final int? chemicalId;
  final String isResultSeen;
  final String? comments;
  final String isActive;
  final DateTime updatedDate;
  final double dosage;
  final String? uomName;
  final String? recommendedChemical;
  final String cropMaintenanceCode;

  DiseaseData({
    required this.plotCode,
    required this.isDiseaseNoticedinPreviousVisit,
    required this.isProblemRectified,
    this.problemRectifiedComments,
    required this.disease,
    required this.diseaseId,
    this.chemical,
    this.chemicalId,
    required this.isResultSeen,
    this.comments,
    required this.isActive,
    required this.updatedDate,
    required this.dosage,
    this.uomName,
    this.recommendedChemical,
    required this.cropMaintenanceCode,
  });

  factory DiseaseData.fromJson(Map<String, dynamic> json) {
    return DiseaseData(
      plotCode: json['plotCode'],
      isDiseaseNoticedinPreviousVisit: json['isDiseaseNoticedinPreviousVisit'],
      isProblemRectified: json['isProblemRectified'],
      problemRectifiedComments: json['problemRectifiedComments'],
      disease: json['disease'],
      diseaseId: json['diseaseId'],
      chemical: json['chemical'],
      chemicalId: json['chemicalId'],
      isResultSeen: json['isResultSeen'],
      comments: json['comments'],
      isActive: json['isActive'],
      updatedDate: DateTime.parse(json['updatedDate']),
      dosage: json['dosage'].toDouble(),
      uomName: json['uomName'],
      recommendedChemical: json['recommendedChemical'],
      cropMaintenanceCode: json['cropMaintenanceCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plotCode': plotCode,
      'isDiseaseNoticedinPreviousVisit': isDiseaseNoticedinPreviousVisit,
      'isProblemRectified': isProblemRectified,
      'problemRectifiedComments': problemRectifiedComments,
      'disease': disease,
      'diseaseId': diseaseId,
      'chemical': chemical,
      'chemicalId': chemicalId,
      'isResultSeen': isResultSeen,
      'comments': comments,
      'isActive': isActive,
      'updatedDate': updatedDate.toIso8601String(),
      'dosage': dosage,
      'uomName': uomName,
      'recommendedChemical': recommendedChemical,
      'cropMaintenanceCode': cropMaintenanceCode,
    };
  }
}

class PlotIrrigation {
  final String plotCode;
  final String name;
  final int irrigationTypeId;
  final String irrigaationType;
  final String updatedBy;
  final DateTime updatedbyDate;

  PlotIrrigation({
    required this.plotCode,
    required this.name,
    required this.irrigationTypeId,
    required this.irrigaationType,
    required this.updatedBy,
    required this.updatedbyDate,
  });

  factory PlotIrrigation.fromJson(Map<String, dynamic> json) {
    return PlotIrrigation(
      plotCode: json['plotCode'],
      name: json['name'],
      irrigationTypeId: json['irrigationTypeId'],
      irrigaationType: json['irrigaationType'],
      updatedBy: json['updatedBy'],
      updatedbyDate: DateTime.parse(json['updatedbyDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plotCode': plotCode,
      'name': name,
      'irrigationTypeId': irrigationTypeId,
      'irrigaationType': irrigaationType,
      'updatedBy': updatedBy,
      'updatedbyDate': updatedbyDate.toIso8601String(),
    };
  }
}
