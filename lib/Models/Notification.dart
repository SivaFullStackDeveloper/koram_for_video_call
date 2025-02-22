// To parse this JSON data, do
//
//     final notification = notificationFromJson(jsonString);

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:koram_app/Helper/Helper.dart';

Notification notificationFromJson(String str) =>
    Notification.fromJson(json.decode(str));

String notificationToJson(Notification data) => json.encode(data.toJson());

class Notification {
  Notification({
    required this.id,
    required this.message,
    required this.sentBy,
    required this.sentTo,
    required this.sentTime

  });

  String id;
  String message;
  String sentBy;
  String sentTo;
  String sentTime;
  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        message: json["message"],
        sentBy: json["sentBy"],
        sentTo: json["sentTo"],
    sentTime: json["sentTime"]??"3m ago"
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "sentBy": sentBy,
        "sentTo": sentTo,
    "sentTime":sentTime
      };
}

class Notifications with ChangeNotifier {
  List<Notification> _notification = [];
  List<Notification> get notification {
    return [..._notification];
  }

  fetchNotification() async {

    final url = G.HOST + "api/v1/notifications";
    var response = await http.get(Uri.parse(url));
    log(response.body);
    List<Notification> loadedData = [];
    for (var value in json.decode(response.body)) {
      if (value["sentTo"] == G.userPhoneNumber) {
        loadedData.add(Notification(
            id: value["_id"],
            message: value["message"],
            sentBy: value["sentBy"],
            sentTo: value["sentTo"], sentTime: value["sentTime"]??"3m ago"));
      }
    }
    _notification = loadedData;

    print(_notification);
    notifyListeners();
  }

  addNotification(String message, String sentTo, String sentBy) async {
    final url = G.HOST + "api/v1/notification";
    await http.post(Uri.parse(url),
        body: {"message": message, "sentBy": sentBy, "sentTo": sentTo,});
  }

  deleteNotification(String id) async {
    final url = G.HOST + "api/v1/notifications/$id";
   await http.delete(Uri.parse(url));
    _notification.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
