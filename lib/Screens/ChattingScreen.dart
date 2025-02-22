import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koram_app/Helper/CallSocketServices.dart';
import 'package:koram_app/Helper/ConnectivityProviderService.dart';
import 'package:koram_app/Helper/DBHelper.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Models/ChatRoom.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:path/path.dart' as path;

import 'package:koram_app/Models/Message.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Screens/AudioCalling.dart';
import 'package:koram_app/Screens/VideoCallingScreen.dart';
import 'package:koram_app/Widget/NewMessage.dart';
// import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

import '../Helper/ChatSocketServices.dart';
import '../Helper/CommonWidgets.dart';

class ChattingScreen extends StatefulWidget with RouteAware {
  UserDetail? otherUserDetail;
  Function? callBack;
  String? otherUserNumber;
  ChattingScreen({this.otherUserDetail, this.callBack, this.otherUserNumber});

  @override
  _ChattingScreenState createState() => _ChattingScreenState();
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

class _ChattingScreenState extends State<ChattingScreen>
    with WidgetsBindingObserver {
  final Uuid uuid = Uuid();
  ScrollController _scrollController = ScrollController();

  TextEditingController _msgInput = TextEditingController();
  // late IO.Socket socket;
  late BuildContext buildContext;
  List<PrivateMessage> allPvtMessage = [];
  List<PrivateMessage> PvtMessageShowOnScreen = [];
  List<File>? _selectedFile = [];
  List<File>? _selectedVideo = [];
  bool isFriend = false;
  bool displayOptions = false;
  final FocusNode textFocusNode = FocusNode();
  int countDependency = 0;
  bool _isProcessingCAll = false;
  int countofSocket = 0;

  startFunctions(String num) async {
    // PvtMessage = ChatSocket().getMessageByPhoneRuntime(num);
    // PvtMessage = await DBProvider.db
    //     .getPrivateMessageByPhone(num);
    if (G.loggedinUser.friendList != null) {
      isFriend = G.loggedinUser.friendList!.contains(num);
    }
    PvtMessageShowOnScreen = await DBProvider.db.getPrivateMessageByPhone(
        widget.otherUserDetail?.phoneNumber ?? widget.otherUserNumber!);
    PvtMessageShowOnScreen.where((e)=>e.isSeen==false);
    List<PrivateMessage>convertedList=PvtMessageShowOnScreen;

    for(int i=0;i<PvtMessageShowOnScreen.length;i++)
    {
      if(PvtMessageShowOnScreen[i].isSeen==false)
      {   log("orivate mwessage with seen false ${PvtMessageShowOnScreen[i].message} ");
        convertedList[i].isSeen= true;
      }

    }
  PvtMessageShowOnScreen=convertedList;
    var res=await DBProvider.db.updateListMessageIsSeen(widget.otherUserDetail!.phoneNumber??widget.otherUserNumber!);

    _scrollToBottom();
    setState(() {});
  }

  sendUnsentMessage(
    ChatSocket chatsock,
  ) async {
    log("sending list of unsent");
    List<PrivateMessage> PvtMessageOnDb = await DBProvider.db
        .getPrivateMessageByPhone(
            widget.otherUserDetail?.phoneNumber ?? widget.otherUserNumber!);
    log("the message length ${PvtMessageOnDb.length}");
    List<PrivateMessage> unsent =
        PvtMessageOnDb.where((message) => message.messageStatus == "notSent")
            .toList();

    if (unsent.isEmpty) {
      log("unsent message is empty");
      return;
    }
    await chatsock.sendListOfUnsentMessage(
        jsonEncode(unsent.map((message) => message.toMap()).toList()), unsent);
  }

  getUpdatedList(String num) async {
    // PvtMessage = ChatSocket().getMessageByPhoneRuntime(num);
    // PvtMessage = await DBProvider.db
    //     .getPrivateMessageByPhone(num);
    log("get updated list called ");
    PvtMessageShowOnScreen = await DBProvider.db.getPrivateMessageByPhone(
        widget.otherUserDetail?.phoneNumber ?? widget.otherUserNumber!);
    log("the status of last message  ${PvtMessageShowOnScreen.last.message}${PvtMessageShowOnScreen.last.messageStatus}");
  }

  Future<File?> cropImage(XFile pickedFile, BuildContext context) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 30,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPresetCustom(),
          ],
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(
            width: 520,
            height: 520,
          ),
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  Future<void> _captureImage(ChatSocket c, BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 30);

    if (image != null) {
      File? croppedImage = await cropImage(image, context);
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
        String messageId = uuid.v1();
        print(json.decode(value));
        var messageJson = {
          "messageId": messageId,
          "senderName": G.loggedinUser.privateName,
          "receiverName": widget.otherUserDetail?.privateName,
          "message": _msgInput.text,
          "sentBy": G.userPhoneNumber,
          "sentTo": widget.otherUserDetail?.phoneNumber,
          "time": DateTime.now().toString(),
          "fileName": json.decode(value)[0]["mediaName"]
        };
        bool isSent = await c.sendMessage(messageJson);
        log("value of is messahe sent $isSent");
        PrivateMessage pvtMessage = PrivateMessage(
            messageId: messageId,
            senderName: G.loggedinUser.privateName,
            receiverName: widget.otherUserDetail?.privateName,
            message: _msgInput.text,
            time: DateTime.now().toString(),
            sentBy: G.userPhoneNumber,
            sentTo: widget.otherUserDetail?.phoneNumber,
            fileName: json.decode(value)[0]["mediaName"],
            messageStatus: isSent ? "sent" : "notSent",
            isRead: true,
            isDelivered: false,
            isSeen: false);

        // socket.emit("message", json.encode(messageJson));
        // PrivateMessage pvtMessage = PrivateMessage.fromMap(messageJson);
        log("message addded ${pvtMessage.toMap()}");
        setState(() {
          PvtMessageShowOnScreen.add(pvtMessage);
        });
        DBProvider.db.newPrivateMessage(pvtMessage);
      });

      // Do something with the captured image, e.g., upload it to a server
      // You can use the 'http' package for uploading to a server
      // Example: await _uploadImageToServer(File(image.path));
    }
  }

  Future<void> _uploadFiles(ChatSocket chatSock, BuildContext context) async {
    String uploadUrl = G.HOST + "api/v1/saveImg";
    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    for (var file in _selectedFile ?? []) {
      log("filee ### ${file.absolute} ");
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      var filename;
      String messageId = uuid.v1();
      response.stream.transform(utf8.decoder).listen((value) {
        log("response of uploaded file ");
        print(json.decode(value));
        Map<String, dynamic> jsonData = jsonDecode(value.toString());

        // Access the values
        String message = jsonData['message'];
        List<String> savedFiles = List<String>.from(jsonData['savedFile']);
        print('Files uploaded successfully');
        savedFiles.forEach((filename) {
          log("filename### $filename");
          var messageJson = {
            "messageId": messageId,
            "senderName": G.loggedinUser.privateName,
            "receiverName": widget.otherUserDetail?.privateName,
            "message": _msgInput.text,
            "sentBy": G.userPhoneNumber,
            "sentTo": widget.otherUserDetail?.phoneNumber,
            "time": DateTime.now().toString(),
            "fileName": filename
          };
          log("Message json $messageJson");
          PrivateMessage pvtMessage = PrivateMessage(
              messageId: messageId,
              messageStatus: "notSent",
              receiverName: widget.otherUserDetail?.privateName,
              senderName: G.loggedinUser.privateName,
              message: _msgInput.text,
              time: DateTime.now().toString(),
              sentBy: G.userPhoneNumber,
              sentTo: widget.otherUserDetail?.phoneNumber,
              fileName: filename,
              isDelivered: false,
              isSeen: false);

          // socket.emit("message", json.encode(messageJson));
          chatSock.sendMessage(messageJson);
          // PrivateMessage pvtMessage = PrivateMessage.fromMap(messageJson);
          log("message addded ${pvtMessage.toMap()}");
          setState(() {
            PvtMessageShowOnScreen.add(pvtMessage);
          });
          DBProvider.db.newPrivateMessage(pvtMessage);
        });

        // Print the values
        print('Message: $message');
        print('Saved Files: $savedFiles');
        // filename=json.decode(value)[0]["mediaName"];
      });
    } else {
      print('Failed to upload files. Status code: ${response.statusCode}');
    }
  }

  Future<void> uploadVideo(ChatSocket c, BuildContext context) async {
    String uploadVideoUrl = G.HOST + "api/v1/saveVideo";
    var request = http.MultipartRequest('POST', Uri.parse(uploadVideoUrl));
    for (var file in _selectedVideo ?? []) {
      request.files.add(await http.MultipartFile.fromPath('videos', file.path));
    }

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      String messageId = uuid.v1();

      response.stream.transform(utf8.decoder).listen((value) {
        log("response of uploaded video ");
        print(json.decode(value));
        Map<String, dynamic> jsonData = jsonDecode(value.toString());

        // Access the values
        String message = jsonData['message'];
        List<String> savedFiles = List<String>.from(jsonData['savedFile']);
        print('video uploaded successfully');
        // Handle the server response as needed
        savedFiles.forEach((filename) {
          log("filename### $filename");
          var messageJson = {
            "messageId": messageId,
            "senderName": G.loggedinUser.privateName,
            "receiverName": widget.otherUserDetail?.privateName,
            "message": _msgInput.text,
            "sentBy": G.userPhoneNumber,
            "sentTo": widget.otherUserDetail?.phoneNumber,
            "time": DateTime.now().toString(),
            "fileName": filename
          };
          log("Message json $messageJson");
          PrivateMessage pvtMessage = PrivateMessage(
              messageId: messageId,
              senderName: G.loggedinUser.privateName,
              receiverName: widget.otherUserDetail?.privateName,
              message: _msgInput.text,
              time: DateTime.now().toString(),
              sentBy: G.userPhoneNumber,
              sentTo: widget.otherUserDetail?.phoneNumber,
              fileName: filename,
              messageStatus: "notSent",
              isDelivered: false,
              isSeen: false);

          // socket.emit("message", json.encode(messageJson));
          c.sendMessage(messageJson);
          // PrivateMessage pvtMessage = PrivateMessage.fromMap(messageJson);
          log("message addded ${pvtMessage.toMap()}");
          setState(() {
            PvtMessageShowOnScreen.add(pvtMessage);
          });
          DBProvider.db.newPrivateMessage(pvtMessage);
        });

        // Print the values
        print('Message: $message');
        print('Saved Files: $savedFiles');
        // filename=json.decode(value)[0]["mediaName"];
      });
    } else {
      print('Failed to upload files. Status code: ${response.statusCode}');
    }
  }

  Future<void> _pickFile(ChatSocket chatSock, BuildContext context) async {
    try {
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
          _uploadFiles(chatSock, context);
        }
        if (tempVideo.isNotEmpty) {
          log("not empty videoo");
          // _selectedVideo =
          //     tempVideo.map((element) => File(element.path!)).toList();
          _selectedVideo = [];
          for (var element in tempVideo) {
            File file = File(element.path!);
            log("Compressing video: ${file.path}");
            MediaInfo? compressedVideo = await VideoCompress.compressVideo(
              file.path,
              quality:
                  VideoQuality.MediumQuality, // Adjust the quality as needed
              deleteOrigin: false, // Whether to delete the original file
            );

            if (compressedVideo != null && compressedVideo.file != null) {
              _selectedVideo?.add(compressedVideo.file!);
            }
          }

          uploadVideo(chatSock, context);
        }
      } else {
        log("users cancelled picking");
        // User canceled the picker
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<bool> _requestPermissions() async {
    PermissionStatus micStatus = await Permission.microphone.status;
    PermissionStatus cameraStatus = await Permission.camera.status;

    if (micStatus.isDenied || cameraStatus.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();
      micStatus = statuses[Permission.microphone]!;
      cameraStatus = statuses[Permission.camera]!;
    }

    return micStatus.isGranted && cameraStatus.isGranted;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await startFunctions(widget.otherUserDetail!.phoneNumber!);
    });

    // socket = IO.io(
    //     // "https://ws.koram.in/",
    //     "http://${G.IP}:4000/",
    //     IO.OptionBuilder()
    //         .setTransports(['websocket']) // for Flutter or Dart VM
    //         .disableAutoConnect() // disable auto-connection
    //         .setExtraHeaders({'foo': 'bar'}) // optional
    //         .build());
    // socket.connect();
    // getMessage();
    // setupSocketListener();
  }

  sendReadStatus() {
    ChatSocket chatSocketProvider =
        Provider.of<ChatSocket>(context, listen: false);
    PvtMessageShowOnScreen = chatSocketProvider
        .getMessageByPhoneRuntime(widget.otherUserDetail!.phoneNumber!);
    List<String?> filteredIds = PvtMessageShowOnScreen.map((element) =>
            element.messageStatus != "sent" ? element.messageId : null)
        .where((id) => id != null)
        .toList();
    if (filteredIds.isNotEmpty) {
      chatSocketProvider.sendMessageRead(
          widget.otherUserDetail!.phoneNumber!, filteredIds);
    }
  }

  // @override
  // void didChangeDependencies()async {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //
  //   ChatSocket chatSocket = Provider.of<ChatSocket>(context, listen: true);
  //
  //    chatSocket.Socket.on("messageReadConfirmation", (data) async {
  //     var messageData = jsonDecode(jsonEncode(data));
  //     log("the read confirmation in main provider didchange dependency ${messageData}");
  //     PvtMessageShowOnScreen.where((e) => messageData["messageID"].contains(e.messageId )
  //         .forEach((element) {
  //       element.messageStatus = "read";
  //     }));
  //
  //   });
  //   setState(() {
  //
  //   });
  //   // if(countDependency==0)
  //   // {
  //   //   sendReadStatus();
  //   // }
  //   //
  //   // setState(() {});
  //   // _scrollToBottom();
  //
  //   // Timer.periodic(Duration(seconds: 5), (t){
  //   //   ChatSocket chatSocketProvider =
  //   //   Provider.of<ChatSocket>(context, listen: false);
  //   //   PvtMessageShowOnScreen = chatSocketProvider
  //   //       .getMessageByPhoneRuntime(widget.groupName!.phoneNumber!);
  //   //   List<String?> filteredIds = PvtMessageShowOnScreen
  //   //       .map((element) => element.messageStatus != "sent" ? element.messageId : null)
  //   //       .where((id) => id != null)
  //   //       .toList();
  //   //    if(filteredIds.isNotEmpty)
  //   //    {
  //   //      chatSocketProvider.sendMessageRead(
  //   //          widget.groupName!.phoneNumber!,filteredIds
  //   //      );
  //   //
  //   //    }
  //   // });
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ChatSocket chatSocket = Provider.of<ChatSocket>(context, listen: true);
    connectivityProvider connectivityClass =
        Provider.of<connectivityProvider>(context, listen: true);
    // if(connectivityClass!=null)
    // {
    //   log("connection status in chatting screnenc ${connectivityClass.connectionStatus}");
    //         if(connectivityClass.connectionStatus)
    // }
    chatSocket.Socket.on("messageReadConfirmation", (data) async {
      var messageData = jsonDecode(jsonEncode(data));
      log("the read confirmation in main provider didChangeDependencies: ${messageData}");

      // Wait for the async processing of message read confirmation
      await Future(() {
        PvtMessageShowOnScreen.where(
                (e) => messageData["messageID"].contains(e.messageId))
            .forEach((element) {
          element.messageStatus = "read";
        });
      });

      // Now update the state after processing the message confirmation
      if (mounted) {
        setState(() {
          // Any UI updates if needed here, or just ensure the widget rebuilds
        });
      }
    });
  }
  //
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if(ModalRoute.of(context)!.settings.arguments!=null)
  //   {
  //     log("inside modeule route not null");
  //     final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  //     final number = args['otherUserNumber'];
  //     log("The passed number ${number}");
  //     if(number!=null)
  //     {
  //       Future.delayed(Duration(seconds: 0)).then((instance)async{
  //
  //         await init(number);
  //         widget.groupName= await  UsersProviderClass().getUserByNumber([number]);
  //       });
  //     }
  //   }
  //   else
  //   {
  //     log("insidemodel null");
  //     Future.delayed(Duration(seconds: 0)).then((instance)async{
  //       await init(widget.groupName!.phoneNumber!);
  //     });
  //   }
  //
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    _msgInput.dispose();
    _scrollController.dispose();

    ChatSocket().RecentMessageData = null;
    // socket.disconnect();
    // socket.dispose();
    // _channel = null;
    super.dispose();
  }

  toggleOptions() {
    log("option toggle calle d");
    displayOptions = !displayOptions;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final height =
    //     MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    // _scrollController.position.maxScrollExtent;
    CallSocketService callSocket =
        Provider.of<CallSocketService>(context, listen: true);
    ChatSocket chatSocket = Provider.of<ChatSocket>(context, listen: true);
    UsersProviderClass UserClass =
        Provider.of<UsersProviderClass>(context, listen: false);
    sendUnsentMessage(chatSocket);
    PvtMessageShowOnScreen.where((e) => e.messageStatus != "sent")
        .forEach((element) {});
    if (chatSocket.RecentMessageData != null) {
      if (chatSocket.RecentMessageData?.sentBy ==
          widget.otherUserDetail?.phoneNumber) {
        PvtMessageShowOnScreen.add(chatSocket.RecentMessageData!);
        chatSocket.sendMessageRead(widget.otherUserDetail!.phoneNumber!,
            [chatSocket.RecentMessageData!.messageId]);
        chatSocket.RecentMessageData = null;
      }
      _scrollToBottom();
    }

    if (chatSocket.chatRoomInvite != null) {
      if (chatSocket.chatRoomInvite?.sentBy ==
          widget.otherUserDetail?.phoneNumber) {
        PvtMessageShowOnScreen.add(chatSocket.chatRoomInvite!);
        chatSocket.chatRoomInvite = null;
      }
      _scrollToBottom();
    }

    if (UserClass.LoggedUser == null) {
      Future.delayed(Duration.zero).then((w) async {
        await UserClass.returnLoggedUser();
        isFriend = UserClass.LoggedUser!.friendList!
            .contains(widget.otherUserDetail?.phoneNumber);
      });
    }

    // try {
    //   if (_scrollController.hasClients) {
    //     // _scrollController.animateTo(
    //     _scrollController.position.maxScrollExtent;
    //     //   duration: Duration(seconds: 2),
    //     //   curve: Curves.easeOut,
    //     // );
    //   }
    //   // Timer(
    //   //   Duration(milliseconds: 300),
    //   //   () => _scrollController
    //   //       .jumpTo(_scrollController.position.maxScrollExtent),
    //   // );
    // } catch (e) {
    //   log("error on scroll while build $e");
    // }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Container(
            height: 70,
            // color: Colors.black,
            width: 170,
            padding: EdgeInsets.only(left: 0),
            child: Row(
              children: [
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: SvgPicture.asset("assets/arrowLeft.svg")),
                    SizedBox(
                      width: 12,
                    ),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: CommanWidgets().cacheProfileDisplay(
                          widget.otherUserDetail!.publicProfilePicUrl!),
                    )

                    // CachedNetworkImage(imageUrl: G.HOST +
                    //     "api/v1/images/" +
                    //     widget.groupName!.publicProfilePicUrl!,filterQuality: FilterQuality.low,),
                    // CircleAvatar(
                    //     backgroundImage: CachedNetworkImageProvider(G.HOST +
                    //         "api/v1/images/" +
                    //         widget.groupName!.publicProfilePicUrl!,scale: 2)),
                  ],
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    height: 70,
                    // width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.otherUserDetail!.privateName!,
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 16,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                        // Text(
                        //   "100 members",
                        //   style: TextStyle(
                        //       fontSize: 15,
                        //       fontWeight: FontWeight.normal,
                        //       color: Colors.grey),
                        // ),
                      ],
                    ),
                  ),
                )
              ],
            )),
        actions: [
          GestureDetector(
              onTap: () async {
                try {
                  log("inside try of the phone call navigation");
                  if (_isProcessingCAll) return; // Prevent multiple taps
                  setState(() {
                    _isProcessingCAll = true;
                  });
                  if (await _requestPermissions()) {
                    await callSocket.CallRequest(
                        widget.otherUserDetail!.phoneNumber!,
                        G.userPhoneNumber ?? "",
                        "Audio");
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => AudioCallingScreen(
                              isVideoCall: false,
                              isfromNotification: false,
                              isIncoming: false,
                              caller: G.userPhoneNumber,
                              callTo: widget.otherUserDetail!.phoneNumber!,
                              otherPersonData: widget.otherUserDetail,
                            )));
                  } else {
                    log("permission was not granted ");
                  }
                } catch (e) {
                  log("error while auduio call  clicked $e");
                } finally {
                  log("inside finnlay ");
                  setState(() {
                    _isProcessingCAll = false;
                  });
                }
              },
              child: SvgPicture.asset("assets/fluent_call.svg")),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
              onTap: () async {
                try {
                  log("inside try of the phone call navigation");
                  if (_isProcessingCAll) return; // Prevent multiple taps
                  setState(() {
                    _isProcessingCAll = true;
                  });
                  if (await _requestPermissions()) {
                    await callSocket.CallRequest(
                        widget.otherUserDetail!.phoneNumber!,
                        G.userPhoneNumber ?? "",
                        "Video");
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => AudioCallingScreen(
                              isVideoCall: true,
                              isfromNotification: false,
                              isIncoming: false,
                              caller: G.userPhoneNumber,
                              callTo: widget.otherUserDetail!.phoneNumber!,
                              otherPersonData: widget.otherUserDetail,
                            )));
                  } else {
                    log("permission was not granted ");
                  }
                } catch (e) {
                  log("error while auduio call  clicked $e");
                } finally {
                  log("inside finnlay ");
                  setState(() {
                    _isProcessingCAll = false;
                  });
                }
              },
              child: SvgPicture.asset("assets/fluent_video.svg")),
          SizedBox(
            width: 10,
          ),
          GestureDetector(
              onTap: () {
                toggleOptions();
              },
              child: SvgPicture.asset("assets/threeDot.svg")),
          SizedBox(
            width: 20,
          ),
          // Icon(
          //   Icons.search,
          //   color: Colors.grey,
          //   size: 25,
          // ),
          // SizedBox(
          //   width: 10,
          // ),
          // Container(
          //     height: 25,
          //     width: 25,
          //     child: Image.asset("assets/Group 629.png")),
          // SizedBox(
          //   width: 10,
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  displayOptions = false;
                },
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: _scrollController,
                    itemCount: PvtMessageShowOnScreen.length,
                    itemBuilder: (ctx, i) {
                      bool isLast = false;
                      if (PvtMessageShowOnScreen.length == i + 1) {
                        // log("last of the list ");
                        isLast = true;
                        // _scrollToBottom();
                      } else {
                        // log("notlast");
                        isLast = false;
                      }
                      return Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 60.0 : 0),
                        child:
                            NewMessage(messageData: PvtMessageShowOnScreen[i]),
                      );
                    }),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  displayOptions = false;
                  setState(() {});
                },
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
                              _captureImage(chatSocket, context);
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
                              onTap: () {
                                displayOptions = false;
                              },
                              focusNode: textFocusNode,
                              controller: _msgInput,
                              onSubmitted: (v) {
                                Timer(
                                  Duration(seconds: 0),
                                  () => _scrollController.jumpTo(
                                      _scrollController
                                          .position.maxScrollExtent),
                                );
                                onSubmit(chatSocket, context);
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
                            displayOptions = false;

                            _pickFile(chatSocket, context);
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
                            displayOptions = false;
                            onSubmit(chatSocket, context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              width: 57.58,
                              height: 42.35,
                              decoration: ShapeDecoration(
                                color: Color(0xFFFF6701),
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
            ),
            Positioned(
              top: 0,
              right: 15,
              child: displayOptions
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(10.0), // Set the radius here
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            spreadRadius: 5, // Spread radius
                            blurRadius: 7, // Blur radius
                            offset:
                                Offset(0, 3), // Offset in x and y directions
                          ),
                        ],
                      ),
                      // height: MediaQuery.of(context).size.height/2,
                      width: MediaQuery.of(context).size.width / 1.5 - 20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "View Contact",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Media,links and docs",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Search",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Mute Notification",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Disappearing messages",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Wallpaper",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(
                                  "More",
                                  style: TextStyle(fontSize: 17),
                                ),
                                Expanded(
                                  child: SizedBox(),
                                ),
                                Icon(
                                  Icons.arrow_right,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ))
                  : SizedBox(),
            ),
          ],
        ),
      ),
      // ),
    );
  }

  void onSubmit(ChatSocket chatSocketInstance, BuildContext context) async {
    if (_msgInput.text == "") {
      return;
    }
    ;
    String messageId = uuid.v1();
    textFocusNode.requestFocus();
    if (!G.loggedinUser.friendList!
        .contains(widget.otherUserDetail!.phoneNumber)) {
      int res = await UsersProviderClass()
          .addFriendByPhoneNumber(widget.otherUserDetail!.phoneNumber!);
      if (res == 200) {
        log("added friends ");
      } else {
        log("error while adding friends");
      }
    }
    var messageJson = {
      "messageId": messageId,
      "receiverName": widget.otherUserDetail!.privateName,
      "senderName": G.loggedinUser.privateName,
      "message": _msgInput.text,
      "sentBy": G.userPhoneNumber,
      "sentTo": widget.otherUserDetail!.phoneNumber,
      "time": DateTime.now().toString(),
      "isDelivered": false,
      "isSeen": false,
    };
    PrivateMessage pvtMessage = PrivateMessage(
        messageStatus: "notSent",
        receiverName: widget.otherUserDetail!.privateName,
        senderName: G.loggedinUser.privateName,
        message: _msgInput.text,
        time: DateTime.now().toString(),
        sentBy: G.userPhoneNumber,
        sentTo: widget.otherUserDetail?.phoneNumber,
        isDelivered: false,
        isSeen: false,
        messageId: messageId);

    // final prefs = await SharedPreferences.getInstance();
    // _message = prefs.getStringList("messages") ?? [];
    // _message.add(jsonEncode(messageJson));
    // log("isfreindd ${isFriend}");
    // if (!isFriend) {
    //   //api to add friend
    //   await G().addFriendByPhoneNumber(
    //       widget.groupName.phoneNumber ?? "", widget.groupName);
    // }
    PvtMessageShowOnScreen.add(pvtMessage);

    _msgInput.clear();

    setState(() {});
    _scrollToBottom();
    chatSocketInstance.MessageStore.add(pvtMessage);
    // _msgInput.text = "";

    // socket.emit("message", json.encode(messageJson));
    await DBProvider.db.newPrivateMessage(pvtMessage);

    await chatSocketInstance.sendMessage(messageJson);
    await getUpdatedList(widget.otherUserDetail!.phoneNumber!);
    setState(() {});
  }
}
