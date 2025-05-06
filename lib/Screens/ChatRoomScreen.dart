import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:koram_app/Helper/CommonWidgets.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:path/path.dart' as path;
import 'package:koram_app/Helper/color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koram_app/Helper/ChatSocketServices.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Models/Chat.dart';
import 'package:koram_app/Models/ChatRoom.dart';
import 'package:koram_app/Models/Message.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Widget/GroupMessage.dart';
import 'package:koram_app/Widget/NewMessage.dart';
import 'package:koram_app/Widget/ParticipantSheet.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:koram_app/Models/Notification.dart' as N;

import '../Helper/ChatSocketServices.dart';
import '../Models/User.dart';

class ChatRoomScreenChat extends StatefulWidget {
  ChatRoom groupName;
  Function changeTab;

  ChatRoomScreenChat({required this.groupName, required this.changeTab});

  @override
  _ChatRoomScreenChatState createState() => _ChatRoomScreenChatState();
}

class _ChatRoomScreenChatState extends State<ChatRoomScreenChat>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<GroupMessage> _message = [];
  TextEditingController _msgInput = TextEditingController();
  late bool isLoading = false;
  List members = [];
  String RoomId = "";
  FocusNode _focusNode = FocusNode();
  List<UserDetail> userCopy = [];
  String hintText = "Search Here";
  TextEditingController theSearch = new TextEditingController();
  UserDetail? loggedUserData;
  List<File>? _selectedFile = [];
  List<File>? _selectedVideo = [];
  ChatRoom? RoomUpdated;
  double theMaxScrollPixel = 0.0;
  bool hasReachedEnd = false;
  final ScrollController _scrollController = ScrollController();
  int counter = 0;
  void sendAppInvite() {
    String downloadLink =
        'https://play.google.com/apps/internaltest/4701747546792537740';
    String message =
        "Hey, join me on Koram! It's a chat app where you can chat with friends and meet new people nearby. Download it now! \n$downloadLink";

    String url = downloadLink; // Make sure this contains your actual URL

    Share.share("$message\n\n$url", subject: "Hey, join me on Koram!");
  }

  void sendChatroomInvite(UsersProviderClass UserClass, String chatRommId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 2,
      useSafeArea: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Send Chatroom Invite",
                style: TextStyle(fontSize: 20),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 2,
                color: Colors.white,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: UserClass.finalFriendsList.length,
                  itemBuilder: (context, index) => ListTile(
                    title:
                        Text("${UserClass.finalFriendsList[index].publicName}"),
                    onTap: () {},
                    leading: Container(
                      width: 31,
                      height: 31,
                      decoration: ShapeDecoration(
                        image: UserClass.finalFriendsList[index]
                                    .publicProfilePicUrl !=
                                ""
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(G.HOST +
                                    "api/v1/images/" +
                                    UserClass.finalFriendsList[index]
                                        .publicProfilePicUrl!),
                                fit: BoxFit.fill,
                              )
                            : DecorationImage(
                                image: AssetImage(
                                  "assets/profile.png",
                                ),
                                fit: BoxFit.fill,
                              ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(49),
                        ),
                      ),
                    ),
                    // CircleAvatar(
                    //   child: CachedNetworkImage(
                    //     filterQuality: FilterQuality.low,
                    //     imageUrl: G.HOST +
                    //         "api/v1/images/" +
                    //         UserClass.finalFriendsList[index]
                    //             .publicProfilePicUrl!,
                    //     width: 50,
                    //     height: 50,
                    //   ),
                    //
                    // ),
                    trailing: TextButton(
                      child: Text(
                        "Send Invite",
                        style: TextStyle(color: RuntimeStorage().PrimaryOrange),
                      ),
                      onPressed: () {
                        try {
                          Provider.of<ChatSocket>(context, listen: false)
                              .sendRoomInvite(
                            widget.groupName,
                            UserClass.finalFriendsList[index].phoneNumber!,
                          );
                          log("sending invite");
                          Navigator.pop(context);
                          CommanWidgets().showSnackBar(context,
                              "Group invite sent Successfully", Colors.green);
                        } catch (e) {
                          CommanWidgets().showSnackBar(
                              context,
                              "Error while sending invite,Please try later",
                              Colors.red);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    log("chat room  screen init called");
    // TODO: implement initState
    super.initState();
    _focusNode.addListener(_onFocusChange);
    ChatRoomsProvider.isChangePage = false;
    Future.delayed(Duration.zero).then((value) async {
      setState(() {
        isLoading = true;
      });

      // if(widget.isAlreadyJoined==true)
      // {
      //   RoomId=widget.ChatRoomId;
      // }else
      // {
      //   RoomId=widget.groupName!.id;
      // }
      await Provider.of<Messages>(context, listen: false)
          .fetchMessageByGroup(widget.groupName.id!);
      // List user = widget.groupName.users;
      // print("here" + widget.groupName.users.toString());
      // user.add(G.userId);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      log("userdataaa ${prefs.getString("LoggedInUserData")!}");

      loggedUserData =
          UserDetail.fromJson(jsonDecode(prefs.getString("LoggedInUserData")!));
      log("userdetails22 ${loggedUserData?.privateName}");

      log("userdetails ${loggedUserData?.toJson()}");
      int? index = widget.groupName.users!
          .indexWhere((u) => u.userphoneNumber == G.userPhoneNumber);
      log("the indexxx ${index}");
      // if(index==-1)
      // {
      await Provider.of<ChatRoomsProvider>(context, listen: false).addUsers(
          loggedUserData!.publicName!,
          G.userPhoneNumber,
          loggedUserData!.publicProfilePicUrl ?? "",
          widget.groupName.id!,
          false);
      log("sending jpined room");
     if (mounted){
       Provider.of<ChatSocket>(context, listen: false)
          .sendJoinedRoom(G.userPhoneNumber, widget.groupName.id!);
     }
      // }
      _scrollToBottom();
    });

    super.initState();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (_scrollController.position.pixels <
            _scrollController.position.maxScrollExtent) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          await Future.delayed(Duration(milliseconds: 300));
        }

        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          setState(() {
            hasReachedEnd = true;
            isLoading = false;
          });
          log("Scroll to bottom: $hasReachedEnd, counter: $counter");
        }

        theMaxScrollPixel = _scrollController.position.maxScrollExtent;
        log("Saved max scroll: $theMaxScrollPixel, current scroll: ${_scrollController.position.maxScrollExtent}");

        if (!hasReachedEnd) {
          _scrollToBottom();
        }
      } catch (e) {
        log("Error while scrolling: $e");
        _scrollToBottom();
      }
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        hintText = ""; // Remove hint text when focused
      });
    } else {
      setState(() {
        hintText = "Search Here"; // Show hint text when not focused
      });
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    ChatRoomsProvider chatRoomProviderLocal =
        Provider.of<ChatRoomsProvider>(context, listen: false);
    chatRoomProviderLocal
        .fetchChatRoomById(widget.groupName.id!)
        .then((theResponse) {
      log("the fetch chat room ${theResponse!.userDetails!.length}");
      if (theResponse != null) {
        RoomUpdated = theResponse;
        userCopy = theResponse.userDetails!;
        setState(() {});
        log("after the upate ${RoomUpdated!.userDetails!.length}");
      } else {
        log("the fetch respones for update chatroom was null");
      }
    });
    Provider.of<UsersProviderClass>(context, listen: false).getFriends();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _msgInput.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _captureImage(
      Messages chatMessage, ChatSocket c, BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 30);

    if (image != null) {
      File? croppedImage = await G().cropImage(image, context);
      var request =
          http.MultipartRequest('POST', Uri.parse(G.HOST + "api/v1/images"));
      request.files.add(http.MultipartFile(
        'image', // Field name for the file
        http.ByteStream(croppedImage!.openRead()),
        await croppedImage.length(),
        filename: path.basename(croppedImage.path),
      ));

      var response = await request.send();

      response.stream.transform(utf8.decoder).listen((value) async {
        json.decode(value)[0]["mediaName"];
        log("REsponse Stram ");
        print(json.decode(value));

        var messageJson = {
          "senderPublicName": loggedUserData?.publicName,
          "message": _msgInput.text,
          "sentBy": G.userPhoneNumber,
          "group": true,
          "groupId": widget.groupName.id,
          "time": DateTime.now().toString(),
          "fileName": json.decode(value)[0]["mediaName"]
        };
        await chatMessage.addMessage(
            _msgInput.text,
            loggedUserData!.publicName!,
            G.userPhoneNumber,
            widget.groupName.id!,
            DateTime.now().toString(),
            true,
            json.decode(value)[0]["mediaName"]);

        c.sendMessage(messageJson);
      });

      await chatMessage.fetchMessageByGroup(widget.groupName.id!);
      setState(() {});
      _scrollToBottom();
      _msgInput.text = "";
    }
  }

  Future<void> _uploadFiles(
      Messages chatMessage, ChatSocket c, BuildContext context) async {
    String uploadUrl =
        G.HOST + "api/v1/saveImg"; // Replace with your actual backend endpoint
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    for (var file in _selectedFile ?? []) {
      log("filee ### ${file.absolute} ");
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      var filename;

      response.stream.transform(utf8.decoder).listen((value) {
        log("response of uploaded file ");
        print(json.decode(value));
        Map<String, dynamic> jsonData = jsonDecode(value.toString());

        // Access the values
        String message = jsonData['message'];
        List<String> savedFiles = List<String>.from(jsonData['savedFile']);
        print('Files uploaded successfully');
        savedFiles.forEach((filename) async {
          log("filename### $filename");

          var messageJson = {
            "senderPublicName": loggedUserData?.publicName,
            "message": _msgInput.text,
            "sentBy": G.userPhoneNumber,
            "group": true,
            "groupId": widget.groupName.id,
            "time": DateTime.now().toString(),
            "fileName": filename
          };
          log("Message json $messageJson");
          await chatMessage.addMessage(
              _msgInput.text,
              loggedUserData!.publicName!,
              G.userPhoneNumber,
              widget.groupName.id!,
              DateTime.now().toString(),
              true,
              filename);
          // socket.emit("message", json.encode(messageJson));
          c.sendMessage(messageJson);

          setState(() {});
          print(_message);
          _msgInput.text = "";
        });
      });
      await chatMessage.fetchMessageByGroup(widget.groupName.id!);

      // Print the values
      setState(() {});
      _scrollToBottom();
    } else {
      print('Failed to upload files. Status code: ${response.statusCode}');
    }
  }

  Future<void> uploadVideo(Messages chatMessage, ChatSocket c) async {
    String uploadVideoUrl = G.HOST + "api/v1/saveVideo";

    var request = http.MultipartRequest('POST', Uri.parse(uploadVideoUrl));
    for (var file in _selectedVideo ?? []) {
      request.files.add(await http.MultipartFile.fromPath('videos', file.path));
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      response.stream.transform(utf8.decoder).listen((value) {
        log("response of uploaded video ");
        print(json.decode(value));
        Map<String, dynamic> jsonData = jsonDecode(value.toString());

        // Access the values
        String message = jsonData['message'];
        List<String> savedFiles = List<String>.from(jsonData['savedFile']);
        print('video uploaded successfully');
        // Handle the server response as needed
        savedFiles.forEach((filename) async {
          log("filename### $filename");

          var messageJson = {
            "senderPublicName": loggedUserData?.publicName,
            "message": _msgInput.text,
            "sentBy": G.userPhoneNumber,
            "group": true,
            "groupId": widget.groupName.id,
            "time": DateTime.now().toString(),
            "fileName": filename
          };
          await chatMessage.addMessage(
              _msgInput.text,
              loggedUserData!.publicName!,
              G.userPhoneNumber,
              widget.groupName.id!,
              DateTime.now().toString(),
              true,
              filename);
          // socket.emit("message", json.encode(messageJson));
          c.sendMessage(messageJson);

          // PrivateMessage pvtMessage = PrivateMessage.fromMap(messageJson);
        });

        // socket.emit("message", json.encode(messageJson));

        // setState(() {
        //   // _message.add(GroupMessage(
        //   //     message: messageJson["message"],
        //   //     sentTime: DateTime.parse(messageJson["time"]),
        //   //     sentFrom: messageJson["sentBy"],
        //   //     groupId: messageJson["groupId"]));
        // });

        print(_message);
        _msgInput.text = "";

        // Print the values
        print('Message: $message');
        print('Saved Files: $savedFiles');
        // filename=json.decode(value)[0]["mediaName"];
      });
      await chatMessage.fetchMessageByGroup(widget.groupName.id!);
      setState(() {});
      _scrollToBottom();
    } else {
      print('Failed to upload files. Status code: ${response.statusCode}');
    }
  }

  Future<void> _pickFile(Messages chatMessage, ChatSocket c) async {
    try {
      log("ChatMEssage ${chatMessage}");
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: true);
      List<PlatformFile> tempVideo = [];
      List<PlatformFile> otherFiles = [];
      if (result != null) {
        log("Pathh ${result.files.first.path} EXTTTT ${result.files.first.extension}  Identifiess${result.files.first.identifier}");

        result.files.forEach((k) {
          if (k.identifier!.contains("video")) {
            log("adding video ${k.path}");
            tempVideo.add(k);
          } else {
            log("adding otherfiles ${k.path}");
            otherFiles.add(k);
          }
        });
        if (otherFiles.isNotEmpty) {
          _selectedFile =
              otherFiles.map((element) => File(element.path!)).toList();
          _uploadFiles(chatMessage, c, context);
        }
        if (tempVideo.isNotEmpty) {
          log("not empty videoo");
          _selectedVideo =
              tempVideo.map((element) => File(element.path!)).toList();
          uploadVideo(chatMessage, c);
        }
      } else {
        log("users cancelled picking");
        // User canceled the picker
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  void onSubmit(Messages chatMessage, ChatSocket c) async {
    log("message on submit chatroom ${_msgInput.text}");
    if (_msgInput.text == "") {
      log("inside null text");
      return;
    }
    ;

    var messageJson = {
      "senderPublicName": loggedUserData?.publicName,
      "message": _msgInput.text,
      "sentBy": G.userPhoneNumber,
      "group": true,
      "groupId": widget.groupName.id,
      "time": DateTime.now().toString()
    };
    await chatMessage.addMessage(
        _msgInput.text,
        loggedUserData!.publicName!,
        G.userPhoneNumber,
        widget.groupName.id!,
        DateTime.now().toString(),
        true,
        "");
    // socket.emit("message", json.encode(messageJson));
    c.sendMessage(messageJson);

    // setState(() {
    //   // _message.add(GroupMessage(
    //   //     message: messageJson["message"],
    //   //     sentTime: DateTime.parse(messageJson["time"]),
    //   //     sentFrom: messageJson["sentBy"],
    //   //     groupId: messageJson["groupId"]));
    // });

    setState(() {});
    print(_message);
    _msgInput.text = "";

    await chatMessage.fetchMessageByGroup(widget.groupName.id!);
    _scrollToBottom();
  }

  SendMessageDialouge(UserDetail theRoomUser) {
    String txt = "";
    bool isloggedUser = theRoomUser.phoneNumber == G.userPhoneNumber;

    return showDialog(
        context: context,
        builder: (ctx) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
              child: Container(
                width: 350,
                height: 290,
                child: Column(
                  children: [
                    SizedBox(
                      height: 18,
                    ),
                    Text(
                      'Sending Message to',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 16,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                    SizedBox(
                      height: 22,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: ShapeDecoration(
                        image: theRoomUser.publicProfilePicUrl != ""
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(G.HOST +
                                    "api/v1/images/" +
                                    theRoomUser.publicProfilePicUrl!),
                                // : CachedNetworkImageProvider(G.HOST + "api/v1/images/" + theRoomUser.privateProfilePicUrl!),
                                fit: BoxFit.fill,
                              )
                            : DecorationImage(
                                image: AssetImage(
                                  "assets/profile.png",
                                ),
                                fit: BoxFit.fill,
                              ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(49),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '${theRoomUser.publicName}',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                      child: TextField(
                        onChanged: (c) {
                          txt = c;
                        },
                        autofocus: false,
                        maxLines: 6,
                        style: TextStyle(
                          color: Color(0xFF484848),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(36.04)),
                          hintText: 'Say “Hello”',
                          fillColor: Color(0xFFF4F4F7),
                          filled: true,
                          // prefix: SvgPicture.asset("assets/star.svg")
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 18, right: 18, bottom: 19),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await Provider.of<N.Notifications>(context,
                                        listen: false)
                                    .addNotification(
                                        txt,
                                        theRoomUser.phoneNumber!,
                                        G.userPhoneNumber);
                                Navigator.of(context).pop();
                                // SnackBar
                              },
                              child: Container(
                                  width: 151,
                                  height: 44,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFF2F2F2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                      child: Text(
                                    'Cancel',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF707070),
                                      fontSize: 12,
                                      fontFamily: 'Helvetica',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                    ),
                                  ))),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await Provider.of<N.Notifications>(context,
                                        listen: false)
                                    .addNotification(
                                        txt,
                                        theRoomUser.phoneNumber!,
                                        G.userPhoneNumber);
                                Navigator.of(context).pop();
                                // SnackBar
                              },
                              child: Container(
                                  width: 151,
                                  height: 44,
                                  decoration: ShapeDecoration(
                                    color: backendColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                      child: Text(
                                    'Send Request',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Helvetica',
                                      fontWeight: FontWeight.w700,
                                      height: 0,
                                    ),
                                  ))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    UsersProviderClass UserClass =
        Provider.of<UsersProviderClass>(context, listen: false);
    ChatSocket chatdata = Provider.of<ChatSocket>(context, listen: true);
    ChatRoomsProvider chatRoomProviderLocal =
        Provider.of<ChatRoomsProvider>(context, listen: false);

    if (chatdata.chatRoomOnLeft != null) {
      log("inside the chatroom not null listener ${chatdata.chatRoomOnLeft['userPhoneNumber']}");
      int? index = widget.groupName.userDetails!.indexWhere(
          (u) => u.phoneNumber == chatdata.chatRoomOnLeft['userPhoneNumber']);
      log("the indexxx ${index}");
      if (index != -1) {
        log("removing the user from list");
        widget.groupName.userDetails!.removeAt(index);
        RoomUpdated!.userDetails!.removeAt(index);
      }
      userCopy = RoomUpdated!.userDetails!;
      chatdata.chatRoomOnLeft = null;
    }
    if (chatdata.chatRoomOnJoin != null) {
      int? index = widget.groupName.userDetails!.indexWhere(
          (u) => u.phoneNumber == chatdata.chatRoomOnJoin['userPhoneNumber']);
      log("the indexxx in join${index}");
      if (index != -1) {
        chatdata.chatRoomOnJoin = null;

        chatRoomProviderLocal
            .fetchChatRoomById(widget.groupName.id!)
            .then((theResponse) {
          log("the fetch chat room ${theResponse!.userDetails!.length}");
          if (theResponse != null) {
            widget.groupName = theResponse;
            RoomUpdated = theResponse;
            userCopy = theResponse.userDetails!;
            setState(() {});
          } else {
            log("the fetch respones for update chatroom was null");
          }
        });
      }
    }

    final height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    final chatMessage = Provider.of<Messages>(context);
    _message = chatMessage.groupMessage;

    _message = _message
        .where((element) => element.groupId == widget.groupName.id)
        .toList();
    log("CHAT MESSAGE OF GROUP ${chatMessage.groupMessage.length}");
    log("notified message data in build of chatroom ${chatdata.messageData}");
    if (chatdata.messageData != null) {
      if (chatdata.messageData["GroupId"] == widget.groupName.id) {
        log("adding message to _message ${chatdata.messageData}");
        _message.add(GroupMessage(
            senderPublicName: chatdata.messageData["senderPublicName"] ?? "",
            message: chatdata.messageData["message"],
            sentTime: DateTime.parse(chatdata.messageData["time"]),
            sentFrom: chatdata.messageData["sentBy"],
            groupId: chatdata.messageData["groupId"]));
      } else {
        log("the group name didnt match ${chatdata.messageData}");
      }
    }

    return PopScope(
      onPopInvoked: (e) async {
        log("pop invoked  chat room screen $e");
        widget.changeTab();

        ChatRoomsProvider.isChangePage = true;
        return;
        // await Prov ider.of<ChatRoomsProvider>(context, listen: false).addUsers(
        //     loggedUserData!.publicName!,
        //     G.userPhoneNumber,
        //     loggedUserData?.publicProfilePicUrl??"",
        //     widget.groupName.id!,
        //     true);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,

          endDrawer: Container(
            width: width - 60,
            height: height,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: theSearch,
                      enabled: true,
                      focusNode: _focusNode,
                      cursorHeight: 15,
                      style: TextStyle(
                        color: Color(0xFF484848),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      autofocus: false,
                      showCursor: true,
                      onChanged: (v) {
                        if (v.isEmpty) {
                          setState(() {
                            RoomUpdated!.userDetails = userCopy;
                          });
                        }
                        List<UserDetail> us = userCopy.where((element) {
                          log("the V ${v}");
                          log("the namess " +
                              element.publicName!.toLowerCase());
                          return element.publicName!
                              .toLowerCase()
                              .startsWith(v.toLowerCase());
                        }).toList();
                        setState(() {
                          RoomUpdated?.userDetails = us;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(36.04)),
                        hintText: hintText,
                        fillColor: Color(0xFFF4F4F7),

                        prefixIcon: Icon(Icons.search),
                        // prefix: SvgPicture.asset("assets/star.svg")
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      sendChatroomInvite(UserClass, widget.groupName.id!);
                    },
                    child: ListTile(
                      horizontalTitleGap: 5,
                      title: Text(
                        "Invite Member",
                        style: TextStyle(
                          color: Color(0xFF303030),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      leading: Container(
                        width: 31,
                        height: 31,
                        decoration: ShapeDecoration(
                          color: backendColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(49),
                          ),
                        ),
                        child: Center(
                            child: SvgPicture.asset(
                          "assets/add-user.svg",
                          color: Colors.white,
                        )),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: RoomUpdated != null
                            ? Text(
                                'Members - ${RoomUpdated!.userDetails?.length}',
                                style: TextStyle(
                                  color: Color(0xFF667084),
                                  fontSize: 14,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.w700,
                                  height: 0,
                                ),
                              )
                            : SizedBox(),
                      ),
                      Expanded(
                        child: SizedBox(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      content: Text("Leave Room ?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              ChatRoomsProvider c = Provider.of<
                                                      ChatRoomsProvider>(
                                                  context,
                                                  listen: false);
                                              await c.addUsers(
                                                  loggedUserData!.publicName!,
                                                  G.userPhoneNumber,
                                                  loggedUserData
                                                          ?.publicProfilePicUrl ??
                                                      "",
                                                  widget.groupName.id!,
                                                  true);
                                              chatdata.sendLeftRoom(
                                                  G.userPhoneNumber,
                                                  widget.groupName.id!);
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs
                                                  .remove('isJoinedRoom');
                                              await prefs
                                                  .remove("JoinedRoomId");
                                              await prefs
                                                  .remove("JoinedRoomName");

                                              c.SelectedRoom = null;
                                              Navigator.pop(context);
                                            },
                                            child: Text("Yes")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("No"))
                                      ],
                                    ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: RuntimeStorage().PrimaryOrange),
                            height: 25,
                            width: 50,
                            child: Center(
                                child: Text(
                              "Leave",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            )),
                          ),
                        ),
                      )
                    ],
                  ),
                  // for(var i in widget.groupName.users)
                  RoomUpdated != null
                      ? ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(0),
                          physics: BouncingScrollPhysics(),
                          itemCount: RoomUpdated!.userDetails?.length ?? 0,
                          itemBuilder: (ctx, i) {
                            log("the user detail in end drawer ${RoomUpdated!.userDetails!.length}");
                            bool isloggedUser =
                                RoomUpdated!.userDetails?[i].phoneNumber ==
                                    G.userPhoneNumber;

                            return ListTile(
                              onTap: () {
                                log("on tap called ");
                                String txt = "";
                                SendMessageDialouge(
                                    RoomUpdated!.userDetails![i]);
                              },
                              dense: true,
                              titleAlignment: ListTileTitleAlignment.center,
                              horizontalTitleGap: 5,
                              minTileHeight: 60,
                              title: Text(
                                '${RoomUpdated!.userDetails?[i].publicName}',
                                style: TextStyle(
                                  color: Color(0xFF303030),
                                  fontSize: 12,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              leading: Container(
                                width: 31,
                                height: 31,
                                decoration: ShapeDecoration(
                                  image: RoomUpdated!.userDetails?[i]
                                              .publicProfilePicUrl !=
                                          ""
                                      ? DecorationImage(
                                          image: isloggedUser
                                              ? CachedNetworkImageProvider(
                                                  G.HOST +
                                                      "api/v1/images/" +
                                                      RoomUpdated!
                                                          .userDetails![i]
                                                          .publicProfilePicUrl!)
                                              : CachedNetworkImageProvider(G
                                                      .HOST +
                                                  "api/v1/images/" +
                                                  RoomUpdated!.userDetails![i]
                                                      .privateProfilePicUrl!),
                                          fit: BoxFit.fill,
                                        )
                                      : DecorationImage(
                                          image: AssetImage(
                                            "assets/profile.png",
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(49),
                                  ),
                                ),
                              ),
                              subtitle: isloggedUser
                                  ? Text(
                                      "you",
                                      style: TextStyle(
                                        color: Color(0xFF303030),
                                        fontSize: 12,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  : SizedBox(),
                              trailing: !isloggedUser
                                  ? GestureDetector(
                                      onTap: () {
                                        log("on tap called ");
                                        SendMessageDialouge(
                                            RoomUpdated!.userDetails![i]);
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 31,
                                        decoration: ShapeDecoration(
                                          color: backendColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(17.41),
                                          ),
                                        ),
                                        child: Center(
                                            child: SvgPicture.asset(
                                          "assets/Layer_1.svg",
                                          color: Colors.white,
                                        )),
                                      ),
                                    )
                                  : SizedBox(),
                            );
                          },
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),

          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FloatingActionButton(
              onPressed: () {
                _scaffoldKey.currentState!.openEndDrawer();
                // showModalBottomSheet(
                //     context: context,
                //     isScrollControlled: true,
                //     builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
                //           return Container(
                //             height: height * .8,
                //             width: width,
                //             child: ParticipantSheet(widget.groupName.users),
                //           );
                //         }));
              },
              elevation: 0.0,
              child: Container(
                width: 59,
                height: 59,
                decoration: ShapeDecoration(
                  color: backendColor,
                  shape: OvalBorder(),
                ),
                child: Center(
                    child: SvgPicture.asset(
                  "assets/2 User.svg",
                  color: Colors.white,
                )),
              ),
            ),
          ),
          body: Container(
            height: height,
            color: Colors.white,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: _scrollController,
                      itemCount: _message.length,
                      itemBuilder: (ctx, i) {
                        bool isLast = false;
                        if (_message.length == i + 1) {
                          isLast = true;
                          log("islast is tue ");
                        }
                        // else{
                        //   isLast = false;
                        // }

                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 60.0 : 0),
                          child: GroupMessageWidget(
                            messageData: _message[i],
                          ),
                        );
                      }),
                ),
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                //   child: Container(
                //     height: 55,
                //     decoration: ShapeDecoration(
                //       color: Color(0xFFF9F9F9),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(27.83),
                //       ),
                //     ),
                //     width: width,
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         SizedBox(
                //           width: 10,
                //         ),
                //         SvgPicture.asset("assets/cameraMessage.svg"),
                //         SizedBox(
                //           width: 10,
                //         ),
                //         Container(
                //           width: 200,
                //           // decoration: ShapeDecoration(
                //           //   color: Color(0xFFF9F9F9),
                //           //   shape: RoundedRectangleBorder(
                //           //     borderRadius: BorderRadius.circular(27.83),
                //           //   ),
                //           // ),
                //           // padding: EdgeInsets.only(left: 20,right: 20),
                //           child: TextField(
                //             controller: _msgInput,
                //             onSubmitted: (v) {
                //               Timer(
                //                 Duration(seconds: 0),
                //                 () => _scrollController.jumpTo(
                //                     _scrollController.position.maxScrollExtent),
                //               );
                //               onSubmit(chatMessage, chatdata);
                //             },
                //             decoration: InputDecoration(
                //                 hintText: "Type here...",
                //                 border: InputBorder.none),
                //           ),
                //         ),
                //         SvgPicture.asset(
                //           "assets/attach.svg",
                //           width: 20,
                //           height: 20,
                //         ),
                //         GestureDetector(
                //           onTap: () {
                //             onSubmit(chatMessage, chatdata);
                //           },
                //           child: Container(
                //             width: 57.58,
                //             height: 42.35,
                //             decoration: ShapeDecoration(
                //               color: backendColor,
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(22.44),
                //               ),
                //             ),
                //             child: Center(
                //                 child: SvgPicture.asset("assets/Send.svg")),
                //           ),
                //
                //           // Container(
                //           //   height: 40,
                //           //   child: Image.asset("assets/Group 516.png"),
                //           // ),
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 5),
                    child: Container(
                      height: 55,
                      decoration: ShapeDecoration(
                        shadows: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 5), // changes position of shadow
                          ),
                        ],
                        color: Color(0xFFF9F9F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27.83),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                              onTap: () {
                                _captureImage(chatMessage, chatdata, context);
                              },
                              child:
                                  SvgPicture.asset("assets/cameraMessage.svg")),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Container(
                              // decoration: ShapeDecoration(
                              //   color: Color(0xFFF9F9F9),
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(27.83),
                              //   ),
                              // ),
                              // padding: EdgeInsets.only(left: 20,right: 20),
                              child: TextField(
                                controller: _msgInput,
                                onSubmitted: (v) {
                                  onSubmit(chatMessage, chatdata);
                                },
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                autofocus: false,
                                maxLines: null,
                                decoration: InputDecoration(
                                    hintText: "Type here...",
                                    border: InputBorder.none),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _pickFile(chatMessage, chatdata);
                            },
                            child: SvgPicture.asset(
                              "assets/attach.svg",
                              width: 20,
                              height: 20,
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          GestureDetector(
                            onTap: () {
                              onSubmit(chatMessage, chatdata);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                width: 57.58,
                                height: 42.35,
                                decoration: ShapeDecoration(
                                  color: backendColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22.44),
                                  ),
                                ),
                                child: Center(
                                    child: SvgPicture.asset("assets/Send.svg")),
                              ),
                            ),

                            // Container(
                            //   height: 40,
                            //   child: Image.asset("assets/Group 516.png"),
                            // ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ),
        ),
      ),
    );
  }
}
