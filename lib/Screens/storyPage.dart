import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:koram_app/Models/NewUserModel.dart';

import '../Models/User.dart';
import 'NewStoryView.dart';

class StoryPage extends StatefulWidget {
  List<UserDetail> Users;
  int pos;
  StoryPage({required this.Users, required this.pos});

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  int _currentIndex = 0;
  late PageController PgController;

  @override
  void initState() {
    log("userLength ${widget.Users.length}");
    // TODO: implement initState
    PgController = PageController(initialPage: widget.pos);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    PgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(

      controller: PgController,
      children: widget.Users.map((e) => NewStoryView(
            Uservalue: e,
            pageController: PgController,
            ListOfusers: widget.Users,
          )).toList(),
    );
  }
}
