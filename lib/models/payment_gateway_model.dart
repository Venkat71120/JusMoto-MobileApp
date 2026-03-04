// To parse this JSON data, do
//
//     final paymentGatewayModel = paymentGatewayModelFromJson(jsonString);

import 'dart:convert';

import 'package:car_service/helper/extension/string_extension.dart';

PaymentGatewayModel paymentGatewayModelFromJson(String str) =>
    PaymentGatewayModel.fromJson(json.decode(str));

String paymentGatewayModelToJson(PaymentGatewayModel data) =>
    json.encode(data.toJson());

class PaymentGatewayModel {
  final List<Gateway> gateways;

  PaymentGatewayModel({
    required this.gateways,
  });

  factory PaymentGatewayModel.fromJson(Map json) => PaymentGatewayModel(
        gateways: json["data"] == null
            ? []
            : List<Gateway>.from(json["data"]!.map((x) => Gateway.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": gateways == null
            ? []
            : List<dynamic>.from(gateways.map((x) => x.toJson())),
      };
}

class Gateway {
  final int? id;
  final String? name;
  final String? image;
  final String? description;
  final dynamic status;
  final bool testMode;
  final Credentials? credentials;

  Gateway({
    this.id,
    this.name,
    this.image,
    this.description,
    this.status,
    required this.testMode,
    this.credentials,
  });

  factory Gateway.fromJson(Map<String, dynamic> json) => Gateway(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        description: json["description"],
        status: json["status"],
        testMode: json["test_mode"].toString().parseToBool,
        credentials: _parseCredentials(json["credentials"]),
      );

  static Credentials? _parseCredentials(dynamic raw) {
    if (raw == null || raw == "" || raw is String) return null;
    if (raw is Map<String, dynamic>) return Credentials.fromJson(raw);
    return null;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "description": description,
        "status": status,
        "test_mode": testMode,
      };
}
class Credentials {
  final String? sandboxClientId;
  final String? sandboxClientSecret;
  final String? sandboxAppId;
  final String? liveClientId;
  final String? liveClientSecret;
  final String? liveAppId;
  final String? merchantKey;
  final String? merchantMid;
  final String? merchantId;
  final String? merchantWebsite;
  final String? channel;
  final String? industryType;
  final String? publicKey;
  final String? secretKey;
  final String? apiKey;
  final String? apiSecret;
  final String? merchantEmail;
  final String? appId;
  final String? secretHash;
  final String? clientId;
  final String? clientSecret;
  final String? username;
  final String? password;
  final String? locationId;
  final String? accessToken;
  final String? apiKeyCinetpay;
  final String? siteId;
  final String? profileId;
  final String? region;
  final String? serverKey;
  final String? version;
  final String? xSignature;
  final String? collectionName;
  final String? categoryCode;
  final String? passphrase;
  final String? itnUrl;
  final String? name;
  final String? description;

  final String? brandId;

  final String? paymentKey;

  final String? clientKey;

  Credentials({
    this.sandboxClientId,
    this.sandboxClientSecret,
    this.sandboxAppId,
    this.liveClientId,
    this.liveClientSecret,
    this.liveAppId,
    this.merchantKey,
    this.merchantMid,
    this.merchantId,
    this.merchantWebsite,
    this.channel,
    this.industryType,
    this.publicKey,
    this.secretKey,
    this.apiKey,
    this.apiSecret,
    this.merchantEmail,
    this.appId,
    this.secretHash,
    this.clientId,
    this.clientSecret,
    this.username,
    this.password,
    this.locationId,
    this.accessToken,
    this.apiKeyCinetpay,
    this.siteId,
    this.profileId,
    this.region,
    this.serverKey,
    this.version,
    this.xSignature,
    this.collectionName,
    this.categoryCode,
    this.passphrase,
    this.itnUrl,
    this.name,
    this.description,
    this.brandId,
    this.paymentKey,
    this.clientKey,
  });

  factory Credentials.fromJson(Map<String, dynamic> json) {
    return Credentials(
      sandboxClientId: json['sandbox_client_id'] as String?,
      sandboxClientSecret: json['sandbox_client_secret'] as String?,
      sandboxAppId: json['sandbox_app_id'] as String?,
      liveClientId: json['live_client_id'] as String?,
      liveClientSecret: json['live_client_secret'] as String?,
      liveAppId: json['live_app_id'] as String?,
      merchantKey: json['merchant_key'] as String?,
      merchantMid: json['merchant_mid'] as String?,
      merchantId: json['merchant_id'] as String?,
      merchantWebsite: json['merchant_website'] as String?,
      channel: json['channel'] as String?,
      industryType: json['industry_type'] as String?,
      publicKey: json['public_key'] as String?,
      secretKey: json['secret_key'] as String?,
      paymentKey: json['key'] as String?,
      apiKey: json['api_key'] as String?,
      clientKey: json['client_key'] as String?,
      apiSecret: json['api_secret'] as String?,
      merchantEmail: json['merchant_email'] as String?,
      appId: json['app_id'] as String?,
      secretHash: json['secret_hash'] as String?,
      brandId: json['brand_id'] as String?,
      clientId: json['client_id'] as String?,
      clientSecret: json['client_secret'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      locationId: json['location_id'] as String?,
      accessToken: json['access_token'] as String?,
      apiKeyCinetpay: json['apiKey'] as String?,
      siteId: json['site_id'] as String?,
      profileId: json['profile_id'] as String?,
      region: json['region'] as String?,
      serverKey: json['server_key'] as String?,
      version: json['version'] as String?,
      xSignature: json['x_signature'] as String?,
      collectionName: json['collection_name'] as String?,
      categoryCode: json['category_code'] as String?,
      passphrase: json['passphrase'] as String?,
      itnUrl: json['itn_url'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
    );
  }
}
