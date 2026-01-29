import 'dart:convert';

import 'package:car_service/helper/constant_helper.dart';
import 'package:car_service/services/conversation_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '../services/chat_services/chat_credential_service.dart';

class PusherHelper {
  late BuildContext context;
  var clientId;
  var providerId;
  var channelName;
  bool subscribed = false;
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  ChatCredentialService get credentials {
    return Provider.of<ChatCredentialService>(context, listen: false);
  }

  disConnect() async {
    try {
      setChatProviderId(null);
      await pusher.unsubscribe(channelName: channelName.toString());
      await pusher.disconnect();
    } catch (e) {
      debugPrint(e.toString());
      debugPrint(channelName.toString());
    }
  }

  void connectToPusher(BuildContext context, clientId, providerId) async {
    this.context = context;
    this.clientId = clientId;
    setChatProviderId(providerId);
    channelName = "private-livechat-provider-channel.$clientId.$providerId";
    this.providerId = providerId;
    debugPrint(channelName.toString());
    try {
      await pusher.init(
        apiKey: credentials.appKey,
        cluster: credentials.appCluster,
        onEvent: onEvent,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onConnectionStateChange: onConnectionStateChange,
        onError: (s, i, d) {
          throw s;
        },
        onAuthorizer: onAuthorizer,
      );
      await pusher.subscribe(channelName: channelName.toString());
      await pusher.connect();
      subscribed = true;
    } catch (e) {
      debugPrint(channelName.toString());
    }
  }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
    var stringToSign = '$socketId:$channelName';

    var hmacSha256 = Hmac(sha256, utf8.encode(credentials.appSecret));
    var digest = hmacSha256.convert(utf8.encode(stringToSign));

    return {
      "auth": "${credentials.appKey}:$digest",
      "user_data": "{\"id\":\"1\"}",
    };
  }

  void onEvent(PusherEvent event) {
    try {
      debugPrint(event.data.toString());
      final messageReceived = jsonDecode(event.data)['message'];
      debugPrint(messageReceived.toString());
      final receivedproviderId = jsonDecode(event.data)['message']['from_user'];
      debugPrint(receivedproviderId.toString());

      Provider.of<ConversationService>(context, listen: false)
          .addNewMessage(messageReceived);
    } catch (e) {}
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    subscribed = true;
    debugPrint("onSubscriptionSucceeded: $channelName data: $data");
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    debugPrint("Connection: $currentState");
  }
}
