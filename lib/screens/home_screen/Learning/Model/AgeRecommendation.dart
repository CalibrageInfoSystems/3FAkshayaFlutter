class AgeRecommendation {
  final String age;
  final String displayName;
  final int sortOrder;

  AgeRecommendation({required this.age, required this.displayName, required this.sortOrder});

  factory AgeRecommendation.fromJson(Map<String, dynamic> json) {
    return AgeRecommendation(
      age: json['age'],
      displayName: json['displayName'],
      sortOrder: json['sortOrder'],
    );
  }
}
