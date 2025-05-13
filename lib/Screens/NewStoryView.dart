import 'dart:convert';
import 'dart:developer';
import 'package:koram_app/Helper/color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:koram_app/Helper/CommonWidgets.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:story_view/story_view.dart';
import 'package:http/http.dart' as http;

import '../Helper/Helper.dart';
import '../Models/User.dart';

class NewStoryView extends StatefulWidget {
  UserDetail Uservalue;
  PageController pageController;
  List<UserDetail> ListOfusers;
  NewStoryView(
      {key,
      required this.Uservalue,
      required this.pageController,
      required this.ListOfusers});

  @override
  State<NewStoryView> createState() => _NewStoryViewState();
}

class _NewStoryViewState extends State<NewStoryView> {
  StoryController strController = StoryController();
  final storyItems = <StoryItem>[];
  var imgExt = ['jpg', 'jpeg', 'png', 'gif', 'bmp'];
  var videoExt = ['mp4', 'avi', 'mkv', 'mov'];
  var txtExt = ['txt', 'doc', 'docx', 'pdf'];
  bool isLoggedInUser = false;
  bool isExpanded = false;
  var ViewIndex = 0;
  var currentUser;
  var count = 0;
  @override
  void initState() {
    // TODO: implement initState
    addStoryitems();
    super.initState();
    if (G.userPhoneNumber == widget.Uservalue.phoneNumber) {
      setState(() {
        isLoggedInUser = true;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    StoryController().dispose();
    super.dispose();
  }

  String formatTimeDifference(DateTime dateTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      // Less than a minute ago
      return "${difference.inSeconds} secs ago";
    } else if (difference.inMinutes < 60) {
      // Less than an hour ago
      return "${difference.inMinutes} mins ago";
    } else if (difference.inHours < 24) {
      // Less than a day ago
      return "${difference.inHours} hours ago";
    } else {
      // For longer durations, you can format it as you like
      return DateFormat.yMd().add_jm().format(dateTime);
    }
  }

  String getFileExtension(String fileName) {
    List<String> parts = fileName.split('.');
    if (parts.length > 1) {
      var ext = parts.last.toLowerCase();
      if (imgExt.contains(ext)) {
        return "Image";
      } else if (videoExt.contains(ext)) {
        return "Video";
      } else if (txtExt.contains(ext)) {
        return "Text";
      }
    } else {
      return 'none'; // No file extension found
    }
    return "";
  }

  void handleCompleted() {
    widget.pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );

    final currentIndex = widget.ListOfusers.indexOf(widget.Uservalue);
    final isLastPage = widget.ListOfusers.length - 1 == currentIndex;
    log("${widget.Uservalue.phoneNumber} current index  $currentIndex  issLat $isLastPage");

    ViewIndex = 0;
    if (isLastPage) {
      Navigator.of(context).pop();
    }
  }

  addStoryitems() {
    log("length of story ${widget.Uservalue.story!.length}");
    for (var i in widget.Uservalue.story!) {
      if (getFileExtension(i.storyUrl!) == "Image") {
        log("added image ${i}");
        storyItems.add(StoryItem.pageImage(
            url: i.storyUrl!,
            controller: strController,
            duration: Duration(seconds: 3)));
      } else if (getFileExtension(i.storyUrl!) == "Video") {
        log("added vdo ");
      } else if (getFileExtension(i.storyUrl!) == "Text") {
        log("added txt ");
        storyItems.add(StoryItem.text(
            title: i.storyUrl!,
            backgroundColor: RuntimeStorage.instance.PrimaryOrange));
      }
    }
    log("lengthhh ${storyItems.length}");
  }

  @override
  Widget build(BuildContext context) {
    log("Built the widgett $count");
    return Scaffold(
        // type: MaterialType.transparency,
        body: Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        StoryView(
          onStoryShow: (r, index) async {
            log("inside count $count  lengthh ${widget.Uservalue.story!.length}  index $index");
            log("${widget.Uservalue.story![count].storyUrl}");

            int currentCount = count;
            if (count < widget.Uservalue.story!.length - 1) {
              count++;
            } else {
              log("count exceeded legth ");
            }

            if (!isLoggedInUser) {
              log("sending this urfl ${widget.Uservalue.story![currentCount].storyUrl}");
              var response = await http
                  .post(Uri.parse(G.HOST + "api/v1/addStorySeen"), body: {
                "viewedUserNo": G.userPhoneNumber,
                "storyOwner": widget.Uservalue.phoneNumber,
                "storyUrl": widget.Uservalue.story![currentCount].storyUrl,
                "seenTime": DateTime.now().toString()
              });
              log(response.body.toString());
            } else {
              log("not a logged in user ");
            }
            log("executing after the loop");
          },
          storyItems: storyItems,
          onComplete: handleCompleted,
          controller: strController,
          indicatorForegroundColor: Colors.white,
          indicatorColor: RuntimeStorage.instance.PrimaryOrange,
          progressPosition: ProgressPosition.top,
        ),
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50, // Adjust the height as needed
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.5), // Slightly transparent black
            ),
          ),
        ),
        Positioned(
          top: 50,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: SvgPicture.asset("assets/CaretLeftWhite.svg"),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  Container(
                      width: 50,
                      height: 50,
                      // decoration: ShapeDecoration(
                      //   shape: CircleBorder(),
                      // ),
                      child: widget.Uservalue.publicProfilePicUrl != ""
                          ? CommanWidgets().LoggedUserProfileDisplay(
                              widget.Uservalue.publicProfilePicUrl!)
                          : AssetImage("assets/profile.png")),
                  SizedBox(
                    width: 12,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 228,
                        child: Text(
                          '${widget.Uservalue.publicName}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w700,
                              height: 0,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      Container(
                        child: Text(
                          formatTimeDifference(DateTime.parse(widget
                              .Uservalue.story![count].postedTime
                              .toString())),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                      )
                    ],
                  ),
                  SvgPicture.asset("assets/threeDotWhite.svg")
                ]),
          ),
        ),
        // Black tint at the top

        Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: isLoggedInUser
                ? Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: ExpansionTileCard(
                        baseColor: Colors.white.withOpacity(0.5),
                        borderRadius: isExpanded
                            ? BorderRadius.only(
                                topLeft: Radius.circular(50),
                                topRight: Radius.circular(50))
                            : BorderRadius.all(Radius.circular(50)),
                        initiallyExpanded: false,
                        expandedColor: Colors.white,
                        contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        onExpansionChanged: (e) {
                          setState(() {
                            isExpanded = e;
                          });

                          if (e) {
                            strController.pause();
                          } else {
                            strController.play();
                          }
                          log("$e  is expanded value $isExpanded");
                        },
                        leading: Padding(
                          padding: isExpanded
                              ? EdgeInsets.only(left: 20, top: 10)
                              : EdgeInsets.only(left: 20),
                          child: Container(
                              width: 24,
                              height: 24,
                              child:
                                  SvgPicture.asset("assets/statusViews.svg")),
                        ),
                        // trailing: isExpanded!=true?SvgPicture.asset("assets/Arrow - Left 4.svg"):null,
                        title: Padding(
                          padding: isExpanded
                              ? EdgeInsets.only(top: 10.0)
                              : EdgeInsets.all(0),
                          child: Text(
                            '${widget.Uservalue.story![count].seenBy!.length} Views',
                            style: TextStyle(
                              color: Color(0xFF303030),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        trailing: Padding(
                          padding: isExpanded
                              ? EdgeInsets.only(right: 20, top: 10)
                              : EdgeInsets.only(right: 15.0),
                          child: isExpanded
                              ? SvgPicture.asset("assets/downChevron.svg")
                              : SvgPicture.asset("assets/Arrow - Left 4.svg"),
                        ),
                        children: <Widget>[
                          Divider(
                            thickness: 1.0,
                            height: 1.0,
                            indent: 10,
                            endIndent: 10,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxHeight: 300.0, // Set your maximum height here
                            ),
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: widget
                                      .Uservalue.story![count].seenBy!.isEmpty
                                  ? Container(
                                      height: 40,
                                      child: Text(
                                        "No view's Yet",
                                        style: TextStyle(
                                          color: Color(0xFF303030),
                                          fontSize: 14,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ))
                                  : Column(
                                      children: widget
                                          .Uservalue.story![count].seenBy!
                                          .map((r) {
                                      return ListTile(
                                        leading: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: new BoxDecoration(
                                              // color: backendColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.asset(
                                                "assets/Mumbai.png")),
                                        title: Text(
                                          '${r.user}',
                                          style: TextStyle(
                                            color: Color(0xFF303030),
                                            fontSize: 16,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w700,
                                            height: 0,
                                          ),
                                        ),
                                        subtitle: Text(
                                          formatTimeDifference(DateTime.parse(
                                              r.seenTime.toString())),
                                          style: TextStyle(
                                            color: Color(0xFF707070),
                                            fontSize: 14,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w400,
                                            height: 0,
                                          ),
                                        ),
                                      );
                                    }).toList()),
                            ),
                          ),
                          // ListTile(
                          //   leading: Container(
                          //       width: 36,
                          //       height: 36,
                          //       decoration: new BoxDecoration(
                          //         // color: backendColor,
                          //         shape: BoxShape.circle,
                          //       ),
                          //       child: Image.asset("assets/Mumbai.png")),
                          //   title: Text(
                          //     'test',
                          //     style: TextStyle(
                          //       color: Color(0xFF303030),
                          //       fontSize: 16,
                          //       fontFamily: 'Helvetica',
                          //       fontWeight: FontWeight.w700,
                          //       height: 0,
                          //     ),
                          //   ),
                          //   subtitle: Text(
                          //     '5 mins ago',
                          //     style: TextStyle(
                          //       color: Color(0xFF707070),
                          //       fontSize: 14,
                          //       fontFamily: 'Helvetica',
                          //       fontWeight: FontWeight.w400,
                          //       height: 0,
                          //     ),
                          //   ),
                          // )
                        ]),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 20,
                      height: 55.67,
                      decoration: ShapeDecoration(
                        color: Colors.white.withOpacity(0.800000011920929),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFE4E4E4)),
                          borderRadius: BorderRadius.circular(27.83),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 6, 0),
                        child: Center(
                          child: TextField(
                            onTap: () {
                              strController.pause();
                            },
                            onTapOutside: (e) {
                              FocusScope.of(context).unfocus();
                              log(e.toString());
                            },
                            decoration: InputDecoration(
                              hintText: "Type..",
                              border: InputBorder.none,
                              suffixIcon: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 57.58,
                                  height: 42.35,
                                  decoration: ShapeDecoration(
                                    color: backendColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(22.44),
                                    ),
                                  ),
                                  child: Center(
                                      child:
                                          SvgPicture.asset("assets/Send.svg")),
                                ),

                                // Container(
                                //   height: 40,
                                //   child: Image.asset("assets/Group 516.png"),
                                // ),
                              ),

                              // GestureDetector(
                              //   onTap: () {},
                              //   child: Container(
                              //     // width: 57.58,
                              //     // height: 42.35,
                              //     decoration: ShapeDecoration(
                              //       color: backendColor,
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(22.44),
                              //       ),
                              //     ),
                              //     child: Center(
                              //         child: SvgPicture.asset("assets/Send.svg")),
                              //   ),
                              //
                              //   // Container(
                              //   //   height: 40,
                              //   //   child: Image.asset("assets/Group 516.png"),
                              //   // ),
                              // )
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
      ],
    ));
  }
}
