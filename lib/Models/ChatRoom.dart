import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:koram_app/Helper/ChatSocketServices.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';

import 'NewUserModel.dart';

class ChatRoom {
  String? id;

  String? category;
  String? subCategory;
  String? superCategory;
  String? name;
  List<Tuple2<String, String>> subCategooryList = [];
  // List users;
  List<chatroomUsers>? users;
  List<UserDetail>? userDetails;
  String? image;

  ChatRoom(
      {this.id,
      this.category,
      this.subCategory,
      this.superCategory,
      this.users,
      this.name,
      this.userDetails,
      this.image});

  ChatRoom.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    if (json['users'] != null) {
      users = <chatroomUsers>[];
      json['users'].forEach((v) {
        users!.add(new chatroomUsers.fromJson(v));
      });
    }
    category = json['category'];
    subCategory = json['subCategory'];
    superCategory = json['superCategory'];
    name = json['name'];
    if (json['userDetails'] != null)
    { userDetails=[];
      json['userDetails'].forEach((v) {
        userDetails!.add(new UserDetail.fromJson(v));
      });
    }

  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    data['category'] = this.category;
    data['subCategory'] = this.subCategory;
    data['superCategory'] = this.superCategory;
    data['name'] = this.name;
    if (this.userDetails != null) {
      data["userDetails"]=this.userDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class chatroomUsers {
  String? sId;
  String? username;
  String? userphoneNumber;
  String? userUrl;

  chatroomUsers({this.sId, this.username, this.userphoneNumber, this.userUrl});

  chatroomUsers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    userphoneNumber = json['userphoneNumber'];
    userUrl = json["userUrl"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['userphoneNumber'] = this.userphoneNumber;
    data['userUrl'] = this.userUrl;
    return data;
  }
}

class ChatRoomsProvider with ChangeNotifier {
  List<ChatRoom> _chatrooms = [];
  List<ChatRoom> LocationRooms = [];
  List<ChatRoom> InterestRooms = [];
  List<ChatRoom> TrendingRooms = [];
  List<ChatRoom> FavouriteRooms = [];
  ChatRoom? SelectedRoom;
  bool isFromExplore=false;

  static bool isChangePage=false;

  updateChatroom(ChatRoom? c) {
    log("inside the update chat room  fucntion $SelectedRoom");
    SelectedRoom = c;
    notifyListeners();
  }
  ChangeHomePage()
  {
    log("seetiing bool of ischange $isChangePage");
    isChangePage=!isChangePage;
    notifyListeners();
  }

  fetchChatRoom() async {
    log("inside fetch chatroom");
    final url = G.HOST + "api/v1/chatrooms";
    final response = await http.get(Uri.parse(url));
    log("fetch chat room response " + jsonEncode(response.body));
    final List<ChatRoom> loadedData = [];

    for (var value in json.decode(response.body) as List) {
      loadedData.add(ChatRoom.fromJson(value));
    }
    _chatrooms = loadedData;
    for (ChatRoom c in _chatrooms) {

      switch (c.superCategory) {
        case "Location":
          {
            log("adding to the location ${c.name}");
            LocationRooms.add(c);

          }
          break;
        case "Favourite":
          {
            FavouriteRooms.add(c);
          }
          break;
        case "Interest":
        {
          InterestRooms.add(c);
        }
       break;
      }
    }
    log("loaded data  of chatrooms ${_chatrooms}");
    notifyListeners();
  }
  Future<ChatRoom?> fetchChatRoomById(String id)async
   {
     log("fetchhh room calleddd $id");
     final url = G.HOST + "api/v1/chatroomById";
     http.Response response = await http.post(Uri.parse(url),body: {"_id":id});
     log("fetch chat room by id response " + jsonEncode(response.body));
     if(response.statusCode==200)
     {
       return ChatRoom.fromJson(json.decode(response.body));
     }else
     {
       return null;
     }

   }
  addUsers(
      String name, String userNo, String userUrl, String id, bool isPop) async {
    log("add user called iispopopopoppop $isPop");
    final url = G.HOST + "api/v1/updateUser";
    print(userNo);
    http.Response response= await http.post(Uri.parse(url), body: {
      "_id": id,
      "username": name,
      "userphoneNumber": userNo,
      "userUrl": userUrl,
      "isPop": isPop.toString()
    });
    if(response.statusCode==200)
    {
      log("200 response on the add user is pop $isPop");
    }else
    {
      log("rseponse is not 200 ${response.body}");
    }
    fetchChatRoom();
    if (isPop){

      _chatrooms[_chatrooms.indexWhere((element) => element.id == id)]
          .users
          ?.removeWhere((element) => element.userphoneNumber == userNo);}
    else{


      _chatrooms[_chatrooms.indexWhere((element) => element.id == id)]
          .users
          ?.add(chatroomUsers(
              username: name,
              userphoneNumber: userNo,
              sId: "added from the function",
              userUrl: userUrl));}

    notifyListeners();
  }

  List<ChatRoom> get chatRooms {
    return [..._chatrooms];
  }
}
