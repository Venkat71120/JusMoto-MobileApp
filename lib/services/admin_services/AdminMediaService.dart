import 'dart:io';
import 'package:car_service/data/network/network_api_services.dart';
import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/models/admin_models/admin_media_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminMediaService extends ChangeNotifier {
  AdminMediaListModel _mediaList = AdminMediaListModel.empty();
  AdminMediaListModel get mediaList => _mediaList;

  bool _loading = false;
  bool get loading => _loading;

  bool _uploading = false;
  bool get uploading => _uploading;

  Future<void> fetchMedia({int page = 1, String? search}) async {
    _loading = true;
    notifyListeners();
    try {
      String url = '${AppUrls.adminMediaUrl}?page=$page&limit=30';
      if (search != null && search.isNotEmpty) url += '&search=$search';

      final response = await NetworkApiServices().getApi(url, "Admin Media List", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _mediaList = AdminMediaListModel.fromJson(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('❌ Error fetching media: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadMedia(File file) async {
    _uploading = true;
    notifyListeners();
    try {
      final request = http.MultipartRequest('POST', Uri.parse(AppUrls.adminMediaUploadUrl));
      request.headers.addAll(acceptJsonAuthHeader);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await NetworkApiServices().postWithFileApi(request, "Upload Media");
      if (response != null && response['success'] == true) {
        "File uploaded successfully".showToast();
        fetchMedia();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error uploading media: $e');
      return false;
    } finally {
      _uploading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedia(int id) async {
    try {
      final response = await NetworkApiServices().deleteApi('${AppUrls.adminMediaUrl}/$id', "Delete Media", headers: acceptJsonAuthHeader);
      if (response != null && response['success'] == true) {
        _mediaList.media.removeWhere((m) => m.id == id);
        notifyListeners();
        "File deleted".showToast();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting media: $e');
      return false;
    }
  }
}
