import 'dart:convert';

import 'package:car_service/models/address_models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../customization.dart';
import '../models/google_place_details_model.dart';
import '../models/google_places_model.dart';

class GoogleLocationSearch with ChangeNotifier {
  List<Prediction> locations = [];
  bool isLoading = false;
  Prediction? geoLoc;

  String? dark;

  setIsLoading(value) {
    if (value == isLoading) {
      return;
    }
    isLoading = value;
    notifyListeners();
  }

  resetLocations() {
    locations = [];
  }

  fetchLocations({location, region}) async {
    try {
      locations = [];

      debugPrint(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$location&language=en&region=$region&key=$mapApiKey"
              .toString());
      var headers = {'Accept': 'application/json'};
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$location&language=en&region=$region&key=$mapApiKey'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      var responseString = await response.stream.bytesToString();
      print(responseString);
      if (response.statusCode == 200) {
        GooglePlacesModel responseData =
            googlePlacesModelFromJson(responseString);
        locations = responseData.predictions ?? [];
        print("location length is ${locations.length}");
      } else {
        print(response.reasonPhrase);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {}
    notifyListeners();
  }

  fetchGEOLocations({double? lat, double? lng}) async {
    try {
      if (geoLoc?.lat?.toStringAsFixed(5) == lat?.toStringAsFixed(5) &&
          geoLoc?.lng?.toStringAsFixed(5) == lng?.toStringAsFixed(5)) {
        debugPrint("same lat lng is ignoring fetching".toString());
        return;
      }
      debugPrint((geoLoc?.lat == lat && geoLoc?.lng == lng).toString());
      debugPrint(
          "(${geoLoc?.lat} == $lat && ${geoLoc?.lng} == $lng)".toString());
      debugPrint("same lat lng is not ignoring fetching".toString());
      locations = [];
      setIsLoading(true);
      debugPrint(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat, $lng&key=$mapApiKey'
              .toString());
      var headers = {'Accept': 'application/json'};
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat, $lng&key=$mapApiKey'));

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      var responseString = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var responseData = jsonDecode(responseString);
        debugPrint(responseData.toString());
        bool breakLoop = false;
        var postCode;
        var city;
        for (var i = 0; i < responseData['results'].length; i++) {
          var element = responseData["results"][i];
          element["address_components"].forEach((e) {
            if (e["types"].contains("postal_code")) {
              breakLoop = true;
              postCode = e["long_name"];
            }
            if (e["types"].contains("sublocality")) {
              breakLoop = true;
              city = e["long_name"];
            }
          });
          if (breakLoop) break;
        }
        geoLoc = Prediction(
          description: formatAddress(responseData["results"]?[0] ?? {}),
          placeId: responseData["results"]?[0]?['place_id'],
          postCode: postCode,
          city: city,
          lat: lat,
          lng: lng,
        );

        debugPrint((geoLoc?.lat).toString());
        debugPrint((geoLoc?.lng).toString());
      } else {
        print(response.reasonPhrase);
      }
    } finally {
      setIsLoading(false);
    }
  }

  Future<GooglePlaceDetailsModel?> fetchPlaceDetails(id) async {
    try {
      debugPrint("fetching place details $id".toString());
      locations = [];
      var headers = {'Accept': 'application/json'};

      var response = await http.get(
        Uri.parse(
            'https://maps.googleapis.com/maps/api/place/details/json?place_id=$id&key=$mapApiKey'),
        headers: headers,
      );

      debugPrint(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$id&key=$mapApiKey'
              .toString());
      if (response.statusCode == 200) {
        GooglePlaceDetailsModel responseData =
            GooglePlaceDetailsModel.fromJson(jsonDecode(response.body));
        setIsLoading(false);
        geoLoc = Prediction(
          description: responseData.result?.formattedAddress,
          lat: responseData.result?.geometry?.location?.lat,
          lng: responseData.result?.geometry?.location?.lng,
        );
        debugPrint(responseData.toString());
        return responseData;
      } else {
        print(response.reasonPhrase);
      }
    } finally {
      setIsLoading(false);
    }
    error(e) {
      debugPrint(e.toString());
    }

    return null;
  }

  String formatAddress(Map<String, dynamic> result) {
    String streetNumber = '';
    String route = '';
    String sublocality = '';
    String locality = '';
    String administrativeArea2 = '';
    String administrativeArea1 = '';
    String country = '';
    String postalCode = '';

    for (var component in result['address_components']) {
      List<String> types = List<String>.from(component['types']);

      if (types.contains('street_number')) {
        streetNumber = component['long_name'];
      } else if (types.contains('route')) {
        route = component['long_name'];
      } else if (types.contains('sublocality') ||
          types.contains('sublocality_level_1')) {
        sublocality = component['long_name'];
      } else if (types.contains('locality')) {
        locality = component['long_name'];
      } else if (types.contains('administrative_area_level_2')) {
        administrativeArea2 = component['long_name'];
      } else if (types.contains('administrative_area_level_1')) {
        administrativeArea1 = component['long_name'];
      } else if (types.contains('country')) {
        country = component['long_name'];
      } else if (types.contains('postal_code')) {
        postalCode = component['long_name'];
      }
    }

    List<String> addressComponents = [
      if (streetNumber.isNotEmpty) streetNumber,
      if (route.isNotEmpty) route,
      if (sublocality.isNotEmpty) sublocality,
      if (locality.isNotEmpty) locality,
      if (postalCode.isNotEmpty) postalCode,
      if (country.isNotEmpty) country,
    ];

    String address = addressComponents.join(', ').trim();

    return address;
  }

  setDark() async {
    dark = await rootBundle.loadString("assets/files/dark-map.json");
  }

  setFromAddress(Address address) async {
    geoLoc = Prediction(
      description: address.address,
      lat: address.latitude,
      lng: address.longitude,
    );
    notifyListeners();
  }
}
