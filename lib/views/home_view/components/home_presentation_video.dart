import 'package:car_service/helper/extension/context_extension.dart';
import 'package:car_service/helper/extension/widget_extension.dart';
import 'package:car_service/utils/components/text_skeleton.dart';
import 'package:car_service/view_models/home_view_model/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../customizations/colors.dart';

class HomePresentationVideo extends StatefulWidget {
  const HomePresentationVideo({super.key});

  @override
  HomePresentationVideoState createState() => HomePresentationVideoState();
}

class HomePresentationVideoState extends State<HomePresentationVideo> {
  final hvm = HomeViewModel.instance;

  @override
  void initState() {
    super.initState();
    hvm.controller.value ??= VideoPlayerController.networkUrl(
      Uri.parse(
        'https://drive.google.com/uc?export=download&id=1_QSrPnrlE_6pzO5A1Nx16UHgICqn4soo',
      ),
    );

    hvm.controller.value?.addListener(() {
      if (mounted) setState(() {});
    });
    hvm.controller.value?.setLooping(true);
    hvm.controller.value?.setVolume(0.0); // Reduce memory usage
    hvm.controller.value?.initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: hvm.controller,
      builder: (context, value, child) {
        if (value == null) {
          return SizedBox();
        }

        return SizedBox(
          child:
              value.value.isInitialized
                  ? FittedBox(
                    child: SizedBox(
                      width: context.width * .9,
                      height: context.width * .6,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(value),
                          _ControlsOverlay(controller: value),
                          VideoProgressIndicator(value, allowScrubbing: true),
                        ],
                      ),
                    ),
                  )
                  : TextSkeleton(
                    width: context.width * .9,
                    height: context.width * .6,
                    color: mutedPrimaryColor,
                  ).shim, // Show loader while initializing
        );
      },
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child:
              controller.value.isPlaying
                  ? const SizedBox.shrink()
                  : const ColoredBox(
                    color: Colors.black26,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24.0,
                          semanticLabel: 'Play',
                        ),
                      ),
                    ),
                  ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
