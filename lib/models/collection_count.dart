// To parse this JSON data, do
//
//     final collectionCount = collectionCountFromJson(jsonString);

import 'dart:convert';

CollectionCount collectionCountFromJson(String str) =>
    CollectionCount.fromJson(json.decode(str));

String collectionCountToJson(CollectionCount data) =>
    json.encode(data.toJson());

class CollectionCount {
  final double? collectionsWeight;
  final int? collectionsCount;
  final double? paidCollectionsWeight;
  final double? unPaidCollectionsWeight;

  CollectionCount({
    this.collectionsWeight,
    this.collectionsCount,
    this.paidCollectionsWeight,
    this.unPaidCollectionsWeight,
  });

  factory CollectionCount.fromJson(Map<String, dynamic> json) =>
      CollectionCount(
        collectionsWeight: json["collectionsWeight"]?.toDouble(),
        collectionsCount: json["collectionsCount"],
        paidCollectionsWeight: json["paidCollectionsWeight"]?.toDouble(),
        unPaidCollectionsWeight: json["unPaidCollectionsWeight"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "collectionsWeight": collectionsWeight,
        "collectionsCount": collectionsCount,
        "paidCollectionsWeight": paidCollectionsWeight,
        "unPaidCollectionsWeight": unPaidCollectionsWeight,
      };
}
