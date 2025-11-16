import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../story_kit.dart';
import '../helpers/video_utils.dart';

/// A widget that displays a video story view, supporting different video sources
/// (network, file) and optional thumbnail and error widgets.
class StoryKitVideo extends StatefulWidget {
  /// The story item containing video data and configuration.
  final StoryKitMedia media;

  /// Creates a [StoryKitVideo] widget.
  const StoryKitVideo({
    required this.media,
    super.key,
  });

  @override
  State<StoryKitVideo> createState() => _StoryKitVideoState();
}

class _StoryKitVideoState extends State<StoryKitVideo>
    with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;
  VideoPlayerController? videoPlayerController;
  ValueNotifier<StoryMediaLoadState> loadState = ValueNotifier(
    StoryMediaLoadState.loading,
  );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _initialiseVideoPlayer();
    super.initState();
  }

  /// Initializes the video player controller based on the source of the video.
  Future<void> _initialiseVideoPlayer() async {
    Duration currentDuration = widget.media.defaultDuration;
    try {
      context.pauseStory();
      StoryKitMedia media = widget.media;
      if (media.mediaSource == StoryMediaSource.network) {
        // Initialize video controller for network source.
        videoPlayerController =
            await VideoUtils.instance.videoControllerFromUrl(
          url: media.url,
          httpHeaders: media.httpHeaders,
        );
      } else {
        // Initialize video controller for file source.
        videoPlayerController = VideoUtils.instance.videoControllerFromFile(
          file: File(media.url),
        );
      }
      await videoPlayerController!.initialize();
      await videoPlayerController!.setVolume(media.isMuteByDefault ? 0 : 1);
      await videoPlayerController!.seekTo(Duration.zero);
      Duration duration = videoPlayerController!.value.duration;
      if (duration <= Duration.zero) {
        loadState.value = StoryMediaLoadState.error;
      } else {
        currentDuration = duration;
        loadState.value = StoryMediaLoadState.loaded;
      }
    } catch (e) {
      loadState.value = StoryMediaLoadState.error;
      debugPrint('$e');
    }
    context.playStory(currentDuration);
    videoPlayerController?.play();
  }

  BoxFit get fit => widget.media.ratio == StoryMediaRatioEnum.portrait
      ? BoxFit.cover
      : BoxFit.contain;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        pause();
        break;
      case AppLifecycleState.resumed:
        play();
        break;
      case AppLifecycleState.inactive:
        pause();
        break;
      case AppLifecycleState.hidden:
        pause();
        break;
      case AppLifecycleState.paused:
        pause();
        break;
    }
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardVisible) {
      _isKeyboardVisible = newValue;
      if (_isKeyboardVisible) {
        videoPlayerController?.pause();
      } else {
        videoPlayerController?.play();
      }
    }
  }

  void pause() {
    if (mounted) context.pauseStory();
  }

  void play() {
    if (mounted && !_isKeyboardVisible) context.playStory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<StoryMediaLoadState>(
      valueListenable: loadState,
      builder: (context, loadState, _) {
        bool cover = fit == BoxFit.cover;
        return Stack(
          alignment: cover ? Alignment.topCenter : Alignment.center,
          fit: cover ? StackFit.expand : StackFit.loose,
          children: [
            if (videoPlayerController != null)
              BlocListener<StoryKitController, StoryKitControllerState>(
                listenWhen: (previous, current) =>
                    previous.isPlaying != current.isPlaying,
                listener: (context, state) {
                  if (state.isPlaying) {
                    videoPlayerController?.play();
                  } else {
                    videoPlayerController?.pause();
                  }
                },
                child: widget.media.useVideoAspectRatio
                    ? AspectRatio(
                        aspectRatio: videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(
                          videoPlayerController!,
                        ),
                      )
                    : FittedBox(
                        fit: fit,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: widget.media.width ??
                              videoPlayerController!.value.size.width,
                          height: widget.media.height ??
                              videoPlayerController!.value.size.height,
                          child: VideoPlayer(videoPlayerController!),
                        ),
                      ),
              ),
            if (loadState == StoryMediaLoadState.loading) ...{
              if (widget.media.thumbnail != null) ...{
                // Display the thumbnail if provided.
                widget.media.thumbnail!,
              } else ...{
                // Display the loading widget if no thumbnail is provided.
                widget.media.loadingWidget ??
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
              },
            } else if (loadState == StoryMediaLoadState.error)
              // Display the error widget if an error occurred.
              widget.media.errorWidget ??
                  Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
          ],
        );
      },
    );
  }
}
