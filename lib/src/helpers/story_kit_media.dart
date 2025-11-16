import 'package:flutter/material.dart';

import '../../story_kit.dart';

class StoryKitMedia {
  const StoryKitMedia({
    required this.url,
    this.customUrl,
    this.height,
    this.width,
    this.httpHeaders,
    this.ratio,
    required this.mediaType,
    this.mediaSource = StoryMediaSource.network,
    this.isMuteByDefault = false,
    this.useVideoAspectRatio = true,
    this.thumbnail,
    this.errorWidget,
    this.loadingWidget,
    this.fit,
    this.defaultDuration = const Duration(
      seconds: 5,
    ),
  });

  factory StoryKitMedia.customUrl({
    required String Function(Size?) customUrl,
    StoryMediaEnum mediaType = StoryMediaEnum.image,
    StoryMediaSource mediaSource = StoryMediaSource.network,
    Duration defaultDuration = const Duration(seconds: 5),
    Map<String, String>? httpHeaders,
    double? height,
    double? width,
    StoryMediaRatioEnum? ratio,
    Widget? errorWidget,
    Widget? loadingWidget,
    bool isMuteByDefault = false,
    bool useVideoAspectRatio = true,
    Widget? thumbnail,
    BoxFit? fit,
  }) =>
      StoryKitMedia(
        customUrl: customUrl,
        mediaType: StoryMediaEnum.image,
        mediaSource: StoryMediaSource.network,
        defaultDuration: Duration(seconds: 5),
        httpHeaders: httpHeaders,
        height: height,
        width: width,
        ratio: ratio,
        errorWidget: errorWidget,
        loadingWidget: loadingWidget,
        isMuteByDefault: isMuteByDefault,
        useVideoAspectRatio: useVideoAspectRatio,
        thumbnail: thumbnail,
        fit: fit,
        url: '',
      );

  /// Height for the media
  final double? height;

  /// Width for the media
  final double? width;

  /// Url of the media
  final String url;

  /// Custom url of the image
  final String? Function(Size?)? customUrl;

  /// Fit for the image
  final BoxFit? fit;

  /// ratio of the media
  final StoryMediaRatioEnum? ratio;

  /// type of the media
  final StoryMediaEnum mediaType;

  /// source of the media
  final StoryMediaSource mediaSource;

  /// Optional headers for the http request of the image url
  final Map<String, String>? httpHeaders;

  /// use if there is audio
  final bool isMuteByDefault;

  /// use if there is video
  final bool useVideoAspectRatio;

  /// Optional thumbnail for the video
  final Widget? thumbnail;

  /// Optional error widget
  final Widget? errorWidget;

  /// Optional loading widget
  final Widget? loadingWidget;

  /// default duration
  final Duration defaultDuration;
}
