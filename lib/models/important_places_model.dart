import 'dart:convert';

ImportantPlaces importantPlacesFromJson(String str) =>
    ImportantPlaces.fromJson(json.decode(str));

String importantPlacesToJson(ImportantPlaces data) =>
    json.encode(data.toJson());

class ImportantPlaces {
  final List<CollectionCenter>? collectionCenters;
  final List<CollectionCenter>? mills;
  final List<Godown>? godowns;
  final List<Nursery>? nurseries;

  ImportantPlaces({
    this.collectionCenters,
    this.mills,
    this.godowns,
    this.nurseries,
  });

  factory ImportantPlaces.fromJson(Map<String, dynamic> json) =>
      ImportantPlaces(
        collectionCenters: json["collectionCenters"] == null
            ? []
            : List<CollectionCenter>.from(json["collectionCenters"]!
                .map((x) => CollectionCenter.fromJson(x))),
        mills: json["mills"] == null
            ? []
            : List<CollectionCenter>.from(
                json["mills"]!.map((x) => CollectionCenter.fromJson(x))),
        godowns: json["godowns"] == null
            ? []
            : List<Godown>.from(
                json["godowns"]!.map((x) => Godown.fromJson(x))),
        nurseries: json["nurseries"] == null
            ? []
            : List<Nursery>.from(
                json["nurseries"]!.map((x) => Nursery.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "collectionCenters": collectionCenters == null
            ? []
            : List<dynamic>.from(collectionCenters!.map((x) => x.toJson())),
        "mills": mills == null
            ? []
            : List<dynamic>.from(mills!.map((x) => x.toJson())),
        "godowns": godowns == null
            ? []
            : List<dynamic>.from(godowns!.map((x) => x.toJson())),
        "nurseries": nurseries == null
            ? []
            : List<dynamic>.from(nurseries!.map((x) => x.toJson())),
      };
}

class CollectionCenter {
  final int? id;
  final String? collectionCenter;
  final String? villageName;
  final String? mandalName;
  final String? districtName;
  final double? latitude;
  final double? longitude;
  final bool? isMill;

  CollectionCenter({
    this.id,
    this.collectionCenter,
    this.villageName,
    this.mandalName,
    this.districtName,
    this.latitude,
    this.longitude,
    this.isMill,
  });

  factory CollectionCenter.fromJson(Map<String, dynamic> json) =>
      CollectionCenter(
        id: json["id"],
        collectionCenter: json["collectionCenter"],
        villageName: json["villageName"],
        mandalName: json["mandalName"],
        districtName: json["districtName"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        isMill: json["isMill"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "collectionCenter": collectionCenter,
        "villageName": villageName,
        "mandalName": mandalName,
        "districtName": districtName,
        "latitude": latitude,
        "longitude": longitude,
        "isMill": isMill,
      };
}

class Godown {
  final String? godown;
  final String? location;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? code;
  final int? godownId;

  Godown({
    this.godown,
    this.location,
    this.address,
    this.latitude,
    this.longitude,
    this.code,
    this.godownId,
  });

  factory Godown.fromJson(Map<String, dynamic> json) => Godown(
        godown: json["godown"],
        location: json["location"],
        address: json["address"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        code: json["code"],
        godownId: json["godownId"],
      );

  Map<String, dynamic> toJson() => {
        "godown": godown,
        "location": location,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "code": code,
        "godownId": godownId,
      };
}

class Nursery {
  final String? nurseryCode;
  final String? nurseryName;
  final String? village;
  final String? mandal;
  final String? district;
  final dynamic latitude;
  final dynamic longitude;
  final int? nurseryId;

  Nursery({
    this.nurseryCode,
    this.nurseryName,
    this.village,
    this.mandal,
    this.district,
    this.latitude,
    this.longitude,
    this.nurseryId,
  });

  factory Nursery.fromJson(Map<String, dynamic> json) => Nursery(
        nurseryCode: json["nurseryCode"],
        nurseryName: json["nurseryName"],
        village: json["village"],
        mandal: json["mandal"],
        district: json["district"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        nurseryId: json["nurseryId"],
      );

  Map<String, dynamic> toJson() => {
        "nurseryCode": nurseryCode,
        "nurseryName": nurseryName,
        "village": village,
        "mandal": mandal,
        "district": district,
        "latitude": latitude,
        "longitude": longitude,
        "nurseryId": nurseryId,
      };
}
