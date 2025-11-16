part of 'story_kit_cubit.dart';

enum StoryKitStatus {
  playing,
  paused,
}

extension StorykitStateX on StoryKitControllerState {
  bool get isPlaying => status == StoryKitStatus.playing;
  bool get isPaused => status == StoryKitStatus.paused;
}

@immutable
class StoryKitControllerState {
  final StoryKitStatus status;
  final Duration? currentDuration;

  const StoryKitControllerState({
    this.status = StoryKitStatus.paused,
    this.currentDuration,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StoryKitControllerState && other.status == status && other.currentDuration == currentDuration;
  }

  @override
  int get hashCode => status.hashCode ^ currentDuration.hashCode;

  StoryKitControllerState copyWith({
    StoryKitStatus? status,
    Duration? currentDuration,
  }) {
    return StoryKitControllerState(
      status: status ?? this.status,
      currentDuration: currentDuration ?? this.currentDuration,
    );
  }
}
