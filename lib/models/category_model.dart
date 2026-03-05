import 'dart:convert';

import 'address_models/states_model.dart';

CategoryListModel addressListModelFromJson(String str) =>
    CategoryListModel.fromJson(json.decode(str));

String addressListModelToJson(CategoryListModel data) =>
    json.encode(data.toJson());

class CategoryListModel {
  final List<Category>? categories;
  final Pagination? pagination;

  CategoryListModel({this.categories, this.pagination});

  factory CategoryListModel.fromJson(json) => CategoryListModel(
    categories:
        json["categories"] == null
            ? []
            : List<Category>.from(
              json["categories"]!.map((x) => Category.fromJson(x)),
            ),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "categories":
        categories == null
            ? []
            : List<dynamic>.from(categories!.map((x) => x.toJson())),
  };
}

class Category {
  final dynamic id;
  final String? name;
  final String? slug;
  final String? icon;
  final dynamic description;
  final String? image;

  Category({
    this.id,
    this.name,
    this.slug,
    this.icon,
    this.description,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"]?.toString(),
    slug: json["slug"]?.toString(),
    icon: json["icon"]?.toString(),
    description: json["description"],
    image: json["image"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "icon": icon,
    "description": description,
    "image": image,
  };
}
