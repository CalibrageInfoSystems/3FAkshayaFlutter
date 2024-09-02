class yearlyresp {
  final String age;
  final String displayName;
  final int sortOrder;

  yearlyresp({
    required this.age,
    required this.displayName,
    required this.sortOrder,
  });

  factory yearlyresp.fromJson(Map<String, dynamic> json) {
    return yearlyresp(
      age: json['age'],
      displayName: json['displayName'],
      sortOrder: json['sortOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'displayName': displayName,
      'sortOrder': sortOrder,
    };
  }
}