import 'dart:async';
import 'dart:io';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/services/support_services/ticket_conversation_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';

class TicketConversationViewModel {
  final ValueNotifier<File?> selectedFile = ValueNotifier(null);
  final ValueNotifier<bool> notifyEmail = ValueNotifier(false);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  // Timer for auto-refreshing messages
  Timer? refreshTimer;

  TicketConversationViewModel._init();
  static TicketConversationViewModel? _instance;
  static TicketConversationViewModel get instance {
    _instance ??= TicketConversationViewModel._init();
    return _instance!;
  }

  void startAutoRefresh(BuildContext context, dynamic ticketId) {
    refreshTimer?.cancel();
    refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final tcProvider = Provider.of<TicketConversationService>(
        context,
        listen: false,
      );
      // Fetch tickets without showing generic loading indicators
      tcProvider.fetchSingleTicketsSilently(context, ticketId);
    });
  }

  void cancelAutoRefresh() {
    refreshTimer?.cancel();
    refreshTimer = null;
  }

  TicketConversationViewModel._dispose();
  static bool get dispose {
    _instance?.cancelAutoRefresh();
    _instance = null;
    return true;
  }

  Future<void> fileSelector() async {
    try {
      FilePickerResult? file = await FilePicker.platform.pickFiles();
      if (file?.files.firstOrNull?.path == null) {
        return;
      }
      selectedFile.value = File(file!.files.first.path!);
      LocalKeys.fileSelected.showToast();
    } catch (error) {
      LocalKeys.fileSelectFailed.showToast();
    }
  }

  void trySendingMessage(BuildContext context) async {
    context.unFocus;
    final tcProvider = Provider.of<TicketConversationService>(
      context,
      listen: false,
    );

    final msg = messageController.text.trim();
    if (msg.isEmpty && selectedFile.value == null) {
      isLoading.value = false;
      tcProvider.setIsLoading(false);
      return;
    }

    isLoading.value = true;
    await tcProvider.sendMessage(
      context,
      tcProvider.ticketDetails!.id,
      message: msg.isEmpty ? " " : msg,
      notifyViaMail: notifyEmail.value,
      file: selectedFile.value,
    );
    messageController.clear();
    selectedFile.value = null;
    isLoading.value = false;
  }

  void tryToLoadMoreMessages(BuildContext context) {
    try {
      final tc = Provider.of<TicketConversationService>(context, listen: false);
      final nextPage = tc.nextPage;
      final nextPageLoading = tc.nextPageLoading;

      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (nextPage != null && !nextPageLoading) {
          tc.fetchOnlyMessages();
          return;
        }
      }
    } catch (e) {}
  }
}
