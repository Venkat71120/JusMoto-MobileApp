import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/ticket_conversation_view_model/ticket_conversation_view_model.dart';
import 'package:car_service/views/ticket_conversation_view/components/ticket_chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../services/support_services/ticket_conversation_service.dart';
import '../../utils/components/custom_preloader.dart';

class TicketConversationView extends StatelessWidget {
  final String title;
  final dynamic id;
  final String? status;
  const TicketConversationView({
    required this.title,
    required this.id,
    this.status,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tcm = TicketConversationViewModel.instance;
    // Start auto-refreshing messages when the view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tcm.startAutoRefresh(context, id);
    });

    return Consumer<TicketConversationService>(
      builder: (context, tcProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            tcm.cancelAutoRefresh();
            tcProvider.clearAllMessages();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              foregroundColor: context.color.primaryContrastColor,
              centerTitle: true,
              title: RichText(
                softWrap: true,
                text: TextSpan(
                  text: '#$id',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                  children: [
                    TextSpan(
                      text: ' $title',
                      style: TextStyle(
                        color: context.color.primaryContrastColor,
                      ),
                    ),
                  ],
                ),
              ),
              leading: NavigationPopIcon(
                onTap: () {
                  tcm.cancelAutoRefresh();
                  tcProvider.clearAllMessages();
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: WillPopScope(
              onWillPop: () async {
                tcm.cancelAutoRefresh();
                tcProvider.clearAllMessages();
                Navigator.of(context).pop();
                return true;
              },
              child: Consumer<TicketConversationService>(
                builder: (context, tcProvider, child) {
                  final isClosed = status == "close" || status == "closed";
                  return Column(
                    children: [
                      Expanded(child: messageListView(context, tcProvider)),
                      if (isClosed)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                          decoration: BoxDecoration(
                            color: context.color.accentContrastColor,
                          ),
                          child: Text(
                            "This ticket is closed. You can no longer send messages.",
                            textAlign: TextAlign.center,
                            style: context.bodySmall?.copyWith(
                              color: context.color.tertiaryContrastColo,
                            ),
                          ),
                        )
                      else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: context.color.accentContrastColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Image Preview ───────────────────────────
                              ValueListenableBuilder(
                                valueListenable: tcm.selectedFile,
                                builder: (context, file, _) {
                                  if (file == null) return const SizedBox();
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(
                                            file,
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: GestureDetector(
                                            onTap: () => tcm.selectedFile.value = null,
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.close_rounded,
                                                  size: 14, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              
                              // ── Input Row ──────────────────────────────
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_photo_alternate_outlined,
                                        color: Colors.grey, size: 24),
                                    onPressed: () => tcm.fileSelector(context),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  8.toWidth,
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: context.color.backgroundColor.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: context.color.primaryBorderColor.withOpacity(0.5),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: tcm.messageController,
                                        maxLines: 5,
                                        minLines: 1,
                                        style: context.bodySmall,
                                        decoration: InputDecoration(
                                          hintText: LocalKeys.writeMessage,
                                          hintStyle: TextStyle(
                                            color: context.color.tertiaryContrastColo.withOpacity(0.5),
                                            fontSize: 14,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        onChanged: (value) => tcProvider.setMessage(value),
                                      ),
                                    ),
                                  ),
                                  8.toWidth,
                                  ValueListenableBuilder(
                                    valueListenable: tcm.isLoading,
                                    builder: (context, loading, _) {
                                      if (loading) {
                                        return const Padding(
                                          padding: EdgeInsets.all(10),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      }
                                      return IconButton(
                                        icon: const Icon(Icons.send_rounded,
                                            color: primaryColor, size: 24),
                                        onPressed: () => tcm.trySendingMessage(context),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              
                              // ── Extras ──────────────────────────────────
                              ValueListenableBuilder(
                                valueListenable: tcm.notifyEmail,
                                builder: (context, notify, _) {
                                  return Row(
                                    children: [
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Checkbox(
                                          value: notify,
                                          activeColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(4)),
                                          onChanged: (val) => tcm.notifyEmail.value = val ?? false,
                                        ),
                                      ),
                                      Text(
                                        LocalKeys.notifyViaMail,
                                        style: TextStyle(
                                          color: context.color.tertiaryContrastColo,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget messageListView(
    BuildContext context,
    TicketConversationService tcProvider,
  ) {
    final tcm = TicketConversationViewModel.instance;
    tcm.scrollController.addListener(() {
      tcm.tryToLoadMoreMessages(context);
    });
    if (tcProvider.ticketDetails == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: CustomPreloader())],
      );
    } else if (tcProvider.messagesList.isEmpty) {
      return Center(
        child: Text(
          LocalKeys.noMessageFound,
          style: TextStyle(color: context.color.tertiaryContrastColo),
        ),
      );
    } else {
      return ListView.separated(
        controller: tcm.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        reverse: true,
        itemCount:
            tcProvider.messagesList.length +
            (!tcProvider.noMoreMessages ? 1 : 0),
        itemBuilder: ((context, index) {
          if (tcProvider.messagesList.length == index) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: CustomPreloader(),
            );
          }
          final element = tcProvider.messagesList[index];
          final usersMessage = element.type != 'admin';
          return TicketChatBubble(
            senderFromWeb: !usersMessage,
            index: index,
            datum: element,
          );
        }),
        separatorBuilder: (context, index) {
          return 8.toHeight;
        },
      );
    }
  }
}
