import 'package:car_service/helper/app_urls.dart';
import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/models/quote_models/quote_model.dart';
import 'package:car_service/data/network/network_api_services.dart';
import 'package:flutter/material.dart';

class QuoteService extends ChangeNotifier {
  final NetworkApiServices _apiService = NetworkApiServices();

  bool _loading = false;
  bool get loading => _loading;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  QuoteListModel _quoteList = QuoteListModel.empty();
  QuoteListModel get quoteList => _quoteList;

  QuoteModel? _quoteDetail;
  QuoteModel? get quoteDetail => _quoteDetail;

  // ── User Methods ────────────────────────────────────────────────────────────

  Future<bool> createQuoteRequest({
    required String title,
    required String description,
    required String type,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _apiService.postApi(
        {"title": title, "description": description, "type": type},
        AppUrls.quotesUrl,
        LocalKeys.supportTicket,
        headers: Map<String, String>.from(commonAuthHeader),
      );

      if (response != null && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error creating quote: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyQuotes({int page = 1}) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await _apiService.getApi(
        "${AppUrls.myQuotesUrl}?page=$page",
        LocalKeys.supportTicket,
        headers: Map<String, String>.from(commonAuthHeader),
      );
      if (response != null) {
        _quoteList = QuoteListModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } catch (e) {
      debugPrint("Error fetching my quotes: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Common/Admin/Franchise Methods ──────────────────────────────────────────

  Future<void> fetchQuoteDetails(int id) async {
    _isLoadingDetail = true;
    _quoteDetail = null;
    notifyListeners();

    try {
      final response = await _apiService.getApi(
        AppUrls.quoteUpdateUrl(id),
        LocalKeys.supportTicket,
        headers: Map<String, String>.from(commonAuthHeader),
      );
      if (response != null) {
        final data = response['data'] ?? response['quote'] ?? response;
        if (data is Map<String, dynamic>) {
           _quoteDetail = QuoteModel.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint("Error fetching quote details: $e");
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllQuotes({int page = 1, String? status}) async {
    _loading = true;
    notifyListeners();

    try {
      String url = "${AppUrls.adminQuotesUrl}?page=$page";
      if (status != null) url += "&status=$status";

      final response = await _apiService.getApi(
        url,
        LocalKeys.supportTicket,
        headers: acceptJsonAuthHeader,
      );
      if (response != null) {
        _quoteList = QuoteListModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      }
    } catch (e) {
      debugPrint("Error fetching all quotes: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuoteResponse({
    required int id,
    required String status,
    double? quotedPrice,
    String? adminNote,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {"status": status};
      if (quotedPrice != null) body["quoted_price"] = quotedPrice.toString();
      if (adminNote != null) body["admin_note"] = adminNote;

      final response = await _apiService.patchApi(
        body,
        AppUrls.quoteUpdateUrl(id),
        LocalKeys.supportTicket,
        headers: Map<String, String>.from(commonAuthHeader),
      );

      if (response != null && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error updating quote: $e");
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
