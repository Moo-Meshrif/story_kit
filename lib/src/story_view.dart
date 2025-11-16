import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../story_kit.dart';

class _StoryKitIndicator extends StatelessWidget {
  const _StoryKitIndicator({
    required this.index,
    required this.value,
    required this.visitedColor,
    required this.unvisitedColor,
    required this.height,
    required this.radius,
  });

  final int index;
  final double value;
  final Color visitedColor;
  final Color unvisitedColor;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: unvisitedColor,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: visitedColor,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
        ),
      );
}

/// Controls story navigation (increment/decrement story index)
class _StoryStackController with ChangeNotifier {
  _StoryStackController(this.storyIndexNotifier, this.storyCount);

  final ValueNotifier<int> storyIndexNotifier;
  final int storyCount;

  void increment(VoidCallback nextPage) {
    if (storyIndexNotifier.value < storyCount - 1) {
      storyIndexNotifier.value++;
    } else {
      nextPage();
    }
    notifyListeners();
  }

  void decrement(VoidCallback previousPage) {
    if (storyIndexNotifier.value > 0) {
      storyIndexNotifier.value--;
    } else {
      previousPage();
    }
    notifyListeners();
  }
}

/// Main story view widget
class StoryKitView extends StatefulWidget {
  const StoryKitView({
    super.key,
    required this.pageCount,
    required this.storyCount,
    required this.contentBuilder,
    this.initialPage = 0,
    this.initialStoryIndex = 0,
    this.visitedColor,
    this.unvisitedColor,
    this.indicatorHeight = 4,
    this.indicatorRadius = 4,
    this.gesturePadding = const EdgeInsets.fromLTRB(
      20,
      kToolbarHeight,
      20,
      8,
    ),
    this.indicatorDuration,
    this.indicatorAnimationController,
    this.overlaysBuilder,
    this.onPageLimitReached,
    this.onViewStory,
    this.viewStoryTriggerPoint = 0.5,
  });

  /// total pages (e.g. users)
  final int pageCount;

  /// story length per page (can vary)
  final int Function(int pageIndex) storyCount;

  /// story UI builder
  final Widget Function(
    BuildContext context,
    int pageIndex,
    int storyIndex,
  ) contentBuilder;

  /// Optional gesture overlay (e.g. text input)
  final List<Widget> Function(
    BuildContext context,
    int pageIndex,
    int storyIndex,
  )? overlaysBuilder;

  /// starting page index
  final int initialPage;

  /// starting story index
  final int initialStoryIndex;

  /// indicator styling
  final Color? visitedColor;
  final Color? unvisitedColor;
  final double indicatorHeight;
  final double indicatorRadius;
  final EdgeInsets gesturePadding;

  /// indicator timing
  final Duration? indicatorDuration;
  final AnimationController? indicatorAnimationController;

  /// callback when last story/page ends
  final VoidCallback? onPageLimitReached;

  /// Triggered when the indicator reaches the middle of the story
  final void Function(int pageIndex, int storyIndex)? onViewStory;

  /// The point at which the indicator reaches the middle of the story
  final double viewStoryTriggerPoint;

  @override
  State<StoryKitView> createState() => StoryKitViewState();
}

class StoryKitViewState extends State<StoryKitView> {
  late final PageController pageController;
  Map<int, List<bool>> _storiesIndexPerPage = {};
  late int initialStoryIndex;
  bool firePreviousPage = false;

  @override
  void initState() {
    super.initState();
    initialStoryIndex = widget.initialStoryIndex;
    pageController = PageController(initialPage: widget.initialPage);
    _initializeStoriesMap();
  }

  @override
  void didUpdateWidget(covariant StoryKitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If pageCount or storyCount changed, reinitialize the map
    if (widget.pageCount != oldWidget.pageCount ||
        widget.storyCount != oldWidget.storyCount) {
      _initializeStoriesMap();
    }

    // If initialPage changed, replace the PageController
    if (widget.initialPage != oldWidget.initialPage) {
      pageController.dispose();
      pageController = PageController(initialPage: widget.initialPage);
    }

    // If initialStoryIndex changed, just update the field
    if (widget.initialStoryIndex != oldWidget.initialStoryIndex) {
      initialStoryIndex = widget.initialStoryIndex;
    }
  }

  void _initializeStoriesMap() {
    final map = <int, List<bool>>{};
    for (int page = 0; page < widget.pageCount; page++) {
      map[page] = List<bool>.filled(widget.storyCount(page), false);
    }
    _storiesIndexPerPage = map;
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => StoryKitController()),
        ],
        child: PageView.builder(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.pageCount,
          itemBuilder: (context, pageIndex) {
            final rotationY = (pageController.hasClients &&
                    pageController.position.hasContentDimensions)
                ? (pageController.page ?? widget.initialPage) - pageIndex
                : widget.initialPage - pageIndex;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(-rotationY * (math.pi / 180.0)),
              alignment: Alignment.center,
              child: _StoryPageBuilder(
                key: ValueKey(pageIndex),
                pageIndex: pageIndex,
                fromPreviousPage: firePreviousPage,
                storyCount: widget.storyCount(pageIndex),
                viewStatusList: _storiesIndexPerPage[pageIndex] ?? [],
                initialStoryIndex: initialStoryIndex,
                contentBuilder: widget.contentBuilder,
                onPageLimitReached: widget.onPageLimitReached,
                onViewStory: (pageIndex, storyIndex) {
                  _storiesIndexPerPage[pageIndex]![storyIndex] = true;
                  widget.onViewStory?.call(pageIndex, storyIndex);
                },
                viewStoryTriggerPoint: widget.viewStoryTriggerPoint,
                overlaysBuilder: widget.overlaysBuilder,
                visitedColor: widget.visitedColor ?? Colors.white,
                unvisitedColor: widget.unvisitedColor ?? Colors.white24,
                indicatorHeight: widget.indicatorHeight,
                indicatorRadius: widget.indicatorRadius,
                gesturePadding: widget.gesturePadding,
                indicatorDuration:
                    widget.indicatorDuration ?? const Duration(seconds: 5),
                indicatorAnimationController:
                    widget.indicatorAnimationController,
                nextPage: () {
                  if (pageIndex < widget.pageCount - 1) {
                    initialStoryIndex = widget.initialStoryIndex;
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  } else {
                    widget.onPageLimitReached?.call();
                  }
                },
                previousPage: () {
                  if (pageIndex > 0) {
                    firePreviousPage = true;
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                    List<bool> stories =
                        _storiesIndexPerPage[pageIndex - 1] ?? [];
                    int notViewedStoryIndex = stories.indexOf(false);
                    if (notViewedStoryIndex != -1) {
                      initialStoryIndex = notViewedStoryIndex;
                    } else {
                      initialStoryIndex = 0;
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            );
          },
        ),
      );
}

/// Contains indicators, gestures, and actual story content
class _StoryPageBuilder extends StatefulWidget {
  const _StoryPageBuilder({
    super.key,
    required this.pageIndex,
    required this.storyCount,
    required this.initialStoryIndex,
    required this.contentBuilder,
    required this.nextPage,
    required this.previousPage,
    required this.visitedColor,
    required this.unvisitedColor,
    required this.indicatorHeight,
    required this.indicatorRadius,
    required this.gesturePadding,
    required this.indicatorDuration,
    required this.indicatorAnimationController,
    this.overlaysBuilder,
    this.onPageLimitReached,
    this.onViewStory,
    required this.viewStoryTriggerPoint,
    required this.viewStatusList,
    required this.fromPreviousPage,
  });

  final int pageIndex;
  final int storyCount;
  final int initialStoryIndex;

  final Widget Function(
    BuildContext context,
    int pageIndex,
    int storyIndex,
  ) contentBuilder;
  final List<Widget> Function(
    BuildContext context,
    int pageIndex,
    int storyIndex,
  )? overlaysBuilder;

  final VoidCallback nextPage;
  final VoidCallback previousPage;

  final Color visitedColor;
  final Color unvisitedColor;
  final double indicatorHeight;
  final double indicatorRadius;
  final EdgeInsets gesturePadding;
  final Duration indicatorDuration;
  final AnimationController? indicatorAnimationController;
  final VoidCallback? onPageLimitReached;
  final void Function(int pageIndex, int storyIndex)? onViewStory;
  final double viewStoryTriggerPoint;
  final List<bool> viewStatusList;
  final bool fromPreviousPage;

  @override
  State<_StoryPageBuilder> createState() => _StoryPageBuilderState();
}

class _StoryPageBuilderState extends State<_StoryPageBuilder>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late ValueNotifier<int> storyIndexNotifier;
  late AnimationController controller;
  late _StoryStackController stackController;
  bool _isKeyboardVisible = false;
  List<bool> _viewStatusList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewStatusList = widget.viewStatusList;
    storyIndexNotifier = ValueNotifier(widget.initialStoryIndex);

    controller = widget.indicatorAnimationController ??
        AnimationController(
          vsync: this,
          duration: widget.indicatorDuration,
        );

    stackController = _StoryStackController(
      storyIndexNotifier,
      widget.storyCount,
    );

    controller.addStatusListener(_onControllerStatusChanged);

    controller.addListener(() {
      if (!_viewStatusList[storyIndexNotifier.value] &&
          controller.value >= widget.viewStoryTriggerPoint) {
        widget.onViewStory?.call(
          widget.pageIndex,
          storyIndexNotifier.value,
        );
      }
    });

    if (widget.fromPreviousPage) {
      controller.forward();
    }

    storyIndexNotifier.addListener(() {
      controller
        ..stop()
        ..reset()
        ..forward();
    });
  }

  void _onControllerStatusChanged(AnimationStatus status) {
    if (!mounted) return;

    // Only increment when the animation fully completes
    if (status == AnimationStatus.completed && controller.value == 1.0) {
      stackController.increment(widget.nextPage);
    }
  }

  @override
  void didUpdateWidget(covariant _StoryPageBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update stories indexes
    if (widget.viewStatusList != oldWidget.viewStatusList) {
      _viewStatusList = widget.viewStatusList;
    }

    // When the initial story index changes, start from that index cleanly
    if (widget.initialStoryIndex != oldWidget.initialStoryIndex) {
      storyIndexNotifier.value = widget.initialStoryIndex;
      controller
        ..stop()
        ..reset();
      controller
        ..removeStatusListener(_onControllerStatusChanged)
        ..addStatusListener(_onControllerStatusChanged);
    }

    // Update story stack length if changed
    if (widget.storyCount != oldWidget.storyCount) {
      stackController = _StoryStackController(
        storyIndexNotifier,
        widget.storyCount,
      );
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
        controller.stop();
      } else {
        controller.forward();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeStatusListener(_onControllerStatusChanged);
    controller.dispose();
    storyIndexNotifier.dispose();
    super.dispose();
  }

  /// Pause animation when user holds finger
  void pauseStory() {
    if (controller.isAnimating) context.pauseStory();
  }

  /// Resume animation when user lifts finger
  void resumeStory() {
    if (!controller.isAnimating && !_isKeyboardVisible) context.playStory();
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<StoryKitController, StoryKitControllerState>(
        listener: (context, state) {
          if (state.isPlaying && !_isKeyboardVisible) {
            if (state.currentDuration != null &&
                controller.duration?.inSeconds !=
                    state.currentDuration?.inSeconds) {
              controller.duration = state.currentDuration;
              controller
                ..stop()
                ..reset();
            }
            controller.forward();
          } else {
            controller.stop();
          }
        },
        listenWhen: (previous, current) =>
            previous.isPlaying != current.isPlaying ||
            previous.currentDuration != current.currentDuration,
        child: Stack(
          children: [
            /// Story content (text/image/video)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (_isKeyboardVisible) {
                    FocusScope.of(context).unfocus();
                  }
                },
                onLongPress: pauseStory,
                onLongPressUp: resumeStory,
                onTapDown: (details) {
                  if (!_isKeyboardVisible) {
                    final width = MediaQuery.of(context).size.width;
                    final dx = details.localPosition.dx;

                    const edgeFactor = 0.20; // 20% on each side
                    final leftEdge = width * edgeFactor;
                    final rightEdge = width * (1 - edgeFactor);

                    if (dx <= leftEdge) {
                      stackController.decrement(widget.previousPage);
                    } else if (dx >= rightEdge) {
                      stackController.increment(widget.nextPage);
                    }
                  }
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 0) {
                    widget.onPageLimitReached?.call();
                  }
                },
                child: ValueListenableBuilder<int>(
                  valueListenable: storyIndexNotifier,
                  builder: (context, index, _) => widget.contentBuilder(
                    context,
                    widget.pageIndex,
                    index,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: widget.gesturePadding.top,
              bottom: widget.gesturePadding.bottom,
              left: widget.gesturePadding.left,
              right: widget.gesturePadding.right,
              child: Column(
                children: [
                  /// Progress indicator bar under app bar
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => Row(
                      children: List.generate(
                        widget.storyCount == 0 ? 1 : widget.storyCount,
                        (index) => _StoryKitIndicator(
                          index: index,
                          value: index < storyIndexNotifier.value
                              ? 1
                              : index == storyIndexNotifier.value
                                  ? controller.value
                                  : 0,
                          visitedColor: widget.visitedColor,
                          unvisitedColor: widget.unvisitedColor,
                          height: widget.indicatorHeight,
                          radius: widget.indicatorRadius,
                        ),
                      ),
                    ),
                  ),

                  /// Optional gesture builder
                  if (widget.overlaysBuilder != null)
                    Expanded(
                      child: ValueListenableBuilder<int>(
                        valueListenable: storyIndexNotifier,
                        builder: (_, index, __) => Column(
                          children: widget.overlaysBuilder!(
                            context,
                            widget.pageIndex,
                            index,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      );
}
