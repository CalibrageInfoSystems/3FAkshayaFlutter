import 'dart:developer';

class BannerModel {
  final int id;
  final String imageName;
  final String? description;
  final String? stateCode;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.imageName,
    required this.description,
    required this.stateCode,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    inspect(json);
    return BannerModel(
      id: json['result']['BannerModel'][0]['id'],
      imageName: json['result']['BannerModel'][0]['imageName'],
      description: json['result']['BannerModel'][0]['description'],
      stateCode: json['result']['BannerModel'][0]['stateCode'],
      isActive: json['result']['BannerModel'][0]['isActive'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageName': imageName,
      'description': description,
      'stateCode': stateCode,
      'isActive': isActive,
    };
  }
}
