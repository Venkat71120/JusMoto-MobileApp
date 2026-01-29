import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/view_models/conversation_view_model/conversation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/utils/components/empty_spacer_helper.dart';
import '../../../models/conversation_model.dart';
import '../../../services/conversation_service.dart';
import '../../../services/profile_services/profile_info_service.dart';
import '../../../utils/components/scrolling_preloader.dart';
import 'chat_bubble.dart';

class ConversationMessageList extends StatelessWidget {
  final ConversationService cs;
  final clientImage;
  final name;
  const ConversationMessageList({
    super.key,
    required this.cs,
    required this.clientImage,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final piProvider = Provider.of<ProfileInfoService>(context, listen: false);
    final cm = ConversationViewModel.instance;
    cm.scrollController.addListener(() {
      cm.tryLoadingMore(context);
    });
    return (cs.conversationModel.allMessage?.length ?? 0) <= 0
        ? ListView()
        : ListView.separated(
            controller: cm.scrollController,
            padding: const EdgeInsets.all(20),
            reverse: true,
            itemBuilder: (context, index) {
              if ((cs.nextPage != null && !cs.nexLoadingFailed) &&
                  index == cs.conversationModel.allMessage!.length) {
                return ScrollPreloader(
                  loading: cs.nextPageLoading,
                  text: LocalKeys.pullDown,
                  iconData: Icons.arrow_circle_down_rounded,
                );
              }
              MessageModel? previousMessage;
              if (index != 0) {
                previousMessage = cs.conversationModel.allMessage![index - 1];
              }
              final datum = cs.conversationModel.allMessage![index];
              final bool senderFromWeb = datum.fromUser.toString() != "1";
              return ChatBubble(
                  datum: datum,
                  senderFromWeb: senderFromWeb,
                  clientImage: senderFromWeb
                      ? clientImage
                      : piProvider.profileInfoModel.userDetails?.image,
                  name: senderFromWeb
                      ? name
                      : piProvider.profileInfoModel.userDetails?.firstName,
                  index: index,
                  sameUser: previousMessage?.fromUser.toString() ==
                      datum.fromUser.toString());
            },
            separatorBuilder: (context, index) =>
                EmptySpaceHelper.emptyHeight(12),
            itemCount: cs.conversationModel.allMessage!.length +
                (cs.nextPage != null && !cs.nexLoadingFailed ? 1 : 0));
  }
}
