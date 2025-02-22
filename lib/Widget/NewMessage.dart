import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Models/ChatRoom.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Models/Message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../Helper/PageProviderService.dart';

class NewMessage extends StatefulWidget {
  final PrivateMessage messageData;
  NewMessage({required this.messageData});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  // late VideoPlayerController _controller;
  // late ChewieController _chewieController;
  var _controller;
  var _chewieController;
  late double spaceWidth;
  bool sentByMe = false;
  var _initializeVideoPlayerFuture;
  String formattedTime = "";
  String fileType = "";
  var thumbnailBytes;
  bool isLoading = true;
  BoxShadow Shadoww = BoxShadow(
    color: Colors.grey.withOpacity(0.2),
    // spreadRadius: 1,
    // blurRadius: 1,
    offset: Offset(0, 1), // changes position of shadow
  );
  BoxShadow whiteShadow = BoxShadow(
    color: Colors.white.withOpacity(1),
    // spreadRadius: 1,
    // blurRadius: 1,
    offset: Offset(0, 1), // changes position of shadow
  );
  @override
  void dispose() {
    // TODO: implement dispose
    if (fileType == "Video") {
      _controller.dispose();
      _chewieController.dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    isLoading = true;
    // TODO: implement initState

    if (widget.messageData.message.characters.length > 31) {
      spaceWidth = 10;
    } else {
      spaceWidth = widget.messageData.message.characters.length - 31;
      spaceWidth.abs();
    }
    DateTime dateTime = DateTime.parse(widget.messageData.time);

    // Format the time using intl package
    formattedTime = DateFormat.jm().format(dateTime);

    String getFileType(String extension) {
      List<String> imageExtensions = ['png', 'jpg', 'jpeg', 'gif', 'bmp'];
      List<String> videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'flv'];
      List<String> documentExtensions = [
        'pdf',
        'doc',
        'docx',
        'txt',
        'ppt',
        'xls'
      ];

      if (imageExtensions.contains(extension)) {
        return 'Image';
      } else if (videoExtensions.contains(extension)) {
        return 'Video';
      } else if (documentExtensions.contains(extension)) {
        return 'Document';
      } else {
        return 'Unknown';
      }
    }

    sentByMe = widget.messageData.sentBy == G.userPhoneNumber;

    String ext;
    if (widget.messageData.fileName != null) {
      String ext = widget.messageData.fileName!.split(".").last;
      log("Ext $ext");
      fileType = getFileType(ext);
      if (fileType == "Video") {
        Future.delayed(Duration.zero).then((value) async {
          thumbnailBytes = await generateThumbnailFromNetwork(G.HOST +
              "api/v1/images/" +
              widget.messageData.fileName.toString());
        });

        log("inside video");

        _controller = VideoPlayerController.networkUrl(Uri.parse(
            G.HOST + "api/v1/images/" + widget.messageData.fileName.toString()))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: false,
          looping: false,
        );
      }
    }
    isLoading = false;
    setState(() {});
    super.initState();
  }

// Function to generate a thumbnail image from the video file
  Future<Uint8List> generateThumbnailFromNetwork(String videoUrl) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      // maxWidth:200, // Adjust as needed
      // maxHeight: ,
      quality: 100,
      // Adjust as needed
    );
    return uint8list!;
  }

  @override
  Widget build(BuildContext context) {
    // log(widget.messageData.message.characters.length.toString());
    // if (widget.messageData.message.characters.length > 31) {
    //   log("more the none line ${widget.messageData.message.characters.length}");
    //   spaceWidth = 10;
    // } else {
    //   log("within one line ${widget.messageData.message.characters.length} ");
    //   spaceWidth = widget.messageData.message.characters.length - 31;
    //   spaceWidth.abs();
    // }
    // DateTime dateTime = DateTime.parse(widget.messageData.time);
    //
    // // Format the time using intl package
    // String formattedTime = DateFormat.jm().format(dateTime);
    //
    // String fileType = "";
    // String getFileType(String extension) {
    //   List<String> imageExtensions = ['png', 'jpg', 'jpeg', 'gif', 'bmp'];
    //   List<String> videoExtensions = ['mp4', 'avi', 'mkv', 'mov', 'flv'];
    //   List<String> documentExtensions = [
    //     'pdf',
    //     'doc',
    //     'docx',
    //     'txt',
    //     'ppt',
    //     'xls'
    //   ];
    //
    //   if (imageExtensions.contains(extension)) {
    //     return 'Image';
    //   } else if (videoExtensions.contains(extension)) {
    //     return 'Video';
    //   } else if (documentExtensions.contains(extension)) {
    //     return 'Document';
    //   } else {
    //     return 'Unknown';
    //   }
    // }
    //
    // bool sentByMe = widget.messageData.sentBy == G.userId;
    // String ext;
    // log("message Filename ${widget.messageData.fileName}");
    // if (widget.messageData.fileName != null) {
    //   String ext = widget.messageData.fileName!.split(".").last;
    //   log("Ext $ext");
    //   fileType = getFileType(ext);
    //   log("File Type: $fileType");
    // }
    var fullwidth = MediaQuery.of(context).size.width;

    Widget FileShowWidget(String Type) {
      switch (Type) {
        case 'Image':
          {
            return GestureDetector(
              onTap: () {
                log("clickeddd");
                // showDialog(
                //   context: context,
                //   builder: (BuildContext context) {
                //     return
                //
                //         //   AlertDialog(
                //         //   // actions: [TextButton(onPressed: (){Navigator.pop(context);}, child: Text("X"))],
                //         //   actionsAlignment: MainAxisAlignment.start,
                //         //   scrollable: true,
                //         //   title: GestureDetector(
                //         //       onTap:(){
                //         //         Navigator.pop(context);
                //         //       },child: Text("Close")),
                //         //
                //         //   titleTextStyle: TextStyle(fontSize: 15,color: Colors.red),
                //         //   titlePadding: EdgeInsets.fromLTRB(5,10, 5,5),
                //         //   contentPadding: EdgeInsets.fromLTRB(5,0, 5,5),
                //         //   content: Column(
                //         //     children: [
                //         //       Container(
                //         //
                //         //         width: MediaQuery.of(context).size.width,
                //         //         height: MediaQuery.of(context).size.height,
                //         //         child: CachedNetworkImage( imageUrl: G.HOST +
                //         //         "api/v1/images/" +
                //         //         widget.messageData.fileName.toString(),
                //         //         filterQuality: FilterQuality.medium
                //         //
                //         //         ),
                //         //       ),
                //         //     ],
                //         //   ),
                //         // );
                //         AlertDialog(
                //
                //       // Making the dialog full-screen
                //       insetPadding: EdgeInsets.all(0),
                //       contentPadding: EdgeInsets.all(0),
                //       content: Stack(
                //         children: [
                //           // Full-screen image
                //           Positioned.fill(
                //             child: CachedNetworkImage(
                //               imageUrl: G.HOST +
                //                   "api/v1/images/" +
                //                   widget.messageData.fileName.toString(),
                //               filterQuality: FilterQuality.medium,
                //               // fit: BoxFit.fill,
                //               height: MediaQuery.of(context).size.height,
                //               width: fullwidth,
                //             ),
                //
                //           ),
                //           // Back icon
                //           Positioned(
                //             top: 16.0,
                //             left: 16.0,
                //             child: IconButton(
                //               icon: Icon(Icons.arrow_back, color: Colors.white),
                //               onPressed: () {
                //                 Navigator.pop(context);
                //               },
                //             ),
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                // );
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      insetPadding: EdgeInsets.all(0),
                      backgroundColor: Colors
                          .transparent, // Optional: to make the background transparent
                      child: Stack(
                        children: [
                          // Full-screen image
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: G.HOST +
                                  "api/v1/images/" +
                                  widget.messageData.fileName.toString(),
                              filterQuality: FilterQuality.medium,
                              fit: BoxFit
                                  .cover, // Make sure the image covers the entire screen
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          // Back icon
                          Positioned(
                            top: 16.0,
                            left: 16.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(
                                    0xFFFF6701), // Semi-transparent color for the glass effect
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners for better aesthetics
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 10.0,
                                      sigmaY: 10.0), // Blur effect
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      weight: 20,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
                // Dialog(child:
                // Container(
                //
                //   // width: MediaQuery.of(context).size.width-30,
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Image.network(
                //         G.HOST + "api/v1/images/" + messageData.fileName.toString()),
                //   ),
                // ),
                // );
              },
              child: Container(
                  decoration: ShapeDecoration(
                    color: RuntimeStorage().PrimaryOrange,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(
                        G.HOST +
                            "api/v1/images/" +
                            widget.messageData.fileName.toString(),
                      ),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
                    shadows: [Shadoww],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width / 2,
                  child: Stack(
                    children: [
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                                 width: 60,
                              height: 30,
                              decoration: BoxDecoration(

                                // color: Color(
                                //     0xFFFF6701), // Semi-transparent color for the glass effect
                                // borderRadius: BorderRadius.circular(
                                //     12), // Rounded corners for better aesthetics
                              ),
                              child:  ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 10.0,
                                      sigmaY: 10.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Ensure the row takes only the space it needs
                                    // crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Text(
                                          formattedTime,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: Color(0xFFFFEADC),
                                            fontSize: 10,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      widget.messageData.messageStatus == "read"
                                          ? SvgPicture.asset("assets/blueTick.svg")
                                          : widget.messageData.messageStatus == "sent"
                                          ? SvgPicture.asset(
                                          "assets/whiteTick.svg")
                                          : SvgPicture.asset(
                                        "assets/messageNotSent.svg",
                                        width: 13,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                          ))
                    ],
                  )),
            );
          }
        case 'Video':
          {
            return GestureDetector(
              onTap: () {
                log("clickeddd on video");
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PopScope(
                      onPopInvoked: (e) async {
                        if (e) {
                          await _controller.pause();
                        }
                      },
                      child: Material(
                        child: Column(
                          children: [
                            Expanded(
                              child: Chewie(
                                controller: _chewieController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                  decoration: ShapeDecoration(
                    shadows: [Shadoww],
                    color: Color(0xFFFFEADC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                  width: 100,
                  child: isLoading
                      ? SizedBox(height: 10, child: CircularProgressIndicator())
                      : SizedBox(
                          width: 50,
                          height: 50,
                          child: Center(child: Text("Video")))
                  // Stack(children: [Icon().,Image.memory(thumbnailBytes)]), // Display the thumbnail

                  // Padding(
                  //
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Text("video")
                  //
                  //
                  // ),
                  ),
            );

            Text("video");
          }
        case 'Document':
          {
            return GestureDetector(
                onTap: () async {
                  Uri temp = Uri.parse(G.HOST +
                      "api/v1/images/" +
                      widget.messageData.fileName.toString());
                  if (await canLaunchUrl(temp)) {
                    await launchUrl(temp, mode: LaunchMode.platformDefault);
                  } else {
                    // Handle the case where the URL couldn't be launched.
                    // You might want to show an error message to the user.
                    print('Could not launch $temp');
                  }
                },
                child: Container(
                  width: 40,
                  decoration: ShapeDecoration(
                    shadows: [Shadoww],
                    color: Color(0xFFFFEADC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                  child: Image.asset(
                    "assets/pdfLogo.png",
                    width: 30,
                  ),
                ));
          }
        default:
          {
            return Text("none");
          }
      }
    }

    return sentByMe
        ? Padding(
            padding: const EdgeInsets.only(right: 20, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                widget.messageData.fileName != null
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FileShowWidget(fileType),
                      )
                    : Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width /
                                2, // Set your maximum width here
                            minHeight: 40),

                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        // margin: EdgeInsets.only(right: 20, bottom: 4),
                        decoration: ShapeDecoration(
                          color: Color(0xFFFF6701),
                          shadows: [Shadoww],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom:
                                      0), // Adjust the bottom padding to create space for the Positioned content
                              child: RichText(
                                text: TextSpan(
                                  text: widget.messageData.message,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Ensure the row takes only the space it needs
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Text(
                                    formattedTime,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: Color(0xFFFFEADC),
                                      fontSize: 10,
                                      fontFamily: 'Helvetica',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                widget.messageData.messageStatus == "read"
                                    ? SvgPicture.asset("assets/blueTick.svg")
                                    : widget.messageData.messageStatus == "sent"
                                        ? SvgPicture.asset(
                                            "assets/whiteTick.svg")
                                        : SvgPicture.asset(
                                            "assets/messageNotSent.svg",
                                            width: 13,
                                            color: Colors.white,
                                          )
                              ],
                            ),
                            // Positioned(
                            //   right: 0,
                            //   bottom: 0,
                            //   child: Row(
                            //     crossAxisAlignment: CrossAxisAlignment.end,
                            //     children: [
                            //       Padding(
                            //         padding: const EdgeInsets.only(right: 4),
                            //         child: Text(
                            //           formattedTime,
                            //           textAlign: TextAlign.end,
                            //           style: TextStyle(
                            //             color: Color(0xFFFFEADC),
                            //             fontSize: 10,
                            //             fontFamily: 'Helvetica',
                            //             fontWeight: FontWeight.w400,
                            //           ),
                            //         ),
                            //       ),
                            //       widget.messageData.messageStatus=="read"?
                            //       SvgPicture.asset("assets/blueTick.svg"):widget.messageData.messageStatus=="sent"?
                            //            SvgPicture.asset("assets/whiteTick.svg"):
                            //       SvgPicture.asset("assets/messageNotSent.svg",width: 13,color: Colors.white,)
                            //
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                        // Stack(
                        //   clipBehavior: Clip.hardEdge,
                        //   children: [
                        //     Padding(
                        //       padding: const EdgeInsets.only(bottom: 20),
                        //       child: RichText(
                        //           text: TextSpan(
                        //               text: widget.messageData.message,
                        //               style: TextStyle(
                        //                 color: Colors.white,
                        //                 fontSize: 14,
                        //                 fontFamily: 'Helvetica',
                        //                 fontWeight: FontWeight.w400,
                        //               ),
                        //               children: [
                        //             WidgetSpan(
                        //                 child: Column(
                        //               children: [
                        //                 SizedBox(
                        //                   height: 10,
                        //                   width: 60,
                        //                 )
                        //               ],
                        //             ))
                        //           ])),
                        //     ),
                        //     Positioned(
                        //       right: 0,
                        //       bottom: 0,
                        //       child: Row(
                        //         children: [
                        //           Padding(
                        //             padding: const EdgeInsets.only(right: 0),
                        //             child: Text(
                        //               formattedTime,
                        //               textAlign: TextAlign.end,
                        //               style: TextStyle(
                        //                 color: Color(0xFFFFEADC),
                        //                 fontSize: 10,
                        //                 fontFamily: 'Helvetica',
                        //                 fontWeight: FontWeight.w400,
                        //               ),
                        //             ),
                        //           ),
                        //           Text(
                        //             widget.messageData.messageStatus,
                        //             // style: TextStyle(
                        //             //   color: Color(0xFFFFEADC),
                        //             //   fontSize: 10,
                        //             //   fontFamily: 'Helvetica',
                        //             //   fontWeight: FontWeight.w400,
                        //             // ),
                        //           )
                        //           // ?
                        //           // // Text("DELIVERED"):Text("SEEN ")
                        //           // SvgPicture.asset("assets/blueTick.svg")
                        //           // : SvgPicture.asset("assets/whiteTick.svg")
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Text(
                //       messageData.time.toString().substring(11, 16),
                //       textAlign: TextAlign.end,
                //       style: TextStyle(
                //         color: Color(0xFF707070),
                //         fontSize: 10,
                //         fontFamily: 'Helvetica',
                //         fontWeight: FontWeight.w400,
                //         height: 1.60,
                //       ),
                //     ),
                //     SizedBox(
                //       width: 4,
                //     ),
                //     SvgPicture.asset("assets/ReadCheck.svg")
                //   ],
                // ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.messageData.groupId != null
                    ? Container(
                        constraints: BoxConstraints(
                          maxWidth: 250.0,
                        ),
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        decoration: ShapeDecoration(
                          color: Color(0xFFF2F2F2),
                          shadows: [Shadoww],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(widget.messageData.message + "yiyiuui"),
                            ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool('isJoinedRoom', true);
                                  await prefs.setString("JoinedRoomId",
                                      widget.messageData.groupId.toString());
                                  await prefs.setString("JoinedRoomName",
                                      widget.messageData.groupName.toString());
                                  pageProviderService pageService =
                                      Provider.of(context, listen: false);
                                  ChatRoomsProvider chatroom =
                                      Provider.of(context, listen: false);
                                  chatroom.isFromExplore = true;
                                  pageService.goToPage(1);
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                                child: Text("Join the room"))
                          ],
                        ),
                      )
                    : widget.messageData.fileName != null
                        ? FileShowWidget(fileType)
                        : Container(
                            constraints: BoxConstraints(
                              maxWidth: 250.0, // Set your maximum width here
                            ),
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            decoration: ShapeDecoration(
                              color: Color(0xFFF2F2F2),
                              shadows: [Shadoww],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        228.0, // Set your maximum width here
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                        text: "${widget.messageData.message}",
                                        style: TextStyle(
                                          color: Color(0xFF303030),
                                          fontSize: 14,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.w400,
                                        ),
                                        children: [
                                          WidgetSpan(
                                              child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                                width: 50,
                                              )
                                            ],
                                          ))
                                        ]),
                                  ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: -8,
                                  child: Container(
                                    child: FittedBox(
                                      fit: BoxFit
                                          .scaleDown, // Ensure the text scales down within its constraints
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          formattedTime.toString(),
                                          style: TextStyle(
                                            color: Color(0xFF707070),
                                            fontSize: 10,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
              ],
            ),
          );
  }
}
