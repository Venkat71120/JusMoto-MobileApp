import 'dart:convert';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_preloader.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../customizations/colors.dart';
import '../../helper/app_urls.dart';
import '../../models/general_models/contact_model.dart';
import '../../utils/components/custom_squircle_widget.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const NavigationPopIcon(),
        title: Text(LocalKeys.contact),
      ),
      body: FutureBuilder<ContactModel?>(
        future: getContactData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CustomPreloader();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(child: Text(LocalKeys.oops));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContactInfo(context, data),
                24.toHeight,
                if (data.social != null) _buildSocialLinks(context, data.social!),
                if (data.outlets != null && data.outlets!.isNotEmpty) ...[
                  24.toHeight,
                  Text(
                    'Our Outlets',
                    style: context.titleMedium?.bold,
                  ),
                  12.toHeight,
                  ...data.outlets!.map((outlet) => _buildOutletCard(context, outlet)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<ContactModel?> getContactData() async {
    try {
      final response = await http.get(Uri.parse(AppUrls.contact));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return ContactModel.fromJson(jsonResponse['data']);
        }
      }
    } catch (e) {
      debugPrint("ContactView Error: $e");
    }
    return null;
  }

  Widget _buildContactInfo(BuildContext context, ContactModel data) {
    return SquircleContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: context.color.accentContrastColor,
      radius: 12,
      child: Column(
        children: [
          if (data.email != null && data.email!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: Icons.email_outlined,
              title: LocalKeys.email,
              value: data.email!,
              onTap: () => _launchUrl('mailto:${data.email}'),
            ),
          if (data.phone != null && data.phone!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: Icons.phone_outlined,
              title: LocalKeys.phone,
              value: data.phone!,
              onTap: () => _launchUrl('tel:${data.phone}'),
            ),
          if (data.whatsapp != null && data.whatsapp!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: Icons.chat_outlined,
              title: 'WhatsApp',
              value: data.whatsapp!,
              onTap: () => _launchUrl('https://wa.me/${data.whatsapp}'),
            ),
          if (data.address != null && data.address!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: Icons.location_on_outlined,
              title: LocalKeys.address,
              value: data.address!,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            16.toWidth,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.bodySmall),
                  Text(value, style: context.bodyMedium?.bold),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context, Social social) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        if (social.facebook != null && social.facebook!.isNotEmpty)
          _buildSocialIcon(context, FontAwesomeIcons.facebook, social.facebook!),
        if (social.instagram != null && social.instagram!.isNotEmpty)
           _buildSocialIcon(context, FontAwesomeIcons.instagram, social.instagram!),
        if (social.twitter != null && social.twitter!.isNotEmpty)
          _buildSocialIcon(context, FontAwesomeIcons.xTwitter, social.twitter!),
        if (social.youtube != null && social.youtube!.isNotEmpty)
          _buildSocialIcon(context, FontAwesomeIcons.youtube, social.youtube!),
      ],
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.color.accentContrastColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: primaryColor),
      ),
    );
  }

  Widget _buildOutletCard(BuildContext context, ContactOutlet outlet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SquircleContainer(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: context.color.accentContrastColor,
        radius: 12,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(outlet.name ?? '', style: context.bodyLarge?.bold),
                  4.toHeight,
                  Text(outlet.address ?? '', style: context.bodyMedium),
                  if (outlet.postCode != null)
                    Text(outlet.postCode!, style: context.bodySmall),
                ],
              ),
            ),
            if (outlet.latitude != null && outlet.longitude != null)
              IconButton(
                icon: Icon(Icons.directions_outlined, color: primaryColor),
                onPressed: () {
                   _launchUrl('https://www.google.com/maps/search/?api=1&query=${outlet.latitude},${outlet.longitude}');
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
