import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../story_kit.dart';

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
  bool _isKeyboardVisible = false, setBefore = false, _showError = false;
  BetterPlayerController? _betterPlayerController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.pauseStory();
    _setupBetterPlayer();
  }

  /// Sets up the BetterPlayer controller.
  void _setupBetterPlayer() {
    final dataSource = BetterPlayerDataSource(
      widget.media.mediaSource == StoryMediaSource.network
          ? BetterPlayerDataSourceType.network
          : BetterPlayerDataSourceType.file,
      widget.media.url,
      videoFormat:
          widget.media.url.contains('m3u') ? BetterPlayerVideoFormat.hls : null,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 100 * 1024 * 1024, // 100MB
        maxCacheFileSize: 50 * 1024 * 1024,
      ),
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        fullScreenByDefault: false,
        aspectRatio: widget.media.ratio?.getRatio ?? 16 / 9,
        fit: fit,
        allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        placeholder: _buildDefaultLoading(),
      ),
      betterPlayerDataSource: dataSource,
    );
    _betterPlayerController?.setVolume(widget.media.isMuteByDefault ? 0 : 1);
    _betterPlayerController?.addEventsListener((event) {
      switch (event.betterPlayerEventType) {
        case BetterPlayerEventType.initialized:
          if (!setBefore && mounted) {
            Duration duration = _betterPlayerController
                    ?.videoPlayerController?.value.duration ??
                Duration.zero;
            if (duration <= Duration.zero) {
              duration = Duration(seconds: 5);
            }
            context.playStory(duration);
            setBefore = true;
          }
          break;
        case BetterPlayerEventType.exception:
          if (!setBefore && mounted) {
            context.playStory(const Duration(seconds: 5));
            setBefore = true;
            setState(() => _showError = true);
          }
          break;
        default:
          break;
      }
    });
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
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        pause();
        break;
      case AppLifecycleState.resumed:
        play();
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
        _betterPlayerController?.pause();
      } else {
        _betterPlayerController?.play();
      }
    }
  }

  void pause() {
    if (mounted) context.pauseStory();
  }

  void play() {
    if (mounted && !_isKeyboardVisible) context.playStory();
  }

  Widget _buildDefaultError() =>
      widget.media.errorWidget ??
      Center(
        child: Icon(Icons.error),
      );

  Widget _buildDefaultLoading() =>
      widget.media.thumbnail ??
      widget.media.loadingWidget ??
      const Center(
        child: CircularProgressIndicator(),
      );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget player = _showError
        ? _buildDefaultError()
        : _betterPlayerController != null
            ? BetterPlayer(controller: _betterPlayerController!)
            : _buildDefaultLoading();

    if (context.storyKitController != null) {
      return BlocListener<StoryKitController, StoryKitControllerState>(
        listener: (context, state) {
          if (state.isPlaying) {
            _betterPlayerController?.play();
          } else {
            _betterPlayerController?.pause();
          }
        },
        listenWhen: (previous, current) =>
            !_isKeyboardVisible && previous.isPlaying != current.isPlaying,
        child: player,
      );
    }

    return player;
  }
}
