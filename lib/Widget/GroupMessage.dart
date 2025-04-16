import 'dart:developer';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:koram_app/Helper/color.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Models/Message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class GroupMessageWidget extends StatefulWidget {
  final GroupMessage messageData;

  GroupMessageWidget({required this.messageData});

  @override
  State<GroupMessageWidget> createState() => _GroupMessageWidgetState();
}

class _GroupMessageWidgetState extends State<GroupMessageWidget> {
  String formattedTime = "";
  int count = 0;
  BoxShadow Shadoww = BoxShadow(
    color: Colors.grey.withOpacity(0.2),
    spreadRadius: 1,
    blurRadius: 10,
    offset: Offset(0, 5), // changes position of shadow
  );
  var _controller;
  var _chewieController;
  late double spaceWidth;
  bool isFileType = false;
  bool isLoading = true;
  String fileType = "";
  var thumbnailBytes;

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

  @override
  void initState() {
    isLoading = true;
    if (widget.messageData.fileName == null ||
        widget.messageData.fileName == "") {
      isFileType = false;
    } else {
      setState(() {
        isFileType = true;
      });
    }
    // Format the time using intl package
    formattedTime = DateFormat.jm().format(widget.messageData.sentTime);
    if (widget.messageData.message.characters.length > 31) {
      log("more the none line ${widget.messageData.message.characters.length}");
      spaceWidth = 10;
    } else {
      log("within one line ${widget.messageData.message.characters.length} ");
      spaceWidth = widget.messageData.message.characters.length - 31;
      spaceWidth.abs();
    }
    if (widget.messageData.fileName != null) {
      String ext = widget.messageData.fileName!.split(".").last;
      log("Ext $ext");
      fileType = getFileType(ext);
      log("File Type: $fileType");
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
    super.initState();
  }

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
  void dispose() {
    // TODO: implement dispose
    if (fileType == "Video") {
      _controller.dispose();
      _chewieController.dispose();
    }

    super.dispose();
  }

  Widget FileShowWidget(String Type) {
    switch (Type) {
      case 'Image':
        {
          return GestureDetector(
            onTap: () {
              log("clickeddd");
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    // actions: [TextButton(onPressed: (){Navigator.pop(context);}, child: Text("X"))],
                    actionsAlignment: MainAxisAlignment.start,
                    scrollable: true,
                    title: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text("Close")),

                    titleTextStyle: TextStyle(fontSize: 15, color: Colors.red),
                    titlePadding: EdgeInsets.fromLTRB(5, 10, 5, 5),
                    contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 5),
                    content: Container(
                      width: 200,
                      height: 200,

                      // width: MediaQuery.of(context).size.width-30,
                      child: CachedNetworkImage(
                          imageUrl: G.HOST +
                              "api/v1/images/" +
                              widget.messageData.fileName.toString(),
                          filterQuality: FilterQuality.medium),
                    ),
                  );
                  //   Container(
                  //   // width: MediaQuery.of(context).size.width-30,
                  //   child: Image.network(G.HOST +
                  //       "api/v1/images/" +
                  //       widget.messageData.fileName.toString()),
                  // );
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
                color: Color(0xFFFFEADC),
                shadows: [Shadoww],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
              width: MediaQuery.of(context).size.width / 2,
              child: CachedNetworkImage(
                imageUrl: G.HOST +
                    "api/v1/images/" +
                    widget.messageData.fileName.toString(),
                filterQuality: FilterQuality.low,
                imageBuilder: (context, imageProvider) {
                  count++;

                  // if(widget.totalMessageCount==widget.currentIndex+1)
                  // {  log("image builderr ${widget.totalMessageCount} indexx ${widget.currentIndex}");
                  //
                  // }
                  return Image(image: imageProvider);
                },
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    bool sentByMe = widget.messageData.sentFrom == G.userPhoneNumber;

    return sentByMe
        // ? Align(
        //     alignment: Alignment.centerRight,
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.end,
        //       children: [
        //         Container(
        //           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        //           margin: EdgeInsets.only(left: 100, right: 10, bottom: 10),
        //           // decoration: BoxDecoration(
        //           //     borderRadius: BorderRadius.only(
        //           //         bottomRight: Radius.circular(20),
        //           //         topLeft: Radius.circular(20),
        //           //         bottomLeft: Radius.circular(20)),
        //           //     color: backendColor),
        //           decoration: ShapeDecoration(
        //             color:  Color(0xFFFFEADC),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.only(
        //                 topRight: Radius.circular(10),
        //                 bottomLeft: Radius.circular(10),
        //                 bottomRight: Radius.circular(10),
        //               ),
        //             ),),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.end,
        //             children: [
        //               Text(
        //                 widget.messageData.message,
        //                 style: TextStyle(
        //                   color: Color(0xFF303030),
        //                   fontSize: 15,
        //                   fontFamily: 'Poppins',
        //                   fontWeight: FontWeight.w400,
        //                 ),
        //               ),
        //               // Align(
        //               //   alignment: Alignment.centerRight,
        //               // child:
        //
        //               // ),
        //             ],
        //           ),
        //         ),
        //         Padding(
        //           padding: EdgeInsets.only(left: 100, right: 10, bottom: 10),
        //           child: Text(
        //             formattedTime,
        //             style: TextStyle(fontSize: 10, color: Colors.black),
        //           ),
        //         ),
        //       ],
        //     ),
        //   )
        // : Align(
        //     alignment: Alignment.centerLeft,
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Container(
        //           padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        //           margin: EdgeInsets.only(right: 100, left: 10, bottom: 10),
        //           // decoration: BoxDecoration(
        //           //     borderRadius: BorderRadius.only(
        //           //         bottomRight: Radius.circular(20),
        //           //         topRight: Radius.circular(20),
        //           //         bottomLeft: Radius.circular(20)),
        //           //     color: Colors.white),
        //           decoration: ShapeDecoration(
        //             color: Color(0xFFF2F2F2),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.only(
        //                 topRight: Radius.circular(10),
        //                 bottomLeft: Radius.circular(10),
        //                 bottomRight: Radius.circular(10),
        //               ),
        //             ),
        //           ),
        //
        //
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Padding(
        //                 padding: const EdgeInsets.only(top:10,bottom: 5),
        //                 child: Text(
        //                   widget.messageData.senderPublicName,
        //                   style: TextStyle(
        //                     color: backendColor,
        //                     fontSize: 12,
        //                     fontFamily: 'Poppins',
        //                     fontWeight: FontWeight.w500,
        //                     height: 0.20,
        //                   ),
        //                 ),
        //               ),
        //               Text(
        //                 widget.messageData.message,
        //                 style: TextStyle(
        //                   color: Color(0xFF303030),
        //                   fontSize: 15,
        //                   fontFamily: 'Poppins',
        //                   fontWeight: FontWeight.w400,
        //                 ),
        //               ),
        //               // Align(
        //               //   alignment: Alignment.centerRight,
        //               //   child:
        //
        //               // ),
        //             ],
        //           ),
        //         ),
        //         Container(
        //           margin: EdgeInsets.only(right: 100, left: 10, bottom: 10),
        //           child: Text(
        //             formattedTime,
        //             textAlign: TextAlign.end,
        //             style: TextStyle(fontSize: 10,color: Colors.black),
        //           ),
        //         ),
        //       ],
        //     ),
        //   );

        ? Padding(
            padding: const EdgeInsets.only(right: 20, top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                isFileType
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FileShowWidget(fileType),
                      )
                    : Container(
                        constraints: BoxConstraints(
                          maxWidth: 250.0, // Set your maximum width here
                        ),
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        // margin: EdgeInsets.only(right: 20, bottom: 4),
                        decoration: ShapeDecoration(
                          color: backendColor,
                          shadows: [Shadoww],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            RichText(
                                text: TextSpan(
                                    text: widget.messageData.message,
                                    style: TextStyle(
                                      color: Colors.white,
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
                                        width: 60,
                                      )
                                    ],
                                  ))
                                ])),
                            Positioned(
                              right: -1,
                              bottom: -5,
                              child: Row(
                                children: [
                                  Text(
                                    formattedTime,
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: Color(0xFFFFEADC),
                                      fontSize: 10,
                                      fontFamily: 'Helvetica',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  // widget.messageData.isDelivered
                                  //     ?
                                  // Text("DELIVERED"):Text("SEEN ")
                                  // SvgPicture.asset("assets/blueTick.svg")
                                  //     :
                                  SvgPicture.asset("assets/whiteTick.svg")
                                ],
                              ),
                            ),
                          ],
                        ),
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
                Text(widget.messageData.senderPublicName,
                    style: TextStyle(fontSize: 11)),
                isFileType
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
                                maxWidth: 228.0, // Set your maximum width here
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
                                // color: Colors.red,
                                width: 50,
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
                          ],
                        ),
                      ),
              ],
            ),
          );
  }
}
