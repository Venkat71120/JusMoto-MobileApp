import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroService with ChangeNotifier {
  final introData = [
    {
      "title": "Welcome to JusMoto",
      "description":
          "Book expert handymen for any task—repairs, shifting, plumbing, and laundry. Experience reliable service and peace of mind.",
      "image": "assets/images/intro_1.png",
    },
    {
      "title": "Book from Services",
      "description":
          "Book yours from a wide range of services listed by the professional handyman service providers & get your things done!",
      "image": "assets/images/intro_2.png",
    },
    {
      "title": "Post Jobs",
      "description":
          "Didn’t find what you’re looking for? Have no worries! Post a job and hire best candidate from hundreds of handyman.",
      "image": "assets/images/intro_3.png",
    },
  ];
  int currentIndex = 0;

  void setIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  checkIntro() async {
    final sp = await SharedPreferences.getInstance();
    bool? intro = sp.getBool("intro");
    if (intro == null) {
      return true;
    }
    return false;
  }

  seeIntroValue() async {
    final sp = await SharedPreferences.getInstance();
    sp.setBool("intro", true);
  }

  fetchIntro(BuildContext context) {}
}
