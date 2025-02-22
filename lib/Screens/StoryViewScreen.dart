import 'dart:async';

import 'package:flutter/material.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Models/User.dart';

class StoryViewScreen extends StatefulWidget {
  List<UserDetail> stories;
  int pos;
  StoryViewScreen(this.stories, this.pos);

  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  int _currentIndex = 0;
  int j = 0;
  late Timer _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentIndex = widget.pos;
    // _timer = Timer.periodic(Duration(seconds: 3), (timer) {
    //   increementJ();
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _timer.cancel();
  }

  increementJ() {
    if (j + 1 < widget.stories[_currentIndex].story!.length - 1) {
      if (mounted)
        setState(() {
          j++;
          print(j);
        });
    } else {
      if (_currentIndex + 1 <= widget.stories.length - 1) {
        if (mounted)
          setState(() {
            _currentIndex++;
            j = 0;
            print(_currentIndex);
          });
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          increementJ();
        },
        child: Container(
          height: height,
          width: width,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Column(
            children: [
              Container(
                height: 70,
                child: ListTile(
                  // tileColor: Colors.black.withOpacity(.6),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(G.HOST +
                        "api/v1/images/" +
                        widget.stories[_currentIndex].publicProfilePicUrl!),
                  ),
                  title: Text(widget.stories[_currentIndex].publicName!),
                ),
              ),

              Container(
                height: height - 70 - MediaQuery.of(context).padding.top,
                width: width,
                child: Image.network(G.HOST +
                    "api/v1/images/" +
                    widget.stories[_currentIndex].story![j].storyUrl!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
