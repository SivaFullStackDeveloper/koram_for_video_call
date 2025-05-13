import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:io';
import 'package:koram_app/Helper/color.dart';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
// import 'package:koram_app/Helper/ChatSocketServices.dart';
import 'package:koram_app/Helper/CommonWidgets.dart';
import 'package:koram_app/Helper/DBHelper.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Helper/NotificationServices.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Models/ChatRoom.dart';
// import 'package:koram_app/Models/Group.dart';
import 'package:koram_app/Models/Message.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Models/Notification.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Screens/AddContactScreen.dart';
import 'package:koram_app/Screens/AudioCalling.dart';
import 'package:koram_app/Screens/ChattingScreen.dart';
import 'package:koram_app/Screens/MyStatusScreen.dart';
import 'package:koram_app/Screens/StoryViewScreen.dart';
import 'package:koram_app/Screens/ViewStoryScreen.dart';
import 'package:koram_app/Screens/storyPage.dart';
import 'package:koram_app/Widget/Badge.dart';
import 'package:koram_app/Widget/status-item.dart';
import 'package:koram_app/Models/Notification.dart' as N;
import 'package:koram_app/Widget/uploda.dart';

import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_socket_channel/io.dart';

import '../Helper/CallSocketServices.dart';
import '../Helper/ChatSocketServices.dart';
import '../Widget/BottomSheetContent.dart';
import 'LoginScreen.dart';
import 'NewProfileScreen.dart';
import 'NotificationScreen.dart';
import 'PrivateProfileScreen.dart';

class ChatScreen extends StatefulWidget {
  NotificationService __notificationService;
  Function StartcallscoketFunc;
  ChatScreen(this.__notificationService, this.StartcallscoketFunc);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late bool isLoading = false;
  List<UserDetail> SeenStoryCopy = [];
  List<UserDetail> UnseenStoryCopy = [];
  List<UserDetail> SeenStory = [];
  List<UserDetail> UnseenStory = [];
  List<UserDetail> FinalFriendList = [];
  var searchValue = TextEditingController();
  List<UserDetail> friendListCopy = [];
  List<PrivateMessage> PvtMessage = [];
  List<Story> UserStory = [];
  late TabController _tabController;
  bool isSearchClicked = false;
  File? profileImage;
  bool isAddingStory = false;
  bool isInternet = false;
  int counter = 0;
  List<String?> theNewlyReceivedMessage = [];
  bool isLoadingStoryPicker = false;
  String formatDateTime(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      // Today
      return DateFormat.jm().format(dateTime);
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      // Yesterday
      return "Yesterday, " + DateFormat.jm().format(dateTime);
    } else {
      // For other days, you can format it as you like
      return DateFormat.yMd().add_jm().format(dateTime);
    }
  }

  List<PrivateMessage> allPvtMessage = [];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      log("listner caling tab");
      setState(() {});
    });
    try {
      Future.delayed(Duration.zero).then((e) async {
        await chatInitialize();

        log("the remove badge executed ");
      });
    } catch (e) {
      log("error in chat screen init ${e}");
    }
    super.initState();
  }

  OnMessageReceivedFunction() {
    log("the on message received function called");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // chatSocketProvider.storeAllMessageToRuntime();
    });
  }

  FocusNode searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  chatInitialize() async {
    try {
      log("chat screen initialize");
      await ChatSocket().storeAllMessageToRuntime();
      isInternet = await G().isInternetAvailable();

      Provider.of<UsersProviderClass>(context, listen: false).saveValueFromDb();

      if (isInternet) {
        log("internet available ");
        Provider.of<UsersProviderClass>(context, listen: false).getFriends();
      }
    } catch (e) {
      log("error at chat initialize ");
    }
  }

  ImagePicker picker = ImagePicker();

  var image;

  String findLatestTimeForFriend(String time) {
    var storeDate;

    if (time == "null") {
      return "";
    }

    storeDate = DateTime.parse(time);
    final difference = DateTime.now().difference(storeDate);
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      final formatter = DateFormat.yMd();
      return formatter.format(storeDate);
    }
  }

  addStory() async {
    log("called add story ");

    // Check server reachability
    var checkUri = Uri.parse(G.HOST + "api/v1/testServer");
    var urlResponse;
    try {
      urlResponse = await http.get(checkUri).timeout(Duration(seconds: 10));
    } catch (e) {
      log("URL validation failed: $e");
      CommanWidgets().showSnackBar(
        context,
        "Failed to connect to the server. Please try again later.",
        Colors.red,
      );
      return;
    }

    if (urlResponse.statusCode != 200) {
      log("Invalid URL or server not reachable ${urlResponse.statusCode}");
      CommanWidgets().showSnackBar(
        context,
        "Server not reachable. Please try again later.",
        Colors.red,
      );
      return;
    }

    // Upload image using custom upload class
    try {
      var finalData =
          await ImageUpload().uploadImage(image!); // Use your image file
      final Map<String, dynamic> data = jsonDecode(finalData);
      final String url = data['url'];

      log("Uploaded Image URL: $url");

      // Save story via provider
      await Provider.of<UsersProviderClass>(context, listen: false)
          .addStory(url, G.userPhoneNumber);

      CommanWidgets().showSnackBar(
        context,
        "Successfully added your story",
        Colors.green,
      );
    } catch (e) {
      log("Upload failed: $e");
      CommanWidgets().showSnackBar(
        context,
        "Upload failed. Please try again later.",
        Colors.red,
      );
      return;
    }

    log("last line of add story ");
    chatInitialize();
  }

  // addStory() async {
  //   log("called add story ");

  //   log("after the internet check ");
  //   // setState(() {
  //   //   isAddingStory = true;
  //   // });
  //   // var stream = new http.ByteStream(DelegatingStream.typed(image!.openRead()));

  //   var checkUri = Uri.parse(G.HOST + "api/v1/testServer");
  //   var urlResponse;
  //   try {
  //     urlResponse = await http.get(checkUri).timeout(Duration(seconds: 10));
  //   } catch (e) {
  //     log("URL validation failed: $e");
  //     CommanWidgets().showSnackBar(
  //         context,
  //         "Failed to connect to the server. Please try again later.",
  //         Colors.red);
  //     return;
  //   }

  //   if (urlResponse.statusCode != 200) {
  //     log("Invalid URL or server not reachable ${urlResponse.statusCode}");
  //     CommanWidgets().showSnackBar(
  //         context, "Server not reachable. Please try again later.", Colors.red);
  //     return;
  //   }
  //   var stream = http.ByteStream.fromBytes(image!.readAsBytesSync());
  //   // get file length
  //   var length = await image!.length();

  //   // string to uri
  //   var uri = Uri.parse(G.HOST + "api/v1/images");

  //   // create multipart request
  //   var request = new http.MultipartRequest("POST", uri);

  //   // multipart that takes file
  //   var multipartFile = new http.MultipartFile('myFile', stream, length,
  //       filename: path.basename(image!.path));

  //   // add file to multipart
  //   request.files.add(multipartFile);

  //   // send
  //   var response;
  //   try {
  //     log("inside the try");
  //     response = await request.send().timeout(Duration(seconds: 5));
  //     response.stream.transform(utf8.decoder).listen((value) async {
  //       log("paruuu ${json.decode(value)}");
  //       // print(json.decode(value)[0]["mediaName"]);
  //       await Provider.of<UsersProviderClass>(context, listen: false)
  //           .addStory(json.decode(value)[0]["mediaName"], G.userPhoneNumber);
  //     });
  //     // initialize();
  //     CommanWidgets()
  //         .showSnackBar(context, "Successfully added your story", Colors.green);
  //   } catch (e) {
  //     log("insdie the error ");
  //     log("eeeeeeE$e");
  //   }

  //   log(" Statis code of response ${response.statusCode}");

  //   log("last line of add story ");
  //   chatInitialize();
  // }

  String messageIdTemp = "";

  addMessagesToScreen(List<UserDetail> users) async {
    List<PrivateMessage> allSavedMessage =
        await DBProvider.db.getAllPrivateMessages();
    allPvtMessage = allSavedMessage;
    for (UserDetail u in users) {
      int index = allSavedMessage.lastIndexWhere(
          (m) => m.sentBy == u.phoneNumber || m.sentTo == u.phoneNumber);
      if (index != -1) {
        log("got the message at index ${index}");

        u.latestMessage = allSavedMessage[index].message;
        u.newMessage = allSavedMessage.where((e) => e.isSeen == false).length;
        log("the length of the message ${u.newMessage} length ");
        u.recieveTime = DateTime.parse(allSavedMessage[index].time);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log("build chat widgets $counter");
    counter++;
    UsersProviderClass UserClass =
        Provider.of<UsersProviderClass>(context, listen: true);
    if (counter == 1) {
      addMessagesToScreen(UserClass.finalFriendsList);
    } else {
      log("add message was not called");
    }

    if (UserClass.LoggedUser != null) {
      log("the loggeduser DEtail ${json.encode(UserClass.LoggedUser!.privateProfilePicUrl ?? "no pic")}");
    }
    ChatSocket chatSocketProvider =
        Provider.of<ChatSocket>(context, listen: true);
    chatSocketProvider.Socket.on("message-receive", (data) async {
      log("inside message receivedd");

      PrivateMessage receivedMessage = PrivateMessage.fromMap(jsonDecode(data));
      log("the boolean value ${theNewlyReceivedMessage.contains(receivedMessage.messageId)}");
      if (receivedMessage.sentTo == G.userPhoneNumber &&
          !theNewlyReceivedMessage.contains(receivedMessage.messageId)) {
        log("the newly received message");
        final index = FinalFriendList.indexWhere(
            (e) => e.phoneNumber == receivedMessage.sentBy);
        log("the indexx of the filtered ${index}");
        if (index != -1) {
          log("index non zero");
          allPvtMessage = await DBProvider.db.getAllPrivateMessages();
          log("allprivate message ${allPvtMessage.length}");
          allPvtMessage.forEach((e) {
            log("inside the app private message");
            if (e.sentBy == receivedMessage.sentBy && !receivedMessage.isSeen) {
              log("the value is true ${e.sentBy == receivedMessage.sentBy}  the next ${receivedMessage.isSeen}");
            } else {
              log("the value is false ${e.sentBy == receivedMessage.sentBy}  the next ${receivedMessage.isSeen}");
            }
            ;
          });
          List<PrivateMessage> filteredMessage = allPvtMessage
              .where((e) => e.sentBy == receivedMessage.sentBy)
              .toList();

          log("the length of filtered list ${filteredMessage.where((k) => k.isSeen == false).length}");
          FinalFriendList[index].newMessage =
              filteredMessage.where((k) => k.isSeen == false).length;
          FinalFriendList[index].recieveTime =
              DateTime.parse(filteredMessage.last.time);
          FinalFriendList[index].latestMessage = filteredMessage.last.message;
          log("after updating the friends list ${FinalFriendList[index].newMessage}");
          setState(() {});
        }
      }

      // if (receivedMessage.sentTo == G.userPhoneNumber &&
      //     !theNewlyReceivedMessage.contains(receivedMessage.messageId)) {
      //   theNewlyReceivedMessage.add(receivedMessage.messageId!);
      //   log("Message received from ${receivedMessage.sentBy}");
      //
      //   // Find index once and store it to avoid duplicate searches in the list
      //   final index = FinalFriendList.indexWhere(
      //           (e) => e.phoneNumber == receivedMessage.sentBy);
      //
      //   if (index != -1) {
      //     log("previous value of newmessage count ${FinalFriendList[index].newMessage}");
      //     FinalFriendList[index].newMessage += 1;
      //     setState(() {});
      //   }
      // }
    });
    if (!isSearchClicked) {
      UnseenStory = UserClass.unseenStories;
      SeenStory = UserClass.seenStories;
      UserStory = UserClass.UserStory ?? [];

      FinalFriendList = UserClass.finalFriendsList;
    } else {
      log(" on search final friend  length in build  ${FinalFriendList.length}");
      log("final seenstiry  length in build ${SeenStory.length}");
      log("final unseenstory  length in build ${UnseenStory.length}");
    }
    List<N.Notification> notification =
        Provider.of<N.Notifications>(context).notification;
    OnMessageReceivedFunction();
    return Builder(builder: (BuildContext context) {
      return Scaffold(
        floatingActionButton: _tabController.index == 1
            ? FloatingActionButton(
                onPressed: () async {
                  showModalBottomSheet(
                      context: context,
                      builder: (ctx) {
                        return StatefulBuilder(builder: (ctx, setSate) {
                          return Container(
                              height: 200,
                              child: Column(
                                children: [
                                  ListTile(
                                    onTap: () async {
                                      XFile? i = await picker.pickImage(
                                          imageQuality: 30,
                                          source: ImageSource.camera);
                                      if (i != null) {
                                        image = await CommanWidgets()
                                            .cropAndAssign(i, context);
                                      }
                                      // setState(() {
                                      //   // image = File(i!.path);
                                      // });
                                      Navigator.pop(context);
                                      addStory();
                                    },
                                    leading: Icon(Icons.camera_alt),
                                    title: Text("Camera"),
                                  ),
                                  ListTile(
                                    onTap: () async {
                                      var i = await picker.pickImage(
                                          imageQuality: 30,
                                          source: ImageSource.gallery);
                                      if (i != null) {
                                        image = await CommanWidgets()
                                            .cropAndAssign(i, context);
                                      }
                                      // setState(() {
                                      //   image = File(i!.path);
                                      // });
                                      Navigator.pop(context);

                                      addStory();
                                    },
                                    leading: Icon(
                                      Icons.image_rounded,
                                      color: backendColor,
                                    ),
                                    title: Text("Gallery"),
                                  )
                                ],
                              ));
                        });
                      });
                },
                elevation: 0.0,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2, color: backendColor.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(100),
                    color: backendColor,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ))

            //    Container(
            //     width: 59,
            //     height: 59,
            //     decoration: ShapeDecoration(
            //       color: Color(0xFFFFEADC),
            //       shape: OvalBorder(),
            //     ),
            //     child: Center(
            //         child: SvgPicture.asset("assets/AddstoryLogo.svg")),
            //   ),
            // )
            : FinalFriendList.length > 0
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => AddContactScreen(
                                callBackToInit: () {
                                  setState(() {});
                                },
                                friends: UserClass.finalFriendsList,
                              )));
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
                        "assets/AddContact.svg",
                        color: Colors.white,
                      )),
                    ),
                  )
                : null,
        backgroundColor: Colors.white,
        appBar: isSearchClicked
            ? AppBar(
                backgroundColor: Colors.white,
                title: TextField(
                  enabled: true,
                  autofocus: true,
                  focusNode: searchFocusNode,
                  controller: searchValue,
                  onChanged: (v) {
                    log("the text valuee ${v}");
                    if (v.isEmpty) {
                      setState(() {
                        FinalFriendList = UserClass.finalFriendsList;
                        SeenStory = UserClass.seenStories;
                        UnseenStory = UserClass.unseenStories;
                      });
                    }
                    List<UserDetail> us = FinalFriendList.where((element) {
                      return element.publicName!
                          .toLowerCase()
                          .startsWith(v.toLowerCase());
                    }).toList();
                    log("userdetail length after seracg ${us.length}");
                    List<UserDetail> seen = SeenStory.where((element) {
                      log("element namee inseen ${element.publicName}");
                      return element.publicName!
                          .toLowerCase()
                          .startsWith(v.toLowerCase());
                    }).toList();
                    List<UserDetail> unseen = UnseenStory.where((element) {
                      log("element namee in unseen ${element.privateName}");
                      return element.publicName!
                          .toLowerCase()
                          .startsWith(v.toLowerCase());
                    }).toList();

                    setState(() {
                      FinalFriendList = us;
                      SeenStory = seen;
                      UnseenStory = unseen;
                    });
                    log("final friend  length ${FinalFriendList.length}");
                    log("final seenstiry  length ${SeenStory.length}");
                    log("final unseenstory  length ${UnseenStory.length}");
                  },
                  decoration: InputDecoration(
                      hintText: 'Search users...', border: InputBorder.none),
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: RuntimeStorage.instance.PrimaryOrange),
                  onPressed: () {
                    setState(() {
                      isSearchClicked = false;
                    });
                    // Handle search button tap
                  },
                ),
              )
            : AppBar(
                elevation: 0.5,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                title: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/Layer 2.svg"),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Koram",
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 23.96,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: backendColor,
                    labelColor: backendColor,
                    unselectedLabelColor: Color(0xFF303030),
                    unselectedLabelStyle: TextStyle(
                      color: Color(0xFF303030),
                      fontSize: 14,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                    tabs: [
                      Tab(
                        text: "Messages",
                      ),
                      Tab(
                        text: 'Stories',
                      )
                    ]),
                actions: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSearchClicked = true;
                      });

                      Future.delayed(Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(searchFocusNode);
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(),
                      child: SvgPicture.asset("assets/Vector.svg"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => NotificationScreen(
                              // callBackInitialize: initialize(),
                              )));
                      // showModalBottomSheet(
                      //     context: context,
                      //     elevation: 3,
                      //     isScrollControlled: true,
                      //     builder: (ctx) => NotificationScreen());
                    },
                    child: BadgeWidget(
                        child: Container(
                            margin: EdgeInsets.all(8),
                            height: 20,
                            width: 20,
                            child: SvgPicture.asset("assets/notify bell.svg")),
                        value: notification.length),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => NewProfileScreen(
                                // callbackToinitialize: initialize(),

                                )));
                      },
                      child: Container(
                        width: 41,
                        child: UserClass.LoggedUser != null &&
                                UserClass.LoggedUser!.publicProfilePicUrl !=
                                    null
                            ? CircleAvatar(
                                backgroundImage:
                                    AssetImage("assets/profile.png"),
                                foregroundImage: CachedNetworkImageProvider(
                                    UserClass.LoggedUser!.publicProfilePicUrl!),
                                // onForegroundImageError: (){}AssetImage("assets/profile.png"),
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                              )
                            : CircleAvatar(
                                backgroundImage:
                                    AssetImage("assets/profile.png"),
                                radius: 60,
                                backgroundColor: Colors.grey[300],
                              ),
                      )),
                  // Container(
                  //   width: 120,
                  //   decoration: ShapeDecoration(
                  //     image: G.loggedinUser.privateProfilePicUrl != ""
                  //         ? DecorationImage(
                  //
                  //             image: CachedNetworkImageProvider(
                  //               G.HOST +
                  //                   "api/v1/images/" +
                  //                   G.loggedinUser.privateProfilePicUrl!,
                  //             ),
                  //             fit: BoxFit.contain,
                  //           )
                  //         : DecorationImage(
                  //             image: AssetImage("assets/profile.png"),
                  //             fit: BoxFit.contain,
                  //           ),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(100),
                  //     ),
                  //   ),
                  // ),

                  SizedBox(
                    width: 19,
                  ),
                ],
              ),
        // body: NestedScrollView(

        body: TabBarView(
            controller: _tabController,
            // physics: BouncingScrollPhysics(),
            children: [
              //CHAT

              RefreshIndicator(
                  onRefresh: () async {
                    log("refresh indicator called ");
                    await chatInitialize();
                  },
                  child: FinalFriendList.length > 0
                      ? ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: FinalFriendList.length,
                          itemBuilder: (ctx, i) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(10, 5, 20, 16),
                              child: Container(
                                  height: 56,
                                  child: InkWell(
                                    onTap: () {
                                      widget.__notificationService
                                          .cancelNotifications(12);
                                      if (FinalFriendList[i].newMessage != 0) {
                                        FinalFriendList[i].newMessage = 0;
                                      }
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (ctx) => ChattingScreen(
                                                  otherUserNumber:
                                                      FinalFriendList[i]
                                                          .phoneNumber!,
                                                  callBack: () async {
                                                    await chatInitialize();
                                                  },
                                                  otherUserDetail:
                                                      FinalFriendList[i])));
                                    },
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          
                                          Stack(children: [
                                            UnseenStory.contains(
                                                    FinalFriendList[i])
                                                ? Container(
                                                    width: 56,
                                                    height: 56,
                                                    child: SvgPicture.asset(
                                                        "assets/StoryNotseen.svg"))
                                                : SizedBox(),
                                            // Padding(
                                            //     padding: const EdgeInsets.only(
                                            //         left: 4.0),
                                            //     child: FinalFriendList[i]
                                            //                 .publicProfilePicUrl !=
                                            //             null
                                            //         ? CommanWidgets()
                                            //             .cacheProfileDisplay(
                                            //                 FinalFriendList[i]
                                            //                     .publicProfilePicUrl!)
                                            //         : Image(
                                            //             image: AssetImage(
                                            //                 "assets/profile.png"))
                                            //     ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0),
                                              child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    "assets/profile.png"),
                                                foregroundImage:
                                                    CachedNetworkImageProvider(
                                                        FinalFriendList[i]
                                                            .publicProfilePicUrl!),
                                                // onForegroundImageError: (){}AssetImage("assets/profile.png"),
                                                radius: 30,
                                                backgroundColor:
                                                    Colors.grey[300],
                                              ),
                                            )
                                          ]),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Column(
                                              // mainAxisAlignment:
                                              //     MainAxisAlignment
                                              //         .center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  child: Text(
                                                    FinalFriendList[i]
                                                            .publicName ??
                                                        "No Name",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF303030),
                                                        fontSize: 16,
                                                        fontFamily: 'Helvetica',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        height: 0,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      3,
                                                ),
                                                Expanded(
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2,
                                                    child: Text(
                                                      FinalFriendList[i]
                                                          .latestMessage!,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF707070),
                                                        fontSize: 14,
                                                        fontFamily: 'Helvetica',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 0,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Expanded(child: SizedBox()),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  5,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    findLatestTimeForFriend(
                                                        FinalFriendList[i]
                                                            .recieveTime
                                                            .toString()),
                                                    style: TextStyle(
                                                      color: Color(0xFF707070),
                                                      fontSize: 12,
                                                      fontFamily: 'Helvetica',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  FinalFriendList[i]
                                                              .newMessage !=
                                                          0
                                                      ? Container(
                                                          width: 22,
                                                          height: 20,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 5,
                                                                  left: 5,
                                                                  right: 5,
                                                                  bottom: 4),
                                                          decoration:
                                                              ShapeDecoration(
                                                            color: Color(
                                                                0xFFFF6701),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          40),
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              '${FinalFriendList[i].newMessage}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10,
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                height: 0,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Container(
                                                          width: 100,
                                                        )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                            );
                          })
                      :

                      ///if no chat
                      Stack(
                          children: [
                            Positioned(
                              // height: MediaQuery.of(context).size.height,
                              // width: MediaQuery.of(context).size.width,

                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 181,
                                        height: 181,
                                        decoration: ShapeDecoration(
                                          color: Color(0xFFFFEADC),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(130.99),
                                          ),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            "assets/noUser.svg",
                                            color: backendColor,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 45,
                                    ),
                                    SizedBox(
                                        width: 286,
                                        child: Text(
                                          'Invite your friends and family to chat on Koram!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF707070),
                                            fontSize: 14,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w400,
                                            height: 0,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    AddContactScreen(
                                                      callBackToInit: () {
                                                        // initialize();
                                                        // PushFriendsList();
                                                        widget
                                                            .StartcallscoketFunc();
                                                      },
                                                      friends: FinalFriendList,
                                                    )));
                                      },
                                      child: Container(
                                        width: 116,
                                        height: 54,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 18),
                                        decoration: ShapeDecoration(
                                          color: backendColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Start Chat',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.w700,
                                                height: 0,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                  //             Container(
                  //                 // height: FinalFriendList.length > 0
                  //                 //     ? MediaQuery.of(context).size.height - 100
                  //                 //     : MediaQuery.of(context).size.height - 200,
                  //                 child: isLoading
                  //                     ? Center(
                  //                         child: CircularProgressIndicator(),
                  //                       )
                  //                     :
                  //                         :
                  //
                  //                         //on no friends
                  //
                  // ),
                  ),

              ///STory block from here

              RefreshIndicator(
                onRefresh: () async {
                  await chatInitialize();
                },
                child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 108,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 26, 0, 26),
                              child: UserStory.isEmpty
                                  ? GestureDetector(
                                      onTap: () async {
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (ctx) {
                                              return StatefulBuilder(
                                                  builder: (ctx, setSate) {
                                                return Container(
                                                    height: 200,
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          onTap: () async {
                                                            XFile? i = await picker
                                                                .pickImage(
                                                                    imageQuality:
                                                                        30,
                                                                    source: ImageSource
                                                                        .camera);

                                                            if (i != null) {
                                                              log("inside the i not null");

                                                              image = await CommanWidgets()
                                                                  .cropAndAssign(
                                                                      i,
                                                                      context);
                                                              log("after crop and asssighn");
                                                              await addStory();
                                                            }

                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          leading: Icon(
                                                              Icons.camera_alt),
                                                          title: Text("Camera"),
                                                        ),
                                                        ListTile(
                                                          onTap: () async {
                                                            XFile? i = await picker
                                                                .pickImage(
                                                                    imageQuality:
                                                                        30,
                                                                    source: ImageSource
                                                                        .gallery);
                                                            if (i != null) {
                                                              image = await CommanWidgets()
                                                                  .cropAndAssign(
                                                                      i,
                                                                      context);
                                                            }
                                                            // setState(() {
                                                            //   image =
                                                            //       File(i!.path);
                                                            // });
                                                            Navigator.pop(
                                                                context);
                                                            await addStory();
                                                          },
                                                          leading: Icon(
                                                            Icons.image_rounded,
                                                            color: backendColor,
                                                          ),
                                                          title:
                                                              Text("Gallery"),
                                                        )
                                                      ],
                                                    ));
                                              });
                                            });
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 2,
                                                  color: backendColor
                                                      .withOpacity(0.5)),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: backendColor,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.add,
                                                size: 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          // SvgPicture.asset(
                                          //     "assets/AddstoryLogo.svg"),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'My Story',
                                                style: TextStyle(
                                                  color: Color(0xFF303030),
                                                  fontSize: 16,
                                                  fontFamily: 'Helvetica',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0,
                                                ),
                                              ),
                                              Text(
                                                'Tap and share your story',
                                                style: TextStyle(
                                                  color: Color(0xFF707070),
                                                  fontSize: 12,
                                                  fontFamily: 'Helvetica',
                                                  fontWeight: FontWeight.w400,
                                                  height: 0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ))
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            // Navigator.of(context).push(
                                            //     MaterialPageRoute(
                                            //         builder: (ctx) =>
                                            //             StoryViewScreen(loginUser, 0)));
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (ctx) => StoryPage(
                                                          pos: 0,
                                                          Users: [
                                                            UserClass
                                                                .LoggedUser!
                                                          ],
                                                        )));
                                          },
                                          child: Stack(children: [
                                            Container(
                                                width: 64,
                                                height: 64,
                                                child: SvgPicture.asset(
                                                    "assets/StoryNotseen.svg")),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 7),
                                              child: Center(
                                                child: ClipOval(
                                                  child: CachedNetworkImage(
                                                    width: 50,
                                                    height: 50,
                                                    fit: BoxFit.cover,
                                                    progressIndicatorBuilder:
                                                        (context, url,
                                                                progress) =>
                                                            Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value:
                                                            progress.progress,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                    ),
                                                    imageUrl: G.loggedinUser
                                                        .publicProfilePicUrl!,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (ctx) =>
                                                        MyStatus()));
                                          },
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'My Story',
                                                style: TextStyle(
                                                  color: Color(0xFF303030),
                                                  fontSize: 16,
                                                  fontFamily: 'Helvetica',
                                                  fontWeight: FontWeight.w500,
                                                  height: 0,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                '${DateFormat('dd MM yyyy').format(DateTime.parse(UserStory.first.postedTime ?? ""))}',
                                                style: TextStyle(
                                                  color: Color(0xFF707070),
                                                  fontSize: 12,
                                                  fontFamily: 'Helvetica',
                                                  fontWeight: FontWeight.w400,
                                                  height: 0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                              child: Center(
                                child: DottedLine(
                                  dashColor: Color(0xFFD8DCEC),
                                ),
                              ),
                            ),
                          ),
                          UnseenStory.isNotEmpty
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 20, 0, 22),
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Newly added',
                                          style: TextStyle(
                                            color: Color(0xFF667084),
                                            fontSize: 12,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w500,
                                            height: 0,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        Column(
                                          children: UnseenStory.map((item) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Navigator.of(context).push(MaterialPageRoute(
                                                  //     builder: (ctx) =>
                                                  //         StoryViewScreen(storyList, 0)));
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (ctx) =>
                                                              StoryPage(
                                                                pos: 0,
                                                                Users:
                                                                    UnseenStory,
                                                              )));
                                                },
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Stack(children: [
                                                        Container(
                                                            width: 65,
                                                            height: 65,
                                                            child: SvgPicture.asset(
                                                                "assets/StoryNotseen.svg")),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  4.5, 4, 4, 4),
                                                          child: Container(
                                                            width: 56,
                                                            height: 56,
                                                            decoration:
                                                                ShapeDecoration(
                                                              image: item.publicProfilePicUrl !=
                                                                      ""
                                                                  ? DecorationImage(
                                                                      image:
                                                                          CachedNetworkImageProvider(
                                                                        item.publicProfilePicUrl!,
                                                                      ),
                                                                      // NetworkImage(G
                                                                      //         .HOST +
                                                                      //     "api/v1/images/" +
                                                                      //     item.publicProfilePicUrl!),
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    )
                                                                  : DecorationImage(
                                                                      image: AssetImage(
                                                                          "assets/profile.png"),
                                                                      fit: BoxFit
                                                                          .fill),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        // CircleAvatar(
                                                        //
                                                        //     radius: 30,
                                                        //
                                                        //     child: Image.asset(
                                                        //       'assets/Mask Group 1.png',
                                                        //       // fit: BoxFit.cover,
                                                        //     )) ,
                                                      ]),
                                                      // StoryItem(item.profilePicUrl),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                              child: Text(
                                                            item.publicName ??
                                                                "",
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF303030),
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              height: 0,
                                                            ),
                                                          )),
                                                          Text(
                                                            formatDateTime(
                                                                DateTime.parse(item
                                                                    .story!
                                                                    .last
                                                                    .postedTime
                                                                    .toString())),
                                                            // "yoyo",

                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF707070),
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              height: 0,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          SeenStory.isNotEmpty
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(24, 20, 0, 22),
                                  child: Container(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Previously seen',
                                            style: TextStyle(
                                              color: Color(0xFF667084),
                                              fontSize: 12,
                                              fontFamily: 'Helvetica',
                                              fontWeight: FontWeight.w500,
                                              height: 0,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Column(
                                            children: SeenStory.map((item) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    // Navigator.of(context).push(MaterialPageRoute(
                                                    //     builder: (ctx) =>
                                                    //         StoryViewScreen(storyList, 0)));
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (ctx) =>
                                                                StoryPage(
                                                                  pos: 0,
                                                                  Users:
                                                                      SeenStory,
                                                                )));
                                                  },
                                                  child: Container(
                                                    child: Row(
                                                      children: [
                                                        Stack(children: [
                                                          Container(
                                                              width: 64,
                                                              height: 64,
                                                              child: SvgPicture
                                                                  .asset(
                                                                      "assets/StorySeen.svg")),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            child: Container(
                                                              width: 56,
                                                              height: 56,
                                                              decoration:
                                                                  ShapeDecoration(
                                                                image: item.publicProfilePicUrl !=
                                                                        ""
                                                                    ? DecorationImage(
                                                                        image:
                                                                            CachedNetworkImageProvider(
                                                                          item.publicProfilePicUrl!,
                                                                        ),
                                                                        // NetworkImage(G
                                                                        //         .HOST +
                                                                        //     "api/v1/images/" +
                                                                        //     item.publicProfilePicUrl!),
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      )
                                                                    : DecorationImage(
                                                                        image: AssetImage(
                                                                            "assets/profile.png"),
                                                                        fit: BoxFit
                                                                            .fill),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          // CircleAvatar(
                                                          //
                                                          //     radius: 30,
                                                          //
                                                          //     child: Image.asset(
                                                          //       'assets/Mask Group 1.png',
                                                          //       // fit: BoxFit.cover,
                                                          //     )) ,
                                                        ]),
                                                        // StoryItem(item.profilePicUrl),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                                child: Text(
                                                              item.publicName ??
                                                                  "",
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF303030),
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                height: 0,
                                                              ),
                                                            )),
                                                            Text(
                                                              formatDateTime(
                                                                  DateTime.parse(item
                                                                      .story!
                                                                      .last
                                                                      .postedTime
                                                                      .toString())),
                                                              style: TextStyle(
                                                                color: Color(
                                                                    0xFF707070),
                                                                fontSize: 12,
                                                                fontFamily:
                                                                    'Helvetica',
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                height: 0,
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ]),
                                  ))
                              : SizedBox()
                        ],
                      ),
                    ]),
              )
            ]),
      );
    });
  }
}
