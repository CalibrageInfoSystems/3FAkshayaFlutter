class ViewVisitMoreDetailsModel {
  final int? id;
  final String? requestCode;
  final String? fileName;
  final String? fileLocation;
  final String? fileExtension;
  final bool? isActive;
  final int? createdByUserId;
  final String? createdDate;
  final int? fileTypeId;

  ViewVisitMoreDetailsModel({
    this.id,
    this.requestCode,
    this.fileName,
    this.fileLocation,
    this.fileExtension,
    this.isActive,
    this.createdByUserId,
    this.createdDate,
    this.fileTypeId,
  });

  factory ViewVisitMoreDetailsModel.fromJson(Map<String, dynamic> json) =>
      ViewVisitMoreDetailsModel(
        id: json["id"],
        requestCode: json["requestCode"],
        fileName: json["fileName"],
        fileLocation: json["fileLocation"],
        fileExtension: json["fileExtension"],
        isActive: json["isActive"],
        createdByUserId: json["createdByUserId"],
        createdDate: json["createdDate"],
        fileTypeId: json["fileTypeId"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "requestCode": requestCode,
        "fileName": fileName,
        "fileLocation": fileLocation,
        "fileExtension": fileExtension,
        "isActive": isActive,
        "createdByUserId": createdByUserId,
        "createdDate": createdDate,
        "fileTypeId": fileTypeId,
      };
}
