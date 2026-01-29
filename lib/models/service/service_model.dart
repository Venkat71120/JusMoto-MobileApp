class Service {
  final dynamic id;
  final String? title;
  final num price;
  final String? image;
  final num discountPrice;
  final String? providerName;
  final String? providerImage;
  final String? category;
  final bool isFavorite;
  final num avgRating;
  final String? unit;

  Service({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.discountPrice,
    required this.providerName,
    required this.providerImage,
    required this.category,
    required this.isFavorite,
    required this.avgRating,
    required this.unit,
  });
}
