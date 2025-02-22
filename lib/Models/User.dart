import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Models/Message.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/DBHelper.dart';
import 'NewUserModel.dart';

// User userFromJson(String str) => User.fromJson(json.decode(str));
//
// String userToJson(User data) => json.encode(data.toJson());

class SeenBy {
  String? sId;
  String? user;
  String? seenTime;

  SeenBy({this.sId, this.user, this.seenTime});

  SeenBy.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    seenTime = json['seenTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['seenTime'] = this.seenTime;
    return data;
  }
}

// class User {
//   var lat;
//   var lon;
//   String gender;
//   String publicGender;
//   String public_profile_pic_url;
//   String private_profile_pic_url;
//   String alias;
//   String id;
//   List friendList;
//   List<Story> story;
//   String name;
//   String phoneNumber;
//   String noCodeNumber;
//   String role;
//   DateTime? recieveTime;
//   String? latestMessage = "";
//   String dateofbirth;
//   bool? seenStory = false;
//   int newMessage = 0;
//
//   ///dating values
//   // List<String>? datingYourInterest;
//   // String? firebaseToken;
//   // String? datingPic1Url;
//   // String? datingPic2Url;
//   // String? datingDob;
//   // String? datingGender;
//   // String? datingHopingTofind;
//   // String? datingDrink;
//   // String? datingSmoke;
//   // int? datingHeight;
//   // String? datingEducation;
//   // String? datingActive;
//   // String? datingRelegion;
//   // List<DatingMatches>? datingMatches;
//   // List groups = [];
//
//   User({
//     required this.gender,
//     required this.publicGender,
//     required this.private_profile_pic_url,
//     required this.public_profile_pic_url,
//     required this.alias,
//     required this.id,
//     required this.name,
//     required this.lat,
//     required this.lon,
//     required this.phoneNumber,
//     required this.friendList,
//     required this.story,
//     required this.role,
//     required this.dateofbirth,
//     required this.noCodeNumber,
//     seenStory,
//     recieveTime,
//     latestMessage,
//     firebaseToken,
//     newMessage,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     var storyvalue;
//     if (json['story'] != null) {
//       storyvalue = <Story>[];
//       json['story'].forEach((v) {
//         storyvalue.add(new Story.fromJson(v));
//       });
//     }
//
//     return User(
//       gender: json["gender"],
//       publicGender: json["public_gender"],
//       alias: json["alias"],
//       name: json["name"],
//       id: json["id"] ?? "",
//       private_profile_pic_url: json["private_profile_pic_url"] ?? "",
//       public_profile_pic_url: json["public_profile_pic_url"] ?? "",
//       noCodeNumber: json["noCodeNumber"],
//       friendList: json["friend_list"] ?? [],
//       phoneNumber: json["phone_number"],
//       role: json["role"],
//       dateofbirth: json["dateofbirth"],
//       lat: json["lat"] ?? "",
//       lon: json["lon"] ?? "",
//       story: storyvalue,
//       firebaseToken: json["firebaseToken"] ?? "",
//       recieveTime: json['recieveTime'] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         "gender": gender,
//         "public_gender": publicGender,
//         "public_profile_pic_url": public_profile_pic_url,
//         "private_profile_pic_url": private_profile_pic_url,
//         "firebaseToken": G.fireBaseToken,
//         "alias": alias,
//         "id": id,
//         "name": name,
//         "phone_number": phoneNumber,
//         "noCodeNumber": noCodeNumber,
//         "role": role,
//         "dateofbirth": dateofbirth,
//         "recieveTime": recieveTime,
//         "story": story,
//       };
//
//   @override
//   String toString() {
//     return '{'
//         'lat: $lat, '
//         'lon: $lon, '
//         'gender: $gender, '
//         'publicGender: $publicGender, '
//         'public_profile_pic_url: $public_profile_pic_url, '
//         'private_profile_pic_url: $private_profile_pic_url, '
//         'alias: $alias, '
//         'id: $id, '
//         'friendList: $friendList, '
//         'story: $story, '
//         'name: $name, '
//         'phoneNumber: $phoneNumber, '
//         'noCodeNumber: $noCodeNumber, '
//         'role: $role, '
//         'recieveTime: $recieveTime, '
//         'latestMessage: $latestMessage, '
//         'dateofbirth: $dateofbirth, '
//         'seenStory: $seenStory, '
//         'newMessage: $newMessage '
//         '}';
//   }
//
//   String toJsonString() {
//     return '{'
//         '"lat": "$lat", '
//         '"lon": "$lon", '
//         '"gender": "$gender", '
//         '"publicGender": "$publicGender", '
//         '"public_profile_pic_url": "$public_profile_pic_url", '
//         '"private_profile_pic_url": "$private_profile_pic_url", '
//         '"alias": "$alias", '
//         '"id": "$id", '
//         '"friendList": $friendList, '
//         '"story": "$story", '
//         '"name": "$name", '
//         '"phoneNumber": "$phoneNumber", '
//         '"noCodeNumber": $noCodeNumber, '
//         '"role": "$role", '
//         '"recieveTime": $recieveTime, '
//         '"latestMessage": "$latestMessage", '
//         '"dateofbirth": "$dateofbirth", '
//         '"seenStory": $seenStory, '
//         '"newMessage": $newMessage '
//         '}';
//   }
// }

class UsersProviderClass with ChangeNotifier {
  // List<UserDetail> _user = [];
  List<UserDetail> finalFriendsList = [];
  List<UserDetail> seenStories = [];
  List<UserDetail> unseenStories = [];
  List<Story>? UserStory;
  ContactResponse? contactFriends;
  UserDetail? LoggedUser;
  List<PrivateMessage>? SavedMessages;
  List<UserDetail> matchedUsers = [];
  List<String> unmatchedPhoneNumbers = [];

  saveValueFromDb() async {
    finalFriendsList = await DBProvider.db.getAllUserDetails();
    SavedMessages = await DBProvider.db.getAllPrivateMessages();

    log("saved messages ${SavedMessages}");
    List<UserDetail> copyOfFriendsList = finalFriendsList;
    for (var friend in finalFriendsList) {
      var relevantMessages = SavedMessages!
          .where((msg) =>
              msg.sentTo == friend.phoneNumber ||
              msg.sentBy == friend.phoneNumber)
          .toList();

      relevantMessages.sort((a, b) => b.time.compareTo(a.time));

      if (relevantMessages.isNotEmpty) {
        friend.latestMessage = relevantMessages.first.message;
        friend.recieveTime = DateTime.parse(relevantMessages.first.time);
      }
      int index = copyOfFriendsList
          .indexWhere((f) => f.phoneNumber == friend.phoneNumber);
      if (index != -1) {
        // Replace the old value with the new one
        copyOfFriendsList[index] = friend;
      }
    }

    finalFriendsList = copyOfFriendsList;

    G.FriendsList = finalFriendsList;
    log("final friends list after addign data from datbase ${jsonEncode(finalFriendsList)}");
    notifyListeners();
  }
  //   {
  //     final url = G.HOST + "api/v1/users";
  //     http.Response response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final List<dynamic> jsonList = json.decode(response.body);
  //       final List<UserDetail> userList =
  //           jsonList.map((json) => UserDetail.fromJson(json)).toList();
  //
  //       _user = userList;
  //       notifyListeners();
  //       log("USErDATA SAVED from provider $userList");
  //     } else {
  //
  //     }
  //   }
  // }

  Future<ContactResponse> getContactUsers(List<String> phoneNumbers) async {
    final url = G.HOST + "api/v1/geContactUsers";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({"phoneNumbers": phoneNumbers}),
    );

    if (response.statusCode == 200) {
      contactFriends = ContactResponse.fromJson(json.decode(response.body));

      return ContactResponse.fromJson(json.decode(response.body));
    } else {
      log("insde else ${response.body}");
      throw Exception('Failed to load contact users');
    }
  }

  // getUserWithPhoneNumber(String phoneNumber) {
  //   return LoggedUser
  //       .where((element) => element.phoneNumber == phoneNumber)
  //       .toList()[0];
  // }

  addFriend(String friend, String id) async {
    final url = G.HOST + "api/v1/addFriend";
    print(id + friend);
    var res =
        await http.post(Uri.parse(url), body: {"id": id, "friend": friend});
    LoggedUser?.friendList!.add(friend);
    notifyListeners();
  }

  Future<int> addFriendByPhoneNumber(String friend) async {
    // try{
    log("friends number ${G.loggedinUser.phoneNumber}");
    final url = G.HOST + "api/v1/addFriendByPhoneNumber";
    http.Response res = await http.post(Uri.parse(url), body: {
      "userNumber": G.loggedinUser.phoneNumber,
      "friendNumber": friend
    });
    LoggedUser?.friendList!.add(friend);
    notifyListeners();
    return res.statusCode;
    // }
  }

  addStory(String image, String id) async {
    final url = G.HOST + "api/v1/addStory";
    var res = await http
        .post(Uri.parse(url), body: {"phone_number": id, "image": image});
    log("addstory response ${res.body}");

    UserDetail rec = UserDetail.fromJson(json.decode(res.body)["UserData"]);
    log("rex ${rec.privateName}");
    LoggedUser = rec;
    UserStory = rec.story;
    // LoggedUser?.story!.add(Story(
    //     seenBy: [], postedTime: DateTime.now().toString(), storyUrl: image));
    notifyListeners();
  }

  addLocation(double lat, double lon) async {
    final url = G.HOST + "api/v1/addLocation";
    try {
      http.Response res = await http.post(Uri.parse(url), body: {
        "phoneNumber": G.userPhoneNumber,
        "lat": lat.toString(),
        "lon": lon.toString()
      });
      if (res.statusCode == 200) {
        log("location added successfully ");
      } else {
        log("location was not added${res.statusCode} ");
      }
      LoggedUser?.lat = lat;
      LoggedUser?.lon = lon;
      notifyListeners();
    } catch (e) {
      log("error while adding location ${e}");
    }
  }

  Future<int> addUser(UserDetail user, bool isPrivate) async {
    log("inside add user " + user.toJson().toString());
    final url = G.HOST + "api/v1/profile/create";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // var res = await http.post(Uri.parse(url), body: user.toJson());
    // _user.add(UserDetail.fromJson(json.decode(res.body)));
    if (!isPrivate) {
      G.logedIn = true;
      await prefs.setBool('logedIn', true);
    }
    http.Response res = await http.post(Uri.parse(url), body: {
      "gender": user.gender ?? "",
      "public_gender": user.publicGender ?? "",
      "public_profile_pic_url": user.publicProfilePicUrl ?? "",
      "private_profile_pic_url": user.privateProfilePicUrl ?? "",
      "privateName": user.privateName ?? "",
      "phone_number": user.phoneNumber ?? "",
      "role": user.role ?? "",
      "publicName": user.publicName ?? "",
      "dateofbirth": user.dateofbirth ?? "",
      "noCodeNumber": user.noCodeNumber ?? "",
      "firebaseToken": prefs.getString("FirebaseToken"),
      "isPrivate": isPrivate.toString(),
      "lat": user.lat.toString(),
      "lon": user.lon.toString()
      // "_id": user.id,
    });
    log("tjhe add user resopnse ${res}");
    if (res.statusCode == 200) {
      log("isnide the status code 200");
      // print("jsooon" + jsonDecode(value.body));
      user = UserDetail(
          story: user.story,
          gender: user.gender,
          noCodeNumber: user.noCodeNumber,
          publicGender: user.publicGender,
          privateProfilePicUrl: user.privateProfilePicUrl,
          publicProfilePicUrl: user.publicProfilePicUrl,
          publicName: user.publicName,
          friendList: user.friendList,
          privateName: user.privateName,
          lat: 0,
          lon: 0,
          phoneNumber: user.phoneNumber,
          role: user.role,
          firebaseToken: prefs.getString("FirebaseToken"),
          dateofbirth: user.dateofbirth);
      // G.userrr = user;
    } else {
      log("the respones of ${res.statusCode}");
    }

    UserDetail updatedUser = UserDetail.fromJson(json.decode(res.body));
    log("the updated user respoonse after mapping ${jsonEncode(updatedUser)}");
    log("saving data of user  ${user.toJson()}");
    await prefs.setString("LoggedInUserData", jsonEncode(user));
    var userData =
        UserDetail.fromJson(jsonDecode(prefs.getString("LoggedInUserData")!));
    log("USERSSS $userData");
    LoggedUser = user;

    notifyListeners();
    return res.statusCode;
  }

  getFriends() async {
    try {
      List<UserDetail> tempList = [];
      await returnLoggedUser();

      log("after the return logged user block ");
      var friendlistResponse = await http.post(
        Uri.parse(G.HOST + "api/v1/userBynumber"),
        body: jsonEncode({
          "listofPhonenumber": LoggedUser!.friendList,
          "requesterPhoneNumber": LoggedUser?.phoneNumber
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      SavedMessages = await DBProvider.db.getAllPrivateMessages();

      log("response of req ${friendlistResponse.body}");
      if (friendlistResponse.statusCode == 200) {
        log("inside success of friendlist request ");
        log("YOLO oooooo" + jsonEncode(friendlistResponse.body));
        var Listoffriends = jsonDecode(friendlistResponse.body)["users"];
        final parsed = jsonDecode(friendlistResponse.body);

        seenStories = (parsed['seenUsers'] as List)
            .map((data) => UserDetail.fromJson(data))
            .toList();

        unseenStories = (parsed['unseenUsers'] as List)
            .map((data) => UserDetail.fromJson(data))
            .toList();

        if (Listoffriends.isNotEmpty) {
          Listoffriends.forEach((friendData) async {
            log("adding friend ${Listoffriends.indexOf(friendData)}");
            var friend = UserDetail.fromJson(friendData);
            var relevantMessages = SavedMessages!
                .where((msg) =>
                    msg.sentTo == friend.phoneNumber ||
                    msg.sentBy == friend.phoneNumber)
                .toList();

            relevantMessages.sort((a, b) => b.time.compareTo(a.time));

            if (relevantMessages.isNotEmpty) {
              friend.latestMessage = relevantMessages.first.message;
              friend.recieveTime = DateTime.parse(relevantMessages.first.time);
            }
            ;
            tempList.add(friend);
          });
          DBProvider.db.insertUserDetailList(tempList);
          finalFriendsList = tempList;

          log("seen story length ${seenStories.length}");
          log("unseen story length ${unseenStories.length}");

          G.FriendsList = finalFriendsList;
        }
      } else {
        log("inside else  of get froeinds  api call  ${friendlistResponse.body}");
      }
      notifyListeners();
    } catch (e) {
      log("error on get user $e");
      saveValueFromDb();
    }
  }

  Future<UserDetail?> getUserByNumber(List<String> requestNumberList) async {
    try {
      var friendlistResponse = await http.post(
        Uri.parse(G.HOST + "api/v1/userBynumber"),
        body: jsonEncode({
          "listofPhonenumber": requestNumberList,
          "requesterPhoneNumber": LoggedUser?.phoneNumber
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      log("response of req ${friendlistResponse.body}");
      if (friendlistResponse.statusCode == 200) {
        log("inside success of number  request ");
        log("the response " + jsonEncode(friendlistResponse.body));
        var Listoffriends = jsonDecode(friendlistResponse.body)["users"];
        UserDetail u = UserDetail.fromJson(Listoffriends.first);
        return u;
      } else {
        log("inside else  of get froeinds  api call  ${friendlistResponse.body}");
        return null;
      }
    } catch (e) {
      log("error on get user $e");
    }
    return null;
  }

  triggerUserNotifier() {
    log("trigger called ");
    notifyListeners();
  }

  returnLoggedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      log("return logged user called ");

      String? PhoneNumber = prefs.getString("userId");

      http.Response response = await http.post(
          Uri.parse(G.HOST + "api/v1/returnUser"),
          body: {"phoneNumber": PhoneNumber}).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        var data = json.decode(response.body)["userDetail"];
        prefs.setString("LoggedInUserData", json.encode(data));

        LoggedUser =
            UserDetail.fromJson(json.decode(response.body)["userDetail"]);
        UserStory = LoggedUser!.story ?? [];
        log("logged user story length ${LoggedUser!.story!.length}");
        G.loggedinUser = LoggedUser!;
      } else {
        log("inside else ");
        LoggedUser = UserDetail.fromJson(
            json.decode(prefs.getString("LoggedInUserData") ?? ""));
        G.loggedinUser = LoggedUser!;
      }
    } catch (e) {
      log("ERRROR in Return logged user $e");
      LoggedUser = UserDetail.fromJson(
          json.decode(prefs.getString("LoggedInUserData") ?? ""));
      G.loggedinUser = LoggedUser!;
    }
  }

  Future<int> deleteStory(String PhoneNumber, String storyId) async {
    http.Response response = await http.post(
        Uri.parse(G.HOST + "api/v1/deleteUserStory"),
        body: {"phoneNumber": PhoneNumber, "storyId": storyId});
    log("resopnse of delete ${response.body}");
    if (response.statusCode == 200) {
      LoggedUser =
          UserDetail.fromJson(json.decode(response.body)["updatedUser"]);
      UserStory = LoggedUser?.story;

      G.loggedinUser = LoggedUser!;
      notifyListeners();

      log("logged user story length ${LoggedUser!.story!.length}");
      return 200;
    } else {
      log("inside else ");
      return 400;
    }
    // } catch (e) {
    //   log("error at delte story");
    //   return 500;
    //
    // }
  }
}

class DatingMatches {
  String? status;
  bool? isMatched;
  String? sId;
  String? phoneNumber;

  DatingMatches({this.status, this.isMatched, this.sId, this.phoneNumber});

  DatingMatches.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    isMatched = json['isMatched'];
    sId = json['_id'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['isMatched'] = this.isMatched;
    data['_id'] = this.sId;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}

class ContactResponse {
  List<UserDetail> matchedUsers = [];
  List<String> unmatchedPhoneNumbers = [];
  ContactResponse(
      {required this.matchedUsers, required this.unmatchedPhoneNumbers});

  factory ContactResponse.fromJson(Map<String, dynamic> json) {
    List<UserDetail> matchedUsers = [];
    if (json['matchedUsers'] != null) {
      matchedUsers = json['matchedUsers']
          .map<UserDetail>((userJson) => UserDetail.fromJson(userJson))
          .toList();
    }
    List<String> unmatchedPhoneNumbers = [];
    if (json['unmatchedPhoneNumbers'] != null) {
      unmatchedPhoneNumbers = List<String>.from(json['unmatchedPhoneNumbers']);
    }
    return ContactResponse(
      matchedUsers: matchedUsers,
      unmatchedPhoneNumbers: unmatchedPhoneNumbers,
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['matchedUsers'] = matchedUsers.map((user) => user.toJson()).toList();
    data['unmatchedPhoneNumbers'] = unmatchedPhoneNumbers;
    return data;
  }
}
