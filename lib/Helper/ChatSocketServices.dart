import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:koram_app/Models/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../Models/ChatRoom.dart';
import '../Models/Message.dart';
import 'DBHelper.dart';
import 'Helper.dart';

final Uuid uuid = Uuid();

// Define a model for managing socket connection state
class ChatSocket extends ChangeNotifier {
  // IO.Socket Socket = IO.io(
  //     "http://${G.IP}:4000/",
  //     IO.OptionBuilder()
  //         .setTransports(['websocket'])
  //         .setExtraHeaders({'foo': 'bar'})
  //         .disableAutoConnect()
  //         .build());
  IO.Socket Socket = IO.io(
  "http://${G.IP}:4000/",
  IO.OptionBuilder()
      .setTransports(['websocket']) // Use websocket transport
      .enableReconnection()         // Enable automatic reconnection
      .setReconnectionAttempts(5)   // Max reconnection attempts
      .setReconnectionDelay(1000)   // Delay between reconnections (ms)
      .setExtraHeaders({'foo': 'bar'}) // Optional headers
      .disableAutoConnect()         // Disable auto-connect on initialization
      .build(),
  );

  int count = 0;
  List<PrivateMessage> receivedMessages = [];

  // Getter for accessing the received messages
  // Getter for accessing the socket
  bool isInititalized = false;
  var messageData;
  var chatRoomOnLeft;
  var chatRoomOnJoin;
  PrivateMessage? chatRoomInvite;
  bool isMessageReceived = false;
  List<PrivateMessage> CurrentMessge = [];
  List<PrivateMessage> MessageStore = [];
  PrivateMessage? RecentMessageData;

  // Function to initialize socket connection
  storeAllMessageToRuntime() async {
    log("storing to the main messageStore");
    MessageStore = await DBProvider.db.getAllPrivateMessages();
    log("message store length ${MessageStore.length}");
  }

  List<PrivateMessage> getMessageByPhoneRuntime(String phoneNumber) {
    log("message store length ${MessageStore.length}");
    log("storing to the main ${phoneNumber}");

    List<PrivateMessage> filteredMessage = MessageStore.where(
        (e) => e.sentTo == phoneNumber || e.sentBy == phoneNumber).toList();
    log("message store length ${MessageStore.length}");
    return filteredMessage;
  }

  void _showNotification(PrivateMessage message) {
    log("showing notifiaction ");
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,

        channelKey: 'message_channel',
        title: '${message.senderName}',
        body: '${message.message}',
        displayOnBackground: true,
        displayOnForeground: true,
        backgroundColor: Colors.white,
        notificationLayout: NotificationLayout.Default,
        payload: message.toStrings(),
      ),
    );
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }

  Future<bool> checkServerAvailability(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return true;
      } else {
        log('Server check failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Server check failed with error: $e');
      return false;
    }
  }

  void initializeSocket() async {
    log("calling Chatsocket $count");
    count++;

    // final serverAvailable = await checkServerAvailability("http://${G.IP}:4000/");
    // if (!serverAvailable) {
    //   log("Server is not available. Socket initialization aborted.");
    //   return;
    // }

    log("initilize chat socket called ");
    final prefs = await SharedPreferences.getInstance();
    // Socket = IO.io(
    //     // "https://ws.koram.in/",
    //     "http://${G.IP}:4000/",
    //     IO.OptionBuilder()
    //         .setTransports(['websocket']) // for Flutter or Dart VM
    //         .disableAutoConnect() // disable auto-connection
    //         .setExtraHeaders({'foo': 'bar'}) // optional
    //         .build());
    Socket?.connect();

    // if(_socket !=null )
    // {
    //   log("inside socket !nulll ${_socket}");
    //   if(_socket!.disconnected){
    //     log(" isnide socket disconnected ");
    //
    // }
    //
    //
    // }

    // Subscribe to socket connection events
    Socket?.onConnect((_) {
      log('Connected to chat socket server');
    });

    Socket?.onConnectError((error) {
      log('Error connecting to chat socket server: $error');
    });

    Socket?.onDisconnect((_) {

      log('Disconnected from socket server');
    });
    // Listen for successful reconnections
    Socket?.onReconnect((_) {
      log('Successfully reconnected to the server');
      notifyListeners(); // Notify listeners when reconnection is successful
    });

    // Listen for reconnection attempts
    Socket?.onReconnectAttempt((attempt) {
      log('Attempting to reconnect... Attempt: $attempt');
    });

    // Handle reconnection errors
    Socket?.onReconnectError((error) {
      log('Error during reconnection: $error');
    });

    // Handle reconnection failures
    Socket?.onReconnectFailed((_) {
      log('Reconnection failed. Giving up.');
    });



    Socket.on("messageReadConfirmation", (data) async {
      messageData = jsonDecode(jsonEncode(data));
      log("the read confirmation in main provider ${messageData}");
      MessageStore = await DBProvider.db.getAllPrivateMessages();
      messageData["messageID"].forEach((ids) {
        DBProvider.db.updateMessageStatus(ids, "read");
            log("the updated id ${ids}");
        // final PrivateMessage? chatElement = MessageStore.firstWhere((element) => element.messageId == ids);
        // if (chatElement != null) {
        //   chatElement.messageStatus = "sent";
        // }
      });

      // notifyListeners();
    });
    Socket.on("message-receive", (data) async {


      log("in message received provider ${jsonDecode(data)}");

      messageData = jsonDecode(data);

      PrivateMessage receivedMessage = PrivateMessage.fromMap(jsonDecode(data));
      if (receivedMessage.sentTo == G.userPhoneNumber) {

        RecentMessageData = receivedMessage;
        await DBProvider.db.newPrivateMessage(receivedMessage);
        notifyListeners();
        _showNotification(receivedMessage);
      }
    });

    Socket.on("leftRoomBroadcast", (data) async {
      log("leftRoomBroadcast data  ${jsonEncode(data)}");

      chatRoomOnLeft = data;
      notifyListeners();
    });

    Socket.on("joinedRoomBroadCast", (data) async {
      log("joinedroom data  ${jsonEncode(data)}");
      var ReceivedData = data;
      if (ReceivedData["userPhoneNumber"] == G.userPhoneNumber) {
        chatRoomOnJoin = data;
        notifyListeners();
      }
    });
    Socket.on("roomInviteBroadCast", (data) async {
      log("room invite data  ${jsonEncode(data)}");
      var ReceivedData = data;
      log("the sent to ${ReceivedData["sentTo"]}");
      if (ReceivedData["sentTo"] == G.userPhoneNumber) {
        PrivateMessage receivedMessage = PrivateMessage.fromMap(data);
        if (receivedMessage.sentTo == G.userPhoneNumber) {
          // Socket?.emit(
          //     'messageAcknowledgment', {"isDeliver": true, "isSeen": true});
          chatRoomInvite = receivedMessage;
          DBProvider.db.newPrivateMessage(receivedMessage);
          notifyListeners();
          _showNotification(receivedMessage);
        }
        // _showNotification(receivedMessage);
      }
    });
    Socket?.on("MessageAck", (data) async {});
    PrivateMessage re;

    Socket?.on("messageAcknowledgment", (data) {
      var _message = prefs.getStringList("messages") ?? [];
      List<PrivateMessage> PvtMessage = [];
      for (var m in _message) {
        PvtMessage.add(PrivateMessage.fromMap(jsonDecode(m)));
      }

      re = PrivateMessage.fromMap(jsonDecode(data));
      PvtMessage.forEach((element) {
        if (element.message == re.message) {
          element.isDelivered = true;
          element.isSeen = false;
        }
      });
    });
    isInititalized = true;
  }

  // sendMessage(var messageJson, BuildContext context) async {
  //   log("emit send message called");
  //   bool isMessageSent = false;
  //
  //   var responseOfGettoken = await G.getTokenBynumber(messageJson["sentTo"]);
  //   if (responseOfGettoken == "error") {
  //     return false;
  //   }
  //   messageJson['fcmToken'] = responseOfGettoken;
  //
  //   Socket.emitWithAck("message", json.encode(messageJson),
  //       ack: (response) async {
  //     log("got the callback");
  //
  //     var decodedResponse = jsonDecode(jsonEncode(response));
  //     log('Server call ack after sending message: ${jsonEncode(decodedResponse)}');
  //     String messageId = decodedResponse["data"]["messageId"];
  //
  //     // final PrivateMessage? chatElement =
  //     //     MessageStore.firstWhere((element) => element.messageId == messageId);
  //     // if (chatElement != null) {
  //     //   chatElement.messageStatus = "sent";
  //     // }
  //     await DBProvider.db.updateMessageStatus(messageId, "sent");
  //     log("messagee status updatred for id ${messageId}");
  //     notifyListeners();
  //
  //
  //
  //   });
  //
  //   // Socket?.emit("message", json.encode(messageJson));
  //   // Provider.of<UsersProviderClass>(context, listen: false)
  //   //     .triggerUserNotifier();
  //   // return isMessageSent;
  // }
  sendMessage(var messageJson) async {
    log("emit send message called");

    var responseOfGettoken = await G.getTokenBynumber(messageJson["sentTo"]);
    if (responseOfGettoken == "error") {
      return false;  // Return false if the token fetching fails
    }

    messageJson['fcmToken'] = responseOfGettoken;

    // Return a Future that completes when the ack is received
    final completer = Completer<bool>();

    Socket.emitWithAck("message", json.encode(messageJson), ack: (response) async {
      log("got the callback");

      var decodedResponse = jsonDecode(jsonEncode(response));
      log('Server call ack after sending message: ${jsonEncode(decodedResponse)}');
      String messageId = decodedResponse["data"]["messageId"];

      await DBProvider.db.updateMessageStatus(messageId, "sent");
      log("message status updated for id ${messageId}");

      notifyListeners();

      // Complete the Future with true when the message is sent
      completer.complete(true);
    });

    return completer.future;  // Return the Future
  }
  sendListOfUnsentMessage(var messages,List<PrivateMessage> privateMessages)
  {
    log("sending unsent message fucntion called ${messages}");
    // Return a Future that completes when the ack is received
    final completer = Completer<bool>();
    Socket.emitWithAck("listOfUnsentMessage", messages, ack: (response) async {
      log("got the callback for list of unsent messages");

      var decodedResponse = jsonDecode(jsonEncode(response));
      log('Server call ack after sending message: ${jsonEncode(decodedResponse)}');


      await DBProvider.db.updateListMessageStatus( privateMessages
          .map((message) => message.messageId)
          .where((id) => id != null)
          .cast<String>() // Cast to List<String> after filtering nulls
          .toList(), "sent");
      log("message status updated for id ");

      notifyListeners();

      // Complete the Future with true when the message is sent
      completer.complete(true);
    });
  }
  sendMessageRead(String userPhoneNumber, List<String?> messageId) {
    log("send Message read  $userPhoneNumber $messageId");
    Socket.emit("messageRead",
        {"userPhoneNumber": userPhoneNumber, "messageID": messageId});
  }
  updateMessageStatus(List<String?> messageId)
  {

  }

  sendLeftRoom(String userPhoneNumber, String groupId) {
    log("send Message Called  $userPhoneNumber $groupId");
    Socket.emit(
        "leftRoom", {"userPhoneNumber": userPhoneNumber, "GroupId": groupId});
  }

  sendJoinedRoom(String userPhoneNumber, String groupId) {
    log("send joined  Message Called  $userPhoneNumber $groupId");
    Socket.emit(
        "joinedRoom", {"userPhoneNumber": userPhoneNumber, "GroupId": groupId});
  }

  sendRoomInvite(ChatRoom group, String sendTo) {
    //   Location
    // Interest
    // Trending
    // Favourite
    String messageId = uuid.v1();
    var messageJson = {
      "messageId": messageId,
      "message": "Join the ${group.name} Room",
      "sentBy": G.userPhoneNumber,
      "sentTo": sendTo,
      "time": DateTime.now().toString(),
      "groupId": group.id,
      "type": group.category,
      "groupName": group.name
    };

    log("send room invite  Message Called  $sendTo ${group.name}");
    Socket.emit("roomInvite", messageJson);
  }
  sendUnsentMessages()async{
   List<PrivateMessage>UnsentMessage= await DBProvider.db.getUnsentPrivateMessage();
   UnsentMessage.forEach((theMessage){});
   // sendMessageRead();
  }
  void disconnectSocket() {
    Socket?.disconnect();
    isInititalized = false;
  }

  // Manually attempt reconnect if desired
  void attemptReconnect() {
    log('Manually attempting to reconnect...');
    Socket?.connect();
  }
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
  //     disconnectSocket();
  //   } else if (state == AppLifecycleState.resumed) {
  //     initializeSocket();
  //   }
  // }
}
