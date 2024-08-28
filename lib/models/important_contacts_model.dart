import 'dart:convert';

ImportantContacts importantContactsFromJson(String str) =>
    ImportantContacts.fromJson(json.decode(str));

String importantContactsToJson(ImportantContacts data) =>
    json.encode(data.toJson());

class ImportantContacts {
  final String? clusterOfficerName;
  final String? clusterOfficerContactNumber;
  final String? clusterOfficerManagerName;
  final String? clusterOfficerManagerContactNumber;
  final String? stateHeadName;

  ImportantContacts({
    this.clusterOfficerName,
    this.clusterOfficerContactNumber,
    this.clusterOfficerManagerName,
    this.clusterOfficerManagerContactNumber,
    this.stateHeadName,
  });

  factory ImportantContacts.fromJson(Map<String, dynamic> json) =>
      ImportantContacts(
        clusterOfficerName: json["clusterOfficerName"],
        clusterOfficerContactNumber: json["clusterOfficerContactNumber"],
        clusterOfficerManagerName: json["clusterOfficerManagerName"],
        clusterOfficerManagerContactNumber:
            json["clusterOfficerManagerContactNumber"],
        stateHeadName: json["stateHeadName"],
      );

  Map<String, dynamic> toJson() => {
        "clusterOfficerName": clusterOfficerName,
        "clusterOfficerContactNumber": clusterOfficerContactNumber,
        "clusterOfficerManagerName": clusterOfficerManagerName,
        "clusterOfficerManagerContactNumber":
            clusterOfficerManagerContactNumber,
        "stateHeadName": stateHeadName,
      };
}
