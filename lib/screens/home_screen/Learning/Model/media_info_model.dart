class MediaInfo {
  final int? id;
  final String? name;
  final String? description;
  final int? categoryId;
  final String? category;
  final String? teluguCategoryName;
  final String? hindiCategoryName;
  final int? fileTypeId;
  final String? fileType;
  final String? fileName;
  final String? fileLocation;
  final String? fileExtension;
  final bool? isActive;
  final int? createdByUserId;
  final String? createdDate;
  final int? updatedByUserId;
  final String? updatedDate;
  final String? fileUrl;
  final String? embedUrl;
  final String? stateCodes;

  MediaInfo({
    this.id,
    this.name,
    this.description,
    this.categoryId,
    this.category,
    this.teluguCategoryName,
    this.hindiCategoryName,
    this.fileTypeId,
    this.fileType,
    this.fileName,
    this.fileLocation,
    this.fileExtension,
    this.isActive,
    this.createdByUserId,
    this.createdDate,
    this.updatedByUserId,
    this.updatedDate,
    this.fileUrl,
    this.embedUrl,
    this.stateCodes,
  });

  factory MediaInfo.fromJson(Map<String, dynamic> json) => MediaInfo(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        categoryId: json["categoryId"],
        category: json["category"],
        teluguCategoryName: json["teluguCategoryName"],
        hindiCategoryName: json["hindiCategoryName"],
        fileTypeId: json["fileTypeId"],
        fileType: json["fileType"],
        fileName: json["fileName"],
        fileLocation: json["fileLocation"],
        fileExtension: json["fileExtension"],
        isActive: json["isActive"],
        createdByUserId: json["createdByUserId"],
        createdDate: json["createdDate"],
        updatedByUserId: json["updatedByUserId"],
        updatedDate: json["updatedDate"],
        fileUrl: json["fileUrl"],
        embedUrl: json["embedUrl"],
        stateCodes: json["stateCodes"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "categoryId": categoryId,
        "category": category,
        "teluguCategoryName": teluguCategoryName,
        "hindiCategoryName": hindiCategoryName,
        "fileTypeId": fileTypeId,
        "fileType": fileType,
        "fileName": fileName,
        "fileLocation": fileLocation,
        "fileExtension": fileExtension,
        "isActive": isActive,
        "createdByUserId": createdByUserId,
        "createdDate": createdDate,
        "updatedByUserId": updatedByUserId,
        "updatedDate": updatedDate,
        "fileUrl": fileUrl,
        "embedUrl": embedUrl,
        "stateCodes": stateCodes,
      };

  // Method to create a copy of the object with updated fields
  MediaInfo copyWith({
    int? id,
    String? name,
    String? description,
    int? categoryId,
    String? category,
    String? teluguCategoryName,
    String? hindiCategoryName,
    int? fileTypeId,
    String? fileType,
    String? fileName,
    String? fileLocation,
    String? fileExtension,
    bool? isActive,
    int? createdByUserId,
    String? createdDate,
    int? updatedByUserId,
    String? updatedDate,
    String? fileUrl,
    String? embedUrl,
    String? stateCodes,
  }) {
    return MediaInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      teluguCategoryName: teluguCategoryName ?? this.teluguCategoryName,
      hindiCategoryName: hindiCategoryName ?? this.hindiCategoryName,
      fileTypeId: fileTypeId ?? this.fileTypeId,
      fileType: fileType ?? this.fileType,
      fileName: fileName ?? this.fileName,
      fileLocation: fileLocation ?? this.fileLocation,
      fileExtension: fileExtension ?? this.fileExtension,
      isActive: isActive ?? this.isActive,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdDate: createdDate ?? this.createdDate,
      updatedByUserId: updatedByUserId ?? this.updatedByUserId,
      updatedDate: updatedDate ?? this.updatedDate,
      fileUrl: fileUrl ?? this.fileUrl,
      embedUrl: embedUrl ?? this.embedUrl,
      stateCodes: stateCodes ?? this.stateCodes,
    );
  }
}
