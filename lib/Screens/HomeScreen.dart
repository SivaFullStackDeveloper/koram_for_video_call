import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:koram_app/Helper/DBHelper.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Helper/NotificationServices.dart';
import 'package:koram_app/Helper/PageProviderService.dart';
import 'package:koram_app/Models/Message.dart';
import 'package:koram_app/Models/Notification.dart' as N;
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Screens/AudioCalling.dart';
import 'package:koram_app/Screens/CallHistory.dart';
import 'package:koram_app/Screens/Chat.dart';
import 'package:koram_app/Screens/ChatRoom.dart';
import 'package:koram_app/Screens/LoginScreen.dart';
import 'package:koram_app/Screens/NearBy.dart';
import 'package:koram_app/Screens/PrivateProfileScreen.dart';
import 'package:koram_app/Screens/test.dart';
import 'package:koram_app/Widget/Badge.dart';
import 'package:koram_app/Widget/BottomSheetContent.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Helper/CallSocketServices.dart';
import '../Helper/ChatSocketServices.dart';
import '../Helper/ConnectivityProviderService.dart';
import '../Helper/RuntimeStorage.dart';
import '../Models/ChatRoom.dart';
import '../main.dart';
import 'DatingScreen.dart';
import 'DecideDating.dart';
import 'VideoCallingScreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class HomeScreen extends StatefulWidget with WidgetsBindingObserver {
  HomeScreen({Key? key, this.justRegisteredDate,this.backgroundCAll}) : super(key: key);
  bool? justRegisteredDate = false;
  bool? backgroundCAll=false;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showAudioCall = false;
  var temp;
  // var page = 0;
  var caller;
  String? CallType;
  bool isHomeCallActive = true;
  int count = 0;
  bool isListening = true;
  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  void initState() {
if(widget.backgroundCAll==true)
{
  MainNavigatorKey.currentState?.pushNamed(
    '/audioCallScreen',
    arguments: {
      'callerName': G.loggedinUser.phoneNumber,
      'callerNumber': "+919876543211",
      'isIncoming': true,
      'isVideoCall': false,

    },
  );
}
    // if (widget.justRegisteredDate == true) {
    //   setState(() {
    //     page = 2;
    //   });
    //
    //
    // }

    // StartCallSocket();
//     FirebaseMessaging.onMessage.listen(( RemoteMessage message) {
//       // var title=message.notification?.title;
//       // var body=message.notification?.body;
// //       List<dynamic>  messageDetail=jsonDecode(message.data.toString());
// // for(var r in messageDetail)
// // {
// //   log("yoyoyoyoyoy"+r);
// // }
//       print("befoore printing ");
//       print(message.data);
//       List<int> decompressedData = GZipCodec().decode(base64.decode(message.data["offer"]));
//
//       // Convert the decompressed data to a string (assuming it was originally a string)
//       String originalDataString = utf8.decode(decompressedData);
//
//       // Print or use the original data
//       print('Decompressed Data: $originalDataString');
//       AwesomeNotifications().createNotification(content: NotificationContent(id: 123, channelKey:"call_channel",
//           color: Colors.white,
//           title: message.data["name"],
//           body: "Calling...",
//           category: NotificationCategory.Call,
//           wakeUpScreen: true,
//           fullScreenIntent: true,
//           autoDismissible: false,
//           backgroundColor: RuntimeStorage.instance.PrimaryOrange
//
//       ),
//           actionButtons: [NotificationActionButton(key: "accept_call",
//
//               label: "Accept Call",color: Colors.green,autoDismissible: true),
//             NotificationActionButton(key: "reject_call",
//                 label: "Reject Call",color: Colors.red,autoDismissible: true)]
//
//
//       );
//       AwesomeNotifications().setListeners(onActionReceivedMethod: (w)async{
//
//         if(w.buttonKeyPressed=="accept_call"){
//           print("call accepted");
//           log("making call request");
//
//           // _channel.sink.add(jsonEncode({
//           //   "type": "callRequestResponse",
//           //   "callStatus": "Accepted",
//           //   "name": message.data["name"],
//           //   "caller_Name": G.userId,
//           //   "callType": "Audio",
//           // }));
//
//           String modifiedString = message.data["name"].replaceAll(RegExp(r'[^0-9+]'), '');
//
//           print("Modiefff from call request accept caller number "+modifiedString);
//
//           Navigator.of(context).push(MaterialPageRoute(
//               builder: (context) => AudioCallingScreen(
//                 sockettemp: originalDataString,
//                 isfromNotification: true,
//                 isReceiving: true,
//                 callTo: modifiedString,
//                 caller: G.userId,
//
//                 callback: (){StartCallSocket();},
//               )));
//         }else
//         if(w.buttonKeyPressed=="reject_call")
//         {
//           // _channel.sink.add(jsonEncode({
//           //   "type": "callRequestResponse",
//           //   "callStatus": "Rejected",
//           //   "name": message.data["name"],
//           //   "caller_Name": G.userId,
//           //   "callType": "Audio",
//           // }));
//           print("call rejected");
//           AwesomeNotifications().cancel(123);
//         }else
//         {
//           print("clicked on notification");
//         }
//
//       });
//       print("FOREGROUND frOM homee $message");
//
//
//     });

    // StartCallSocket();
    // firebaseFunction();
    // _channel = IOWebSocketChannel.connect("ws://${G.IP}:9090");
    // _channel.sink.add(jsonEncode({
    //   "type": "present",
    //   "name": G.userId,
    // }));
    // _channel.stream.listen((message) {
    //   log("messssageee $message");
    //   temp = jsonDecode(message);
    //   switch (temp["type"]) {
    //     case "offer":
    //       {
    //         var offer;
    //         setState(() {
    //           caller = temp["name"];
    //           showAudioCall = true;
    //           offer = temp["offer"];
    //         });
    //
    //         log("offerr json   ${temp['offer']}   call Type ${temp["callType"]}");
    //         if (temp["callType"] == "Audio") {
    //           Navigator.of(context).push(MaterialPageRoute(
    //               builder: (context) => AudioCallingScreen(
    //                     sockettemp: offer,
    //                     isReceiving: true,
    //                     callTo: caller,
    //                     caller: G.userId,
    //                   )));
    //
    //           log("Audio offer");
    //         } else if (temp["callType"] == "Video") {
    //           Navigator.of(context).push(MaterialPageRoute(
    //               builder: (context) => VideoCallingScreen(
    //                     sockettemp: offer,
    //                     isReceiving: true,
    //                     callTo: caller,
    //                     caller: G.userId,
    //                   )));
    //
    //           log("Videoo offer");
    //         }
    //       }
    //       break;
    //     case "answer":
    //       {
    //         log("answer answer");
    //       }
    //       break;
    //
    //     case "candidate":
    //       {}
    //       break;
    //
    //     case "leave":
    //       {}
    //       break;
    //   }
    // }, onDone: () {
    //   log("HomeScreen Channel Done Listening @@@@@@@");
    // });

    // socket = IO.io(
    //     // "https://ws.koram.in/",
    //     "http://${G.IP}:4000",
    //     IO.OptionBuilder()
    //         .setTransports(['websocket']) // for Flutter or Dart VM
    //         .disableAutoConnect() // disable auto-connection
    //         .setExtraHeaders({'foo': 'bar'}) // optional
    //         .build());
    // socket.connect();
    //  socket.emit("join",G.userId);
    // socket.onDisconnect((data) => {socket.emit("disconnect",G.userId)});
    //  setupSocketListener();
    // Future.delayed(Duration.zero).then((value) async {
    //    Provider.of<N.Notifications>(context, listen: false)
    //       .fetchNotification();
    // });

    super.initState();
  }



  // StartCallSocket() {
  //   log("start Call Sockett");
  //   _channel = IOWebSocketChannel.connect("ws://${G.IP}:9090");
  //
  //   _channel.sink.add(jsonEncode({
  //     "type": "present",
  //     "name": G.userPhoneNumber,
  //   }));
  //   // _channel = IOWebSocketChannel.connect("ws://24.199.85.25:9090/");
  //
  //   _channel.stream.listen((message) {
  //     // log("messssageee calll socket in homeeee $message");
  //     temp = jsonDecode(message);
  //     switch (temp["type"]) {
  //       case "offer":
  //         {
  //           var offer;
  //           setState(() {
  //             caller = temp["name"];
  //             showAudioCall = true;
  //             offer = temp["offer"];
  //           });
  //
  //           log("offerr json   ${temp['offer']}   call Type ${temp["callType"]}");
  //           if (temp["callType"] == "Audio") {
  //             Navigator.of(context).push(MaterialPageRoute(
  //                 builder: (context) => AudioCallingScreen(
  //                   isfromNotification: false,
  //                       sockettemp: offer,
  //                       isReceiving: true,
  //                       callTo: caller,
  //                       caller: G.userPhoneNumber,
  //                     callback:(){
  //                     log("inside cstart call socket callback");
  //                         StartCallSocket();
  //                       }
  //                     )));
  //
  //             log("Audio offer");
  //           } else if (temp["callType"] == "Video") {
  //             Navigator.of(context).push(MaterialPageRoute(
  //                 builder: (context) => VideoCallingScreen(
  //                       sockettemp: offer,
  //                       isReceiving: true,
  //                       callTo: caller,
  //                       caller: G.userPhoneNumber,
  //                     callback:(){
  //                       StartCallSocket();
  //                     }
  //                     )));
  //
  //             log("Videoo offer");
  //           }
  //         }
  //         break;
  //       case "answer":
  //         {
  //           log("answer answer from Homeeee");
  //         }
  //         break;
  //
  //       case "candidate":
  //         {
  //           log("CAndidate from home");
  //
  //         }
  //         break;
  //
  //       case "leave":
  //         {
  //            log("inside case leave of home  adding present");
  //           _channel.sink.add(jsonEncode({
  //             "type": "present",
  //             "name": G.userPhoneNumber,
  //           }));
  //         }
  //         break;
  //     }
  //   }, onDone: () {
  //     setState(() {
  //       isHomeCallActive=false;
  //     });
  //     log("HomeScreen Channel Done Listening @@@@@@@");
  //   });
  // }

  NotificationService _notificationService = NotificationService();

  // void setupSocketListener() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.getString("");
  //   socket.on("message-receive", (data) async {
  //     data = json.decode(data);
  //     if (data["sentTo"] == G.userPhoneNumber)
  //       await _notificationService.showNotifications(data);
  //
  //     log("SEtUPSocketListner");
  //     log(data["sentTo"]);
  //     log(data["sentBy"]);
  //     List<String> _message = [];
  //     _message = prefs.getStringList("messages") ?? [];
  //     if (data["sentTo"] == G.userPhoneNumber) {
  //       if (mounted)
  //         setState(() {
  //           _message.add(json.encode(data));
  //
  //           // _message = _message;
  //         });
  //       log(_message.toString());
  //       prefs.setStringList("messages", _message);
  //       log(prefs.getStringList("messages").toString());
  //     }
  //   });
  // }

  getChildren(int pageService) {
    log("pageSErvice ${pageService}");
    switch (pageService) {
      case 0:
        return ChatScreen(_notificationService, () {
          // StartCallSocket();
        });
      // Test(
      // "/9j/4QG1RXhpZgAATU0AKgAAAAgABwEQAAIAAAAaAAAAYgEAAAQAAAABAAAEOAEBAAQAAAABAAAHgAEyAAIAAAAUAAAAfAESAAMAAAABAAEAAIdpAAQAAAABAAAAlwEPAAIAAA==");
      case 1:
        return ChatRoomScreen();
      case 2:
        return NearByScreen();
      // //   return datingScreen();
      // return DecideDating(isJustRegistered: widget.justRegisteredDate??false,);
      case 3:
        return CallHistoryScreen();
    }
  }

  void _navigateToAudioCallingScreen(
      BuildContext context, String receiverNo, String imageURL,bool isVideo) {

    WidgetsBinding.instance.addPostFrameCallback((_) {

      Navigator.of(context)
          .push(MaterialPageRoute(
        builder: (context) => AudioCallingScreen(
          isfromNotification: false,
          // sockettemp: offer,
          isIncoming: true,
          callTo: receiverNo,
          caller: G.userPhoneNumber,
          callerURl: imageURL,
          isVideoCall: isVideo,
        ),
      ));
      //     .then((value) {
      //   setState(() {
      //     isListening = false;
      //   });
      // });

    });

  }

  void _navigateToVideoCallingScreen(BuildContext context, String receiverNo) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => VideoCallingScreen(
        isReceiving: true,
        callTo: receiverNo,
        caller: G.userPhoneNumber,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {

    log("home screen build count $count");

    ChatSocket chatSocket = Provider.of<ChatSocket>(context, listen: false);
    connectivityProvider connectivity= Provider.of<connectivityProvider>(context, listen: true);
      connectivity.startConnectivityListener();
      // if(connectivity.connectionStatus!=null)
      // {
      //   log("change notify called ${connectivity.connectionStatus}");
      // }

    if(!chatSocket.Socket.connected)
     {
       log("initializing chat socket from home ");

       chatSocket.initializeSocket();
     }
    final callSocket =
        Provider.of<CallSocketService>(context, listen: isListening);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!callSocket.isConnected) {
        log("inside call socket not connected");
        callSocket.init();

      }
    });

    count++;
    log("callsocket temp ${callSocket.temp}");
    if (callSocket.temp != null && callSocket.temp["type"] == "CallRequest") {
      log("inside the home sccreen if cond");
      // var offer = callSocket.temp["offer"];
      if (callSocket.temp["callType"] == "Audio") {
        log("Navigating from home to Audio");
        _navigateToAudioCallingScreen(context, callSocket.temp["callerNo"],
            callSocket.temp["receiver_profile_pic_url"],false);

        callSocket.temp=null;
      } else if (callSocket.temp["callType"] == "Video") {
        _navigateToAudioCallingScreen(context, callSocket.temp["callerNo"],
            callSocket.temp["receiver_profile_pic_url"],true);
        callSocket.temp=null;
      }
    }


    List<N.Notification> notification =
        Provider.of<N.Notifications>(context).notification;
    pageProviderService pageService= Provider.of(context,listen: true);
    return PopScope(
      canPop: false,
      onPopInvoked: (e) async {
        log("pop invokedd $e");

        if(pageService.page!=0)
        {
          if(pageService.page==1)
          {
            if(ChatRoomsProvider.isChangePage)
            {
              log("pageChange was true");
              setState(() {
                pageService.goToPage(0);
                // page=0;
              });
              return;
            }
               log("page was one ${ChatRoomsProvider.isChangePage} so retuned the pop ");

               return;
          }
          setState(() {
            pageService.goToPage(0);
            // page=0;
          });
          return;
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Exit App'),
              content: Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                    Navigator.of(context).pop(true); // Pop the screen
                  },
                  child: Text('Exit'),
                ),
              ],
            );
          },
        );

        // Return false to prevent the screen from popping
      },
      child: Scaffold(

        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              height: 0.5, // Adjust the height as needed
              color: Colors.black12, // Line color
            ),
            BottomNavigationBar(
              elevation: 0,
              showSelectedLabels: true,
              selectedItemColor: Color(0xFFFF6701),
              backgroundColor: Colors.white,
              currentIndex: pageService.page,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: TextStyle(
                color: Color(0xFFFF6701),
                fontSize: 11,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w800,
              ),
              unselectedItemColor: Color(0xFF707070),
              unselectedLabelStyle: TextStyle(
                color: Color(0xFF707070),
                fontSize: 10,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w400,
              ),
              showUnselectedLabels: true,
              items: [
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                          height: 40,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SvgPicture.asset(pageService.page == 0
                                ? 'assets/ChatSelected.svg'
                                : 'assets/ChatUnselected.svg'),
                          )),
                    ),
                    label: "Messages"),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                          height: 40,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SvgPicture.asset(pageService.page == 1
                                ? 'assets/ChatroomSelected.svg'
                                : 'assets/ChatroomUnselected.svg'),
                          )),
                    ),
                    label: "Chat Rooms"),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                          height: 40,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SvgPicture.asset(pageService.page == 2
                                ? 'assets/nearbySelected.svg'
                                : 'assets/nearbyunSelected.svg'),
                          )),
                    ),
                    label: "NearBy"),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                          height: 40,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: SvgPicture.asset(pageService.page == 3
                                ? 'assets/CallSelected.svg'
                                : 'assets/CallUnselected.svg'),
                          )),
                    ),
                    label: "Call Logs"),
              ],
              onTap: (index) {

                setState(() {
                  pageService.goToPage(index);
                });
              },
            ),
          ],
        ),
        body:
            // FutureBuilder<List<PrivateMessage>>(
            //   future: DBProvider.db.getAllPrivateMessages(),
            //   builder:
            getChildren(pageService.page),
        // ),
        // floatingActionButton: page != 0
        //     ? null
        //     : FloatingActionButton(
        //         onPressed: () {},
        //         child: Image.asset("assets/Group 510.png"),
        //       ),
      ),
    );
  }
}
