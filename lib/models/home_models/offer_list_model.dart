import 'dart:convert';

OfferListModel offerListModelFromJson(String str) =>
    OfferListModel.fromJson(json.decode(str));

String offerListModelToJson(OfferListModel data) => json.encode(data.toJson());

class OfferListModel {
  final List<Offer> offers;

  OfferListModel({
    required this.offers,
  });

  factory OfferListModel.fromJson(json) => OfferListModel(
        offers: json["offers"] == null
            ? []
            : List<Offer>.from(json["offers"]!.map((x) => Offer.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "offers": offers == null
            ? []
            : List<dynamic>.from(offers.map((x) => x.toJson())),
      };
}

class Offer {
  final dynamic id;
  final String? image;
  final String? title;
  final String? subTitle;
  final dynamic isPrimary;
  final dynamic status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expairesAt;

  Offer({
    this.id,
    this.image,
    this.title,
    this.subTitle,
    this.isPrimary,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.expairesAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        id: json["id"],
        image: json["image"],
        title: json["title"],
        subTitle: json["subTitle"],
        isPrimary: json["is_primary"],
        status: json["status"],
        createdAt: DateTime.tryParse(json["created_at"].toString()),
        updatedAt: DateTime.tryParse(json["updated_at"].toString()),
        expairesAt: DateTime.tryParse(json["expaires_at"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "title": title,
        "subTitle": subTitle,
        "is_primary": isPrimary,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "expaires_at":
            "${expairesAt!.year.toString().padLeft(4, '0')}-${expairesAt!.month.toString().padLeft(2, '0')}-${expairesAt!.day.toString().padLeft(2, '0')}",
      };
}
