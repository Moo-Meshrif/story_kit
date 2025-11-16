
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'story_kit_state.dart';

class StoryKitController extends Cubit<StoryKitControllerState> {
  StoryKitController() : super(StoryKitControllerState());

  void play([Duration? duration]) => emit(
        state.copyWith(
          status: StoryKitStatus.playing,
          currentDuration: duration,
        ),
      );
  void pause() => emit(
        state.copyWith(
          status: StoryKitStatus.paused,
        ),
      );
}
