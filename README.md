# Story Kit

Story Kit is a Flutter package for creating **Instagram-like stories** with images, videos, animated indicators, gestures, overlays, and full control over story playback.  
It is lightweight, extensible, and production-ready.

---

## ✨ Features

- 📸 Image stories (network & file)
- 🎥 Video stories with caching  
- 📚 Page-by-page navigation (each user = a page)
- 🌀 Smooth story transitions  
- ⏱ Animated progress indicators  
- 👆 Tap to skip forward/backward  
- ✋ Hold to pause  
- ⌨️ Keyboard-aware (auto-pause when typing)
- 🧩 Custom UI overlays (input fields, buttons, etc.)
- 🎚 Custom per-story duration  
- 🎨 Portrait, landscape & square ratios  
- 🔉 Mute/unmute support  
- 📡 Custom dynamic URL builder  
- ✔ Story viewed callback  
- 🔚 End-of-stories callback  

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  story_kit:
    git:
      url: https://github.com/Moo-Meshrif/story_kit
```

Install:

```bash
flutter pub get
```

Import:

```dart
import 'package:story_kit/story_kit.dart';
```

---

## 🧠 Core Concepts

### Page  

Represents a group of stories (e.g., one user).

### Story  

A single image or video item.

### StoryKitMedia  

Model describing how each story loads & behaves.

### StoryKitView  

The full-screen engine that runs story logic.

---

## 🚀 Quick Start

### 1. Create your story data

```dart
import 'package:story_kit/story_kit.dart';

final pages = [
  [
    StoryKitMedia(
      url: 'https://picsum.photos/1200/800',
      mediaType: StoryMediaEnum.image,
      ratio: StoryMediaRatioEnum.square,
      defaultDuration: Duration(seconds: 5),
    ),
    StoryKitMedia(
      url: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      mediaType: StoryMediaEnum.video,
      mediaSource: StoryMediaSource.network,
    ),
  ],
  [
    StoryKitMedia.customUrl(
      customUrl: (size) {
        final base =
            'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d';
        return size != null ? "$base?w=${size.width}&h=${size.height}" : base;
      },
      ratio: StoryMediaRatioEnum.portrait,
    ),
  ],
];
```

---

### 2. Display the story viewer

```dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:story_kit/story_kit.dart';
import 'dummy_data.dart';

class StoriesPage extends StatelessWidget {
  const StoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: StoryKitView(
        pageCount: pages.length,
        storyCount: (pageIndex) => pages[pageIndex].length,
        contentBuilder: (context, pageIndex, storyIndex) {
          final media = pages[pageIndex][storyIndex];
          switch (media.mediaType) {
            case StoryMediaEnum.image:
              return StoryKitImage(media: media);
            case StoryMediaEnum.video:
              return StoryKitVideo(media: media);
            default:
              return SizedBox.shrink();
          }
        },
        overlaysBuilder: (context, pageIndex, storyIndex) => [
          const Spacer(),
          TextFormField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type something...',
            ),
            onFieldSubmitted: (v) => log('Submitted: $v'),
          ),
        ],
        onViewStory: (page, index) =>
            log("Viewed story: page=$page, story=$index"),
        onPageLimitReached: () =>
            Navigator.of(context).maybePop(),
      ),
    );
  }
}
```

---

## 🧩 StoryKitMedia

### Constructor

```dart
StoryKitMedia({
  required String url,
  required StoryMediaEnum mediaType,
  StoryMediaSource mediaSource = StoryMediaSource.network,
  StoryMediaRatioEnum? ratio,
  Duration defaultDuration = const Duration(seconds: 5),
  double? height,
  double? width,
  Map<String, String>? httpHeaders,
  Widget? thumbnail,
  Widget? errorWidget,
  Widget? loadingWidget,
  bool isMuteByDefault = false,
  bool useVideoAspectRatio = true,
  BoxFit? fit,
});
```

### Dynamic URL version

```dart
StoryKitMedia.customUrl({
  required String Function(Size? size) customUrl,
  StoryMediaEnum mediaType = StoryMediaEnum.image,
  StoryMediaSource mediaSource = StoryMediaSource.network,
  Duration defaultDuration = const Duration(seconds: 5),
  StoryMediaRatioEnum? ratio,
  ...
});
```

---

## 🎛 StoryKitView Parameters

```dart
StoryKitView({
  required int pageCount,
  required int Function(int pageIndex) storyCount,
  required Widget Function(BuildContext, int pageIndex, int storyIndex)
      contentBuilder,
  int initialPage = 0,
  int initialStoryIndex = 0,
  Color? visitedColor,
  Color? unvisitedColor,
  double indicatorHeight = 4,
  double indicatorRadius = 4,
  EdgeInsets gesturePadding = const EdgeInsets.fromLTRB(20, kToolbarHeight, 20, 8),
  Duration? indicatorDuration,
  AnimationController? indicatorAnimationController,
  List<Widget> Function(BuildContext, int pageIndex, int storyIndex)?
      overlaysBuilder,
  VoidCallback? onPageLimitReached,
  void Function(int pageIndex, int storyIndex)? onViewStory,
  double viewStoryTriggerPoint = 0.5,
});
```

### Common Use Cases

| Property | Usage |
|---------|-------|
| `pageCount` | Number of story pages. |
| `storyCount(page)` | Number of stories in each page. |
| `contentBuilder` | Returns StoryKitImage or StoryKitVideo. |
| `overlaysBuilder` | Input fields, buttons, overlays. |
| `indicatorDuration` | Override story duration. |
| `onViewStory` | Track when story becomes “viewed”. |
| `onPageLimitReached` | Close viewer automatically. |
| `viewStoryTriggerPoint` | When story counts as seen (0–1). |

---

## 🖼 Widgets

### StoryKitImage

```dart
StoryKitImage(media: media);
```

Supports:

- Network & file images  
- Cache manager  
- Custom loaders & error widgets  
- Fit & ratio overrides  

---

### StoryKitVideo

```dart
StoryKitVideo(media: media);
```

Supports:

- Network & file video  
- Video caching  
- Auto play/pause  
- Thumbnails  
- Error/loading widgets  
- Mute/unmute behavior  

---

## 🎮 Controller Extensions

Pause & resume stories programmatically:

```dart
context.pauseStory();
context.playStory();
```

Useful when:

- User opens keyboard  
- Custom gestures  
- Interactions require pausing animation  

---

## 📂 Example Project

A complete running example is included:

```example/
  lib/
    main.dart
    stories_page.dart
    dummy_data.dart
```

Run it:

```bash
flutter run
```

---

## 📄 License

MIT License.  
This package is free for commercial and open-source use.
