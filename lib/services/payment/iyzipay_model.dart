import 'dart:convert';

class PaymentRequest {
  String locale;
  String conversationId;
  double price;
  String basketId;
  String paymentGroup;
  Buyer buyer;
  Address shippingAddress;
  Address billingAddress;
  List<BasketItem> basketItems;
  List<int> enabledInstallments;
  String callbackUrl;
  String currency;
  double paidPrice;

  PaymentRequest({
    required this.locale,
    required this.conversationId,
    required this.price,
    required this.basketId,
    required this.paymentGroup,
    required this.buyer,
    required this.shippingAddress,
    required this.billingAddress,
    required this.basketItems,
    required this.enabledInstallments,
    required this.callbackUrl,
    required this.currency,
    required this.paidPrice,
  });

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'conversationId': conversationId,
      'price': price,
      'basketId': basketId,
      'paymentGroup': paymentGroup,
      'buyer': buyer.toJson(),
      'shippingAddress': shippingAddress.toJson(),
      'billingAddress': billingAddress.toJson(),
      'basketItems': basketItems.map((item) => item.toJson()).toList(),
      'callbackUrl': callbackUrl,
      'currency': currency,
      'paidPrice': paidPrice,
      'enabledInstallments': enabledInstallments,
    };
  }
}

class Buyer {
  String id;
  String name;
  String surname;
  String identityNumber;
  String email;
  String gsmNumber;
  String registrationDate;
  String lastLoginDate;
  String registrationAddress;
  String city;
  String country;
  String zipCode;
  String ip;

  Buyer({
    required this.id,
    required this.name,
    required this.surname,
    required this.identityNumber,
    required this.email,
    required this.gsmNumber,
    required this.registrationDate,
    required this.lastLoginDate,
    required this.registrationAddress,
    required this.city,
    required this.country,
    required this.zipCode,
    required this.ip,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'identityNumber': identityNumber,
      'email': email,
      'gsmNumber': gsmNumber,
      'registrationDate': registrationDate,
      'lastLoginDate': lastLoginDate,
      'registrationAddress': registrationAddress,
      'city': city,
      'country': country,
      'zipCode': zipCode,
      'ip': ip,
    };
  }
}

class Address {
  String address;
  String zipCode;
  String contactName;
  String city;
  String country;

  Address({
    required this.address,
    required this.zipCode,
    required this.contactName,
    required this.city,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'zipCode': zipCode,
      'contactName': contactName,
      'city': city,
      'country': country,
    };
  }
}

class BasketItem {
  String id;
  double price;
  String name;
  String category1;
  String category2;
  String itemType;

  BasketItem({
    required this.id,
    required this.price,
    required this.name,
    required this.category1,
    required this.category2,
    required this.itemType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'name': name,
      'category1': category1,
      'category2': category2,
      'itemType': itemType,
    };
  }
}

void main() {
  final paymentRequest = PaymentRequest(
    locale: 'tr',
    conversationId: '123456789',
    price: 1.0,
    basketId: 'B67832',
    paymentGroup: 'PRODUCT',
    buyer: Buyer(
      id: 'BY789',
      name: 'John',
      surname: 'Doe',
      identityNumber: '74300864791',
      email: 'email@email.com',
      gsmNumber: '+905350000000',
      registrationDate: '2013-04-21 15:12:09',
      lastLoginDate: '2015-10-05 12:43:35',
      registrationAddress: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
      city: 'Istanbul',
      country: 'Turkey',
      zipCode: '34732',
      ip: '85.34.78.112',
    ),
    shippingAddress: Address(
      address: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
      zipCode: '34742',
      contactName: 'Jane Doe',
      city: 'Istanbul',
      country: 'Turkey',
    ),
    billingAddress: Address(
      address: 'Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1',
      zipCode: '34742',
      contactName: 'Jane Doe',
      city: 'Istanbul',
      country: 'Turkey',
    ),
    basketItems: [
      BasketItem(
        id: 'BI101',
        price: 0.3,
        name: 'Binocular',
        category1: 'Collectibles',
        category2: 'Accessories',
        itemType: 'PHYSICAL',
      ),
      BasketItem(
        id: 'BI102',
        price: 0.5,
        name: 'Game code',
        category1: 'Game',
        category2: 'Online Game Items',
        itemType: 'VIRTUAL',
      ),
      BasketItem(
        id: 'BI103',
        price: 0.2,
        name: 'Usb',
        category1: 'Electronics',
        category2: 'Usb / Cable',
        itemType: 'PHYSICAL',
      ),
    ],
    enabledInstallments: [1, 2, 3, 6, 9],
    callbackUrl: 'https://www.merchant.com/callback',
    currency: 'TRY',
    paidPrice: 1.2,
  );

  final jsonString = jsonEncode(paymentRequest.toJson())
      .replaceAll('{', "[")
      .replaceAll('}', "]");
  print(jsonString);
}

const demo =
    "sandbox-wtyih1LNnlN1FtCei29rVjbZRKfqVeUC123456789sandbox-QsgXTUpizlCZzHaypMJwkL8YTMGsYMBM[locale=tr,conversationId=123456789,price=1.0,basketId=B67832,paymentGroup=PRODUCT,buyer=[id=BY789,name=John,surname=Doe,identityNumber=74300864791,email=email@email.com,gsmNumber=+905350000000,registrationDate=2013-04-21 15:12:09,lastLoginDate=2015-10-05 12:43:35,registrationAddress=Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1,city=Istanbul,country=Turkey,zipCode=34732,ip=85.34.78.112],shippingAddress=[address=Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1,zipCode=34742,contactName=Jane Doe,city=Istanbul,country=Turkey],billingAddress=[address=Nidakule Göztepe, Merdivenköy Mah. Bora Sok. No:1,zipCode=34742,contactName=Jane Doe,city=Istanbul,country=Turkey],basketItems=[[id=BI101,price=0.3,name=Binocular,category1=Collectibles,category2=Accessories,itemType=PHYSICAL], [id=BI102,price=0.5,name=Game code,category1=Game,category2=Online Game Items,itemType=VIRTUAL], [id=BI103,price=0.2,name=Usb,category1=Electronics,category2=Usb / Cable,itemType=PHYSICAL]],callbackUrl=https://www.merchant.com/callback,currency=TRY,paidPrice=1.2,enabledInstallments=[1, 2, 3, 6, 9]]";
