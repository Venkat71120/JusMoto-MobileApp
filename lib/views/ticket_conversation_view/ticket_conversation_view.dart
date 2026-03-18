import 'package:car_service/customizations/colors.dart';
import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/extension/string_extension.dart';
import 'package:car_service/helper/svg_assets.dart';
import 'package:car_service/utils/components/navigation_pop_icon.dart';
import 'package:car_service/view_models/ticket_conversation_view_model/ticket_conversation_view_model.dart';
import 'package:car_service/views/ticket_conversation_view/components/ticket_chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/local_keys.g.dart';
import '../../services/support_services/ticket_conversation_service.dart';
import '../../utils/components/custom_button.dart';
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
                        padding: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: context.color.accentContrastColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: context.height / 7,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: TextField(
                                  maxLines: 4,
                                  controller: tcm.messageController,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: LocalKeys.writeMessage,
                                    hintStyle: TextStyle(
                                      color: context.color.tertiaryContrastColo,
                                      fontSize: 14,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: context.color.primaryBorderColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: context.color.primaryBorderColor,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: context.color.primaryBorderColor,
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    tcProvider.setMessage(value);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    LocalKeys.file,
                                    style: TextStyle(
                                      color: context.color.tertiaryContrastColo,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      tcm.fileSelector();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color:
                                              context.color.primaryBorderColor,
                                        ),
                                      ),
                                      child: Text(
                                        LocalKeys.selectFile,
                                        style: TextStyle(
                                          color:
                                              context
                                                  .color
                                                  .tertiaryContrastColo,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ValueListenableBuilder(
                                    valueListenable: tcm.selectedFile,
                                    builder: (context, file, child) {
                                      return SizedBox(
                                        width: context.width / 3,
                                        child: Text(
                                          file == null
                                              ? LocalKeys.noFileChosen
                                              : file.path.split('/').last,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.titleSmall,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder(
                              valueListenable: tcm.notifyEmail,
                              builder: (context, notify, child) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Transform.scale(
                                        scale: 1.3,
                                        child: Checkbox(
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          side: BorderSide(
                                            width: 1,
                                            color:
                                                context
                                                    .color
                                                    .primaryBorderColor,
                                          ),
                                          activeColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            side: BorderSide(
                                              width: 1,
                                              color:
                                                  context
                                                      .color
                                                      .primaryBorderColor,
                                            ),
                                          ),
                                          value: notify,
                                          onChanged: (value) {
                                            tcm.notifyEmail.value = !notify;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      RichText(
                                        softWrap: true,
                                        text: TextSpan(
                                          text: LocalKeys.notifyViaMail,
                                          style: TextStyle(
                                            color:
                                                context
                                                    .color
                                                    .tertiaryContrastColo,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    return ValueListenableBuilder(
                                      valueListenable: tcm.isLoading,
                                      builder: (context, loading, child) {
                                        return CustomButton(
                                          btText: LocalKeys.send,
                                          isLoading: loading,
                                          onPressed: () async {
                                            tcProvider.setIsLoading(true);
                                            tcm.trySendingMessage(context);
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: SizedBox(height: 25),
                            ),
                          ],
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
    } else if ((tcProvider.messagesList ?? []).isEmpty) {
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

  Widget showFile(
    BuildContext context,
    String? url,
    int id,
    AlignmentGeometry alignment,
  ) {
    print('Url is: $url');
    if (url != null &&
        (!url.contains('.png') &&
            !url.contains('.jpg') &&
            !url.contains('.jpeg'))) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 50,
        width: 50,
        child: SvgAssets.fileText.toSVGSized(
          24,
          color: context.color.tertiaryContrastColo,
        ),
      );
    }
    return GestureDetector(
      onTap: () {},
      child:
          url != null
              ? GestureDetector(
                child: Container(
                  alignment: alignment,
                  constraints: BoxConstraints(maxWidth: context.width / 1.5),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Image.network(
                    url,
                    alignment: alignment,
                    loadingBuilder: (context, child, loding) {
                      if (loding == null) {
                        return child;
                      }
                      return Container(
                        height: 200,
                        margin: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            alignment: alignment,
                            image: const AssetImage(
                              'assets/images/app_icon.png',
                            ),
                            opacity: .4,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, str, some) {
                      return Container(
                        height: 200,
                        margin: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            alignment: alignment,
                            image: const AssetImage(
                              'assets/images/app_icon.png',
                            ),
                            opacity: .4,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
              : const SizedBox(),
    );
  }
}
