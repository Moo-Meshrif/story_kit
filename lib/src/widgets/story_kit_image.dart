import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../story_kit.dart';

class StoryKitImage extends StatefulWidget {
  const StoryKitImage({super.key, required this.media});

  final StoryKitMedia media;

  @override
  State<StoryKitImage> createState() => _StoryKitImageState();
}

class _StoryKitImageState extends State<StoryKitImage> {
  void _startAnimationIfNeeded() {
    if (!mounted) return;
    var controller = context.storyKitController;
    if (controller == null) return;
    if (controller.state.isPaused ||
        controller.state.currentDuration?.inSeconds != 5) {
      controller.play(
        widget.media.defaultDuration,
      );
    }
  }

  void pause() {
    if (mounted) context.pauseStory();
  }

  Size? getSize() {
    if (widget.media.width != null && widget.media.height != null)
      return Size(
        widget.media.width!,
        widget.media.height!,
      );
    final ratio = widget.media.ratio;
    double? factor = ratio?.getRatio;
    if (ratio == null || factor == null) return null;
    final deviceSize = MediaQuery.of(context).size;
    double width, height;
    switch (ratio) {
      case StoryMediaRatioEnum.square:
        width = height = deviceSize.width;
        break;
      case StoryMediaRatioEnum.landscape:
        width = deviceSize.width;
        height = width / factor;
        break;
      case StoryMediaRatioEnum.portrait:
        height = deviceSize.height;
        width = height * factor;
        break;
      default:
        return null;
    }
    return Size(width, height);
  }

  @override
  Widget build(BuildContext context) {
    Size? size = getSize();
    if (widget.media.mediaSource == StoryMediaSource.network) {
      return CachedNetworkImage(
        imageUrl: widget.media.customUrl?.call(
              size,
            ) ??
            widget.media.url,
        height: size?.height ?? widget.media.height,
        width: size?.width ?? widget.media.width,
        fit: widget.media.fit ?? BoxFit.contain,
        httpHeaders: widget.media.httpHeaders,
        placeholder: (_, __) {
          pause();
          return Center(
            child: widget.media.loadingWidget ??
                CircularProgressIndicator.adaptive(),
          );
        },
        errorWidget: (_, __, ___) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _startAnimationIfNeeded());
          return Center(
            child: widget.media.errorWidget ??
                Icon(
                  Icons.error,
                  color: Colors.red,
                ),
          );
        },
        imageBuilder: (context, imageProvider) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _startAnimationIfNeeded());
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(widget.media.customUrl?.call(size) ?? widget.media.url),
        fit: widget.media.fit ?? BoxFit.contain,
        height: size?.height ?? widget.media.height,
        width: size?.width ?? widget.media.width,
        errorBuilder: (context, error, stackTrace) => Center(
          child: widget.media.errorWidget ??
              Icon(
                Icons.error,
                color: Colors.red,
              ),
        ),
      );
    }
  }
}
