class HomeProvidersModel {
  final dynamic id;
  final String name;
  final String? image;
  final num avgRating;
  final String? profession;
  final num? ratingCount;
  final num? completionRate;
  final bool isVerified;
  HomeProvidersModel({
    required this.name,
    this.image,
    required this.avgRating,
    required this.id,
    this.profession,
    this.ratingCount,
    this.completionRate,
    this.isVerified = false,
  });
}
