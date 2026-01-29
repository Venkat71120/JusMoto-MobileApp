import 'dart:convert';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/custom_preloader.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;

import '../../utils/components/custom_squircle_widget.dart';

class TacPpView extends StatelessWidget {
  final String title;
  final String url;
  const TacPpView({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: 8.paddingV,
        child: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CustomPreloader();
            }
            return SquircleContainer(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                color: context.color.accentContrastColor,
                radius: 12,
                child: HtmlWidget(snapshot.data.toString()));
          },
        ),
      ),
    );
  }

  Future<String> getData() async {
    debugPrint(url);
    final response = await http.get(Uri.parse(url));
    String content = "";
    try {
      debugPrint(response.body.toString());
      final tempBody = jsonDecode(response.body);
      content = (tempBody["terms_and_conditions"] ??
          tempBody["contact_page"] ??
          tempBody["privacy_policy"])["page_content"];
    } catch (e) {}
    return content;
  }
}
