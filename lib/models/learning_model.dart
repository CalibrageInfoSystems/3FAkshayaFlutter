class LearningModel {
  final int id;
  final String name;
  final String teluguName;
  final String hindiName;
  final String? kannadaName;
  final String remarks;
  final bool isActive;
  final int createdByUserId;
  final String createdBy;
  final String createdDate;
  final int updatedByUserId;
  final String updatedBy;
  final String updatedDate;

  LearningModel({
    required this.id,
    required this.name,
    required this.teluguName,
    required this.hindiName,
    required this.kannadaName,
    required this.remarks,
    required this.isActive,
    required this.createdByUserId,
    required this.createdBy,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedBy,
    required this.updatedDate,
  });

  factory LearningModel.fromJson(Map<String, dynamic> json) {
    return LearningModel(
      id: json['id'],
      name: json['name'],
      teluguName: json['teluguName'],
      hindiName: json['hindiName'],
      kannadaName: json['kannadaName'],
      remarks: json['remarks'],
      isActive: json['isActive'],
      createdByUserId: json['createdByUserId'],
      createdBy: json['createdBy'],
      createdDate: json['createdDate'],
      updatedByUserId: json['updatedByUserId'],
      updatedBy: json['updatedBy'],
      updatedDate: json['updatedDate'],
    );
  }
}
