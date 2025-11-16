import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../story_kit.dart';

extension StoryKitHelper on BuildContext {
  StoryKitController? get storyKitController {
    try {
      return read<StoryKitController>();
    } catch (e) {
      return null;
    }
  }

  void playStory([Duration? duration]) => storyKitController?.play(duration);

  void pauseStory() => storyKitController?.pause();
}

extension RatioEnumX on StoryMediaRatioEnum {
  double? get getRatio => this == StoryMediaRatioEnum.landscape
      ? 16 / 9
      : this == StoryMediaRatioEnum.portrait
          ? 9 / 16
          : this == StoryMediaRatioEnum.square
              ? 1
              : null;
}
