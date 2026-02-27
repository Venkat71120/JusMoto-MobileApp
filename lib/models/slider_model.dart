class SliderListModel {
  final List<HomeSliderModel>? sliders;

  SliderListModel({
    this.sliders,
  });

  factory SliderListModel.fromJson(Map json) => SliderListModel(
        sliders: json["data"] == null
            ? []
            : List<HomeSliderModel>.from(
                json["data"]!.map((x) => HomeSliderModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": sliders == null
            ? []
            : List<dynamic>.from(sliders!.map((x) => x.toJson())),
      };
}

class HomeSliderModel {
  final dynamic id;
  final String? image;
  final dynamic identity;
  final String? type;

  HomeSliderModel({
    this.id,
    this.image,
    this.identity,
    this.type,
  });

  factory HomeSliderModel.fromJson(Map<String, dynamic> json) =>
      HomeSliderModel(
        id: json["id"],
        identity: json["identity"],
        type: json["type"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "identity": identity,
        "type": type,
        "image": image,
      };
}