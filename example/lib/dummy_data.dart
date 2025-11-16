 import 'package:story_kit/story_kit.dart';

final pages = [
    // Page 0
    [
      StoryKitMedia(
        url: 'https://picsum.photos/1200/800',
        mediaType: StoryMediaEnum.image,
        ratio: StoryMediaRatioEnum.square,
        defaultDuration: const Duration(seconds: 5),
      ),
      StoryKitMedia(
        url:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        mediaType: StoryMediaEnum.video,
        mediaSource: StoryMediaSource.network,
        isMuteByDefault: true,
        ratio: StoryMediaRatioEnum.portrait,
      ),
    ],
    // Page 1
    [
      StoryKitMedia.customUrl(
        customUrl: (size) {
          var url =
              'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?q=80&auto=format&fit=crop';
          return size != null ? url + '?w=${size.width}&h=${size.height}' : url;
        },
        ratio: StoryMediaRatioEnum.portrait,
      ),
    ],
  ];
  