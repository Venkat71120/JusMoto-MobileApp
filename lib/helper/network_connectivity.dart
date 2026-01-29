import 'dart:async';
import 'dart:io';

import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/int_extension.dart';
import 'package:car_service/helper/local_keys.g.dart';
import 'package:car_service/utils/components/custom_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;
  void initialise() async {
    var result = await _networkConnectivity.checkConnectivity();
    _checkStatus(result);
    _networkConnectivity.onConnectivityChanged.listen((result) {
      print(result);
      _checkStatus(result);
    });
  }

  Future<bool> currentStatus() async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    return isOnline;
  }

  void _checkStatus(List<ConnectivityResult> result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result.firstOrNull: isOnline});
  }

  void disposeStream() => _controller.close();

  listenToConnectionChange(BuildContext context) {
    Map source = {ConnectivityResult.none: false};
    String string = '';
    initialise();
    bool isOffline = false;
    myStream.listen((source) {
      source = source;
      print('source $source');

      switch (source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          string =
              source.values.toList()[0] ? 'Mobile: Online' : 'Mobile: Offline';
          break;
        case ConnectivityResult.wifi:
          string = source.values.toList()[0] ? 'WiFi: Online' : 'WiFi: Offline';
          break;
        case ConnectivityResult.none:
        default:
          string = 'Offline';
      }
      if (string.contains('Online') && isOffline) {
        isOffline = false;
        Navigator.pop(context);
      }
      if (string.contains('Offline') && !isOffline) {
        isOffline = true;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Container(
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: context.color.accentContrastColor,
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LottieBuilder.asset(
                      'assets/animations/no_internet.json',
                      height: 240,
                    ),
                    Text(
                      LocalKeys.oops,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    8.toHeight,
                    Text(
                      LocalKeys.noConnectionFound,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    16.toHeight,
                    CustomButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        btText: LocalKeys.okay,
                        isLoading: false)
                  ]),
            ),
          ),
        ).then((value) => isOffline = false);
      }
    });
  }
}
