import 'package:flutter/material.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Models/User.dart';
import 'package:story_view/story_view.dart';

class ViewStoryScreen extends StatefulWidget {
  ViewStoryScreen({key});
  @override
  State<ViewStoryScreen> createState() => _ViewStoryScreenState();
}

class _ViewStoryScreenState extends State<ViewStoryScreen> {
  final StoryPgCtrl = PageController();
  var storyItems = <StoryItem>[];
  StoryController stryCtrl = StoryController();

  @override
  void dispose() {
    // TODO: implement dispose
    StoryPgCtrl.dispose();
    stryCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    storyItems.add(StoryItem.pageImage(
        url:
            "https://s3-alpha-sig.figma.com/img/ea77/c6de/6493f3e0cd86964293ba9d822064ac40?Expires=1699228800&Signature=nNLF-6qJ03c2oH15mPw0b2zA4nwclmZpznMrphdqDwVlu8pCVAWFLpGOPNOku4PjNDTOlOYFENd6uLXQR8XAB6YvqRsViVmkBaZ6KwWb0v5Yp8bOTHlvw5kSXH2qx4lXNgbHIMaAURKJa5S-4mpZgjuyRpbvOkLQ9mG6u5~vr6IbwvM2L7sFdFnuY4pgjPQmYcxTTuwntZja5yUpkhMpxT0eCnc~YIljrCvx~D0GVreZyNenV-re-0qPrpBadavyi~svJMbTjBHIma9Z6giB~K8kILGBgrJGrNQ-vHrhxQ6mrltxE07iQWJCcjCjXuJCI2Qc53SkoTNeeBc8JYzSFg__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
        controller: stryCtrl));
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children:[ StoryView(
          storyItems: storyItems,
          controller: stryCtrl,
inline: false,
          indicatorForegroundColor:RuntimeStorage.instance.PrimaryOrange ,
          onComplete: () {
            Navigator.pop(context);
          },
        ),
    ]);

  }
}
