import 'dart:io';

import 'package:car_service/app_static_values.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/conversation_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConversationViewModel {
  TextEditingController messageController = TextEditingController();
  ValueNotifier<File?> aFile = ValueNotifier(null);
  ValueNotifier<bool> loading = ValueNotifier(false);

  ScrollController scrollController = ScrollController();

  ConversationViewModel._init();
  static ConversationViewModel? _instance;
  static ConversationViewModel get instance {
    _instance ??= ConversationViewModel._init();
    return _instance!;
  }

  ConversationViewModel._dispose();
  static bool get dispose {
    _instance = null;
    return true;
  }

  void attachFile() async {
    if (aFile.value != null) {
      aFile.value = null;
      LocalKeys.fileRemoved.showToast();
      return;
    }
    final file = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: supportedFileTypesInC,
    );
    if (file == null && file!.files.isNotEmpty) {
      return;
    }
    aFile.value = File(file.files.first.path!);
    LocalKeys.fileSelected.showToast();
  }

  trySendingMessage(BuildContext context, clientId) async {
    context.unFocus;
    if (messageController.text.isEmpty && aFile.value == null) {
      LocalKeys.pleaseWriteMessageOrSelectAFile.showToast();
      return;
    }
    loading.value = true;

    final cProvider = Provider.of<ConversationService>(context, listen: false);
    await cProvider
        .trySendingMessage(messageController.text, aFile.value, clientId)
        .then((value) {
      if (value == true) {
        messageController.clear();
        aFile.value = null;
      }
    });
    loading.value = false;
  }

  initPusher(BuildContext context) async {}

  tryLoadingMore(BuildContext context) async {
    try {
      final cs = Provider.of<ConversationService>(context, listen: false);
      final nextPage = cs.nextPage;
      final nextPageLoading = cs.nextPageLoading;

      if (scrollController.offset ==
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (nextPage != null && !nextPageLoading) {
          cs.fetchNextPage();
          return;
        }
      }
    } catch (e) {}
  }
}
