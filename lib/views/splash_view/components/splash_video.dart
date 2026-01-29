import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ButterFlyAssetVideo extends StatefulWidget {
  const ButterFlyAssetVideo({super.key});

  @override
  ButterFlyAssetVideoState createState() => ButterFlyAssetVideoState();
}

class ButterFlyAssetVideoState extends State<ButterFlyAssetVideo> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(
      'assets/files/splash_video.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    try {
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0);
      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const SizedBox();
    }

    return Center(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width * 1.05,
            height: _controller!.value.size.height * 1.01,
            child: VideoPlayer(_controller!),
          ),
        ),
      ),
    );
  }
}
