import 'dart:convert';

CategoryItem categoryItemFromJson(String str) =>
    CategoryItem.fromJson(json.decode(str));

String categoryItemToJson(CategoryItem data) => json.encode(data.toJson());

class CategoryItem {
  final int? categoryId;
  final String? name;
  final int? parentCategoryId;
  final String? description;

  CategoryItem({
    this.categoryId,
    this.name,
    this.parentCategoryId,
    this.description,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
        categoryId: json["categoryId"],
        name: json["name"],
        parentCategoryId: json["parentCategoryId"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "categoryId": categoryId,
        "name": name,
        "parentCategoryId": parentCategoryId,
        "description": description,
      };
}
