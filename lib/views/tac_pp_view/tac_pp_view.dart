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
    debugPrint("TacPpView URL: $url");
    try {
      final response = await http.get(Uri.parse(url));
      debugPrint("TacPpView Response: ${response.body}");
      if (response.statusCode == 200) {
        final tempBody = jsonDecode(response.body);
        if (tempBody["success"] == true && tempBody["data"] != null) {
          final data = tempBody["data"];
          // Handle new structure: {"success":true,"data":{"content":"..."}}
          if (data is Map && data.containsKey("content")) {
            return data["content"]?.toString() ?? "";
          }
          // Fallback to old structures if data is the map containing page_content
          if (data is Map && data.containsKey("page_content")) {
            return data["page_content"]?.toString() ?? "";
          }
        }
        
        // Final fallback for legacy formats
        final legacyContent = (tempBody["terms_and_conditions"] ??
            tempBody["contact_page"] ??
            tempBody["privacy_policy"]);
        if (legacyContent != null && legacyContent is Map) {
          return legacyContent["page_content"]?.toString() ?? "";
        }
      }
    } catch (e) {
      debugPrint("TacPpView Error: $e");
    }
    return "";
  }
}
