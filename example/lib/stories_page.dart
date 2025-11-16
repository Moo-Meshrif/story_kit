import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:story_kit/story_kit.dart';

import 'dummy_data.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
 @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
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
                return const SizedBox.shrink();
            }
          },
          overlaysBuilder: (context, pageIndex, storyIndex) => [
            Spacer(),
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type something',
              ),
              onFieldSubmitted: (value) => log('onFieldSubmitted: $value'),
            ),
          ],
          onViewStory: (page, index) => log(
            'onViewStory: page=$page, index=$index',
          ),
          viewStoryTriggerPoint: 0.7,
          onPageLimitReached: () => Navigator.of(context).maybePop(),
        ),
      );
}
