import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/helper/image_assets.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/services/chat_services/chat_list_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:car_service/utils/components/custom_refresh_indicator.dart';
import 'package:car_service/utils/components/empty_widget.dart';
import 'package:car_service/utils/components/scrolling_preloader.dart';
import 'package:car_service/view_models/chat_list_view_model/chat_list_view_model.dart';
import 'package:car_service/views/message_list_view/components/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/pusher_helper.dart';
import '../../services/profile_services/profile_info_service.dart';
import '../../view_models/conversation_view_model/conversation_view_model.dart';
import '../account_skeleton/account_skeleton.dart';
import '../conversation_view/conversation_view.dart';
import 'components/chat_list_skeleton.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final clm = ChatListViewModel.instance;
    return Scaffold(
      backgroundColor: context.color.accentContrastColor,
      appBar: AppBar(
        title: Text(LocalKeys.messages),
      ),
      body: Consumer<ProfileInfoService>(builder: (context, pi, child) {
        if (pi.profileInfoModel.userDetails == null) {
          return const AccountSkeleton();
        }
        return Consumer<ChatListService>(builder: (context, cl, child) {
          return CustomRefreshIndicator(
            onRefresh: () async {
              await cl.fetchChatList();
            },
            child: CustomFutureWidget(
              function: cl.shouldAutoFetch ? cl.fetchChatList() : null,
              shimmer: const ChatListSkeleton(),
              child: cl.chatListModel.chatList.isEmpty
                  ? EmptyWidget(
                      title: LocalKeys.noConversationFound,
                      differentImage: ImageAssets.emptyConversation,
                    )
                  : Scrollbar(
                      controller: clm.scrollController,
                      child: CustomScrollView(
                        controller: clm.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverList.separated(
                            itemBuilder: (context, index) {
                              final providerChat =
                                  cl.chatListModel.chatList[index];
                              return GestureDetector(
                                  onTap: () {
                                    ConversationViewModel.dispose;
                                    PusherHelper().connectToPusher(
                                      context,
                                      providerChat.clientId,
                                      providerChat.providerId,
                                    );
                                    ConversationViewModel
                                        .instance.messageController
                                        .clear();
                                    context.toNamed(ConversationView.routeName,
                                        arguments: [
                                          providerChat.providerId,
                                          providerChat.providerName,
                                          providerChat.providerImage,
                                          providerChat.clientId,
                                        ], then: () {
                                      PusherHelper().disConnect();
                                    });
                                  },
                                  child: ChatTile(chat: providerChat));
                            },
                            separatorBuilder: (context, index) => Padding(
                              padding: 24.paddingH,
                              child: Divider(
                                height: 2,
                                thickness: 2,
                                color: context.color.primaryBorderColor,
                              ),
                            ),
                            itemCount: cl.chatListModel.chatList.length,
                          ),
                          24.toHeight.toSliver,
                          if (cl.nextPage != null && !cl.nexLoadingFailed)
                            ScrollPreloader(loading: cl.nextPageLoading)
                                .toSliver,
                          24.toHeight.toSliver,
                        ],
                      ),
                    ),
            ),
          );
        });
      }),
    );
  }
}
