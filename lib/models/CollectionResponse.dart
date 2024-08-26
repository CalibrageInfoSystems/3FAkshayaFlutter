class Collection {
  final String uColnid;
  final String uFarcode;
  final String uPlotid;
  final String uApaystat;
  final String canceled;
  final String docStatus;
  final String docDate;
  final String whsCode;
  final String whsName;
  final double quantity;
  final int docEntry;
  final String updateDate;
  final String farmerName;
  final String? vehicalNumber;
  final String? driverName;

  Collection({
    required this.uColnid,
    required this.uFarcode,
    required this.uPlotid,
    required this.uApaystat,
    required this.canceled,
    required this.docStatus,
    required this.docDate,
    required this.whsCode,
    required this.whsName,
    required this.quantity,
    required this.docEntry,
    required this.updateDate,
    required this.farmerName,
    this.vehicalNumber,
    this.driverName,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      uColnid: json['u_colnid'],
      uFarcode: json['u_farcode'],
      uPlotid: json['u_plotid'],
      uApaystat: json['u_apaystat'],
      canceled: json['canceled'],
      docStatus: json['docStatus'],
      docDate: json['docDate'],
      whsCode: json['whsCode'],
      whsName: json['whsName'],
      quantity: (json['quantity'] as num).toDouble(),
      docEntry: json['docEntry'],
      updateDate: json['updateDate'],
      farmerName: json['farmerName'],
      vehicalNumber: json['vehicalNumber'],
      driverName: json['driverName'],
    );
  }
}

class CollectionCount {
  final double collectionsWeight;
  final int collectionsCount;
  final double paidCollectionsWeight;
  final double unPaidCollectionsWeight;

  CollectionCount({
    required this.collectionsWeight,
    required this.collectionsCount,
    required this.paidCollectionsWeight,
    required this.unPaidCollectionsWeight,
  });

  factory CollectionCount.fromJson(Map<String, dynamic> json) {
    return CollectionCount(
      collectionsWeight: (json['collectionsWeight'] as num).toDouble(),
      collectionsCount: json['collectionsCount'],
      paidCollectionsWeight: (json['paidCollectionsWeight'] as num).toDouble(),
      unPaidCollectionsWeight: (json['unPaidCollectionsWeight'] as num).toDouble(),
    );
  }
}

class CollectionResponse {
  final List<Collection> collectioData;
  final CollectionCount collectionCount;
  final bool isSuccess;
  final int affectedRecords;
  final String endUserMessage;
  final List<dynamic> validationErrors;

  CollectionResponse({
    required this.collectioData,
    required this.collectionCount,
    required this.isSuccess,
    required this.affectedRecords,
    required this.endUserMessage,
    required this.validationErrors,
  });

  factory CollectionResponse.fromJson(Map<String, dynamic> json) {
    return CollectionResponse(
      collectioData: (json['result']['collectioData'] as List)
          .map((item) => Collection.fromJson(item))
          .toList(),
      collectionCount: CollectionCount.fromJson(json['result']['collectionCount']),
      isSuccess: json['isSuccess'],
      affectedRecords: json['affectedRecords'],
      endUserMessage: json['endUserMessage'],
      validationErrors: json['validationErrors'],
    );
  }
}


