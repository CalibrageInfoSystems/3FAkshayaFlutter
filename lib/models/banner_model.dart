import 'dart:convert';

BannerModel bannerModelFromJson(String str) =>
    BannerModel.fromJson(json.decode(str));

String bannerModelToJson(BannerModel data) => json.encode(data.toJson());

class BannerModel {
  final int? id;
  final String? imageName;
  final String? description;
  final String? stateCode;
  final bool? isActive;

  BannerModel({
    this.id,
    this.imageName,
    this.description,
    this.stateCode,
    this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json["id"],
        imageName: json["imageName"],
        description: json["description"],
        stateCode: json["stateCode"],
        isActive: json["isActive"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "imageName": imageName,
        "description": description,
        "stateCode": stateCode,
        "isActive": isActive,
      };
}
