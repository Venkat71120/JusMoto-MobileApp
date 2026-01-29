import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/services/conversation_service.dart';
import 'package:car_service/utils/components/custom_future_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/views/conversation_view/components/conversations_input_box.dart';
import '../../utils/components/navigation_pop_icon.dart';
import 'components/conversation_message_list.dart';
import 'components/conversation_skeleton.dart';

class ConversationView extends StatelessWidget {
  static const routeName = "conversation_view";
  const ConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = context.arguments;
    final id = arguments[0];
    final name = arguments[1];
    final image = arguments[2];
    final myId = arguments[3];
    final cProvider = Provider.of<ConversationService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(leading: const NavigationPopIcon(), title: Text(name)),
      body: Stack(
        children: [
          CustomFutureWidget(
            function: 2 == 2 ? cProvider.fetchConversationMessages(id) : null,
            shimmer: const ConversationSkeleton(),
            child: Consumer<ConversationService>(
              builder: (context, cs, child) {
                return Column(
                  children: [
                    Expanded(
                      child: ConversationMessageList(
                        cs: cs,
                        name: name,
                        clientImage: image,
                      ),
                    ),
                    ConversationInputBox(providerId: id),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
