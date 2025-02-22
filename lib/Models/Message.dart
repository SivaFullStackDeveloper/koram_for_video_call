import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:http/http.dart' as http;

class PrivateMessage {
   String? messageId;
  final String message;
  final String time;
  final sentTo;
  final sentBy;
  final senderName;
  final receiverName;
  bool isSeen;
  String messageStatus="notSent";
  bool? isRead;
  bool isDelivered;
  String? fileName;
  String? groupId;
  String? type;
  String? groupName;
  PrivateMessage(
      { this.messageId,
      required this.message,
      required this.time,
      required this.sentBy,
      required this.sentTo,
      required this.isDelivered,
      required this.isSeen,
      this.fileName,
      required this.receiverName,
      required this.senderName,
      this.groupId,
        required this.messageStatus,
        this.groupName,
        this.type,
         this.isRead
      });
  factory PrivateMessage.fromMap(Map<String, dynamic> json) {
    var deliverValue;
    var seenValue;
    var isReadValue;
    if (json["isDelivered"] == "true") {
      deliverValue = true;
    } else {
      deliverValue = false;
    }
    if (json["isSeen"] == "true") {
      seenValue = true;
    } else {
      log("setting false in is seen for ${json["message"]}");
      seenValue = false;
    }
    if (json["isRead"] == "true") {
      isReadValue = true;
    } else {
      isReadValue = false;
    }
    return new PrivateMessage(
      messageId: json["messageId"],
      message: json["message"],
      time: json["time"],
      sentBy: json["sentBy"],
      sentTo: json["sentTo"],
      senderName: json["senderName"],
      receiverName: json["receiverName"],
      isDelivered: deliverValue,
      fileName: json["fileName"],
      groupId: json["groupId"],
      groupName: json["groupName"],
      messageStatus: json["messageStatus"]??"notSent",
      type: json["type"],
      isSeen: seenValue,
      isRead: isReadValue
    );
  }
   factory PrivateMessage.fromStringMap(Map<String, String?> json) {
     var deliverValue;
     var seenValue;
     var isReadValue;
     if (json["isDelivered"] == "true") {
       deliverValue = true;
     } else {
       deliverValue = false;
     }
     if (json["isSeen"] == "true") {
       seenValue = true;
     } else {
       seenValue = false;
     }
     return new PrivateMessage(
       messageId: json["messageId"],
       message: json["message"]??"",
       time: json["time"]??"",
       sentBy: json["sentFrom"],
       sentTo: json["sentTo"],
       senderName: json["senderName"],
       receiverName: json["receiverName"],
       isDelivered: deliverValue,
       fileName: json["fileName"],
       groupId: json["groupId"],
       groupName: json["groupName"],
       type: json["type"],
       messageStatus: json["messageStatus"]??"sent",
       isSeen: seenValue,
       isRead: isReadValue
     );
   }

   Map<String, dynamic> toMap() => {
        "messageId": messageId,
        "message": message,
        "time": time,
        "sentFrom": sentBy,
        "sentTo": sentTo,
        "senderName": senderName,
        "receiverName": receiverName,
        "isDelivered": isDelivered,
        "isSeen": isSeen,
        "fileName": fileName,
        "groupId":groupId,
       "groupName":groupName,
    "type":type,
"messageStatus":messageStatus,
"isRead":isRead
      };
   Map<String, String> toStrings() =>

       {
     "messageId": messageId.toString(),
     "message": message.toString(),
     "time": time.toString(),
     "sentFrom": sentBy.toString(),
     "sentTo": sentTo.toString(),
     "senderName": senderName.toString(),
     "receiverName": receiverName.toString(),
     "isDelivered": isDelivered.toString(),
     "isSeen": isSeen.toString(),
     "fileName": fileName.toString(),
     "groupId":groupId.toString(),
     "groupName":groupName.toString(),
     "type":type.toString(),
         "messageStatus":messageStatus.toString(),
       "isRead":isRead.toString()

   };
}

class GroupMessage {
  final String message;
  final DateTime sentTime;
  final String senderPublicName;
  final groupId;
  final sentFrom;
  String? fileName;
  bool? isDelivered;
  GroupMessage({
    this.isDelivered,
    this.fileName,
    required this.senderPublicName,
    required this.message,
    required this.sentTime,
    required this.sentFrom,
    required this.groupId,
  });
}

class Messages with ChangeNotifier {
  List<PrivateMessage> _privateMessage = [];
  List<GroupMessage> _groupMessage = [];
  List<PrivateMessage> get privateMessage {
    return [..._privateMessage];
  }

  addMessage(String message, String senderName, String sentBy, String groupId,
      String time, bool group, String? fileName) async {
    final url = G.HOST + "api/v1/sendMessage";
    await http.post(Uri.parse(url), body: {
      "senderPublicName": senderName,
      "message": message,
      "sentBy": sentBy,
      "groupId": groupId,
      "time": time,
      "group": "true",
      "fileName": fileName
    }).then((value) => _groupMessage.add(GroupMessage(
        fileName: fileName,
        senderPublicName: senderName,
        message: message,
        sentTime: DateTime.parse(time),
        sentFrom: sentBy,
        groupId: groupId)));

    notifyListeners();
  }

  fetchMessage() async {
    final url = G.HOST + "api/v1/message";
    final response = await http.get(Uri.parse(url));
    print(json.decode(response.body));
    log("Group message from api ${jsonDecode(response.body)}");
    // List<PrivateMessage> GroupMessages=PrivateMessage.fromMap(response.body) ;
    final List<GroupMessage> loadedData = [];
    for (var value in json.decode(response.body) as List) {
      loadedData.add(GroupMessage(
          fileName: value["fileName"],
          senderPublicName: value["senderPublicName"] ?? "",
          sentTime: DateTime.parse(value["time"]),
          groupId: value["groupId"],
          sentFrom: value["sentBy"],
          message: value["message"]));
    }
    _groupMessage = loadedData;
    notifyListeners();
  }
  // /v1/messageByGroup
  fetchMessageByGroup(String id) async {
    final url = G.HOST + "api/v1/messageByGroup";
    final response = await http.post(Uri.parse(url),body: {"id":id});
    print(json.decode(response.body));
    log("Group message from api ${jsonDecode(response.body)}");
    // List<PrivateMessage> GroupMessages=PrivateMessage.fromMap(response.body) ;
    final List<GroupMessage> loadedData = [];
    for (var value in json.decode(response.body) as List) {
      loadedData.add(GroupMessage(
          fileName: value["fileName"],
          senderPublicName: value["senderPublicName"] ?? "",
          sentTime: DateTime.parse(value["time"]),
          groupId: value["groupId"],
          sentFrom: value["sentBy"],
          message: value["message"]));
    }
    _groupMessage = loadedData;
    notifyListeners();
  }
  List<GroupMessage> get groupMessage {
    return [..._groupMessage];
  }
}
