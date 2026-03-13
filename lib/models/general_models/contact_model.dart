import 'dart:convert';

ContactModel contactModelFromJson(String str) =>
    ContactModel.fromJson(json.decode(str));

class ContactModel {
  final String? email;
  final String? phone;
  final String? whatsapp;
  final String? address;
  final Social? social;
  final List<ContactOutlet>? outlets;

  ContactModel({
    this.email,
    this.phone,
    this.whatsapp,
    this.address,
    this.social,
    this.outlets,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        email: json["email"],
        phone: json["phone"],
        whatsapp: json["whatsapp"],
        address: json["address"],
        social: json["social"] == null ? null : Social.fromJson(json["social"]),
        outlets: json["outlets"] == null
            ? []
            : List<ContactOutlet>.from(
                json["outlets"]!.map((x) => ContactOutlet.fromJson(x))),
      );
}

class ContactOutlet {
  final int? id;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? postCode;

  ContactOutlet({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.postCode,
  });

  factory ContactOutlet.fromJson(Map<String, dynamic> json) => ContactOutlet(
        id: json["id"],
        name: json["name"],
        address: json["address"],
        latitude: double.tryParse(json["latitude"].toString()),
        longitude: double.tryParse(json["longitude"].toString()),
        postCode: json["post_code"],
      );
}

class Social {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? youtube;

  Social({
    this.facebook,
    this.instagram,
    this.twitter,
    this.youtube,
  });

  factory Social.fromJson(Map<String, dynamic> json) => Social(
        facebook: json["facebook"],
        instagram: json["instagram"],
        twitter: json["twitter"],
        youtube: json["youtube"],
      );
}
