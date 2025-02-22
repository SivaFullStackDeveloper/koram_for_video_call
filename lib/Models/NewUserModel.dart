import 'dart:convert';

import 'package:koram_app/Helper/Helper.dart';

class UserModel {
  String? status;
  String? message;
  String? token;
  String? id;
  UserDetail? userDetail;

  UserModel({this.status, this.message, this.token, this.id, this.userDetail});

  UserModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    token = json['token'];
    id = json['id'];
    userDetail = json['userDetail'] != null
        ? new UserDetail.fromJson(json['userDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['token'] = this.token;
    data['id'] = this.id;
    if (this.userDetail != null) {
      data['userDetail'] = this.userDetail!.toJson();
    }
    return data;
  }
}

class UserDetail {
  var lat;
  var lon;
  String? role;
  List<String>? friendList=[];
  String? sId;
  String? phoneNumber;
  int? iV;
  String? publicName;
  String? createdAt;
  String? dateofbirth;
  String? gender;
  String? privateName;
  var noCodeNumber;
  String? privateProfilePicUrl;
  String? publicGender;
  String? publicProfilePicUrl;
  String? updatedAt;
  List<Story>? story=[];
  String? firebaseToken;
  DateTime? recieveTime;
  String? localImage;
  String? latestMessage = "";
  bool? seenStory = false;
  int newMessage = 0;

  UserDetail(
      {this.lat,
        this.lon,
        this.role,
        this.friendList,
        this.sId,
        this.phoneNumber,
        this.iV,
        this.publicName,
        this.createdAt,
        this.dateofbirth,
        this.gender,
        this.privateName,
        this.noCodeNumber,
        this.privateProfilePicUrl,
        this.publicGender,
        this.publicProfilePicUrl,
        this.updatedAt,
        this.story,
        this.firebaseToken,
         this.localImage,
        seenStory,
        recieveTime,
        latestMessage,
        newMessage,
      });



  UserDetail.fromJson(Map<String, dynamic> json) {
    lat = json['lat']??"";
    lon = json['lon']??"";
    if(json['friend_list']!=null)
    {
      friendList = json['friend_list'].cast<String>();

    }else
    {
      friendList=[];
    }
    phoneNumber = json['phone_number'];
    publicName = json['publicName'];
    dateofbirth = json['dateofbirth'];
    gender = json['gender'];
   noCodeNumber=json["noCodeNumber"];
    privateName = json['privateName'];
    noCodeNumber = json['noCodeNumber'];
    privateProfilePicUrl = json['private_profile_pic_url'];
    publicGender = json['public_gender'];
    publicProfilePicUrl = json['public_profile_pic_url'];
    if (json['story'] != null) {
      story = <Story>[];
      json['story'].forEach((v) {
        story!.add(new Story.fromJson(v));
      });
    }
    firebaseToken = json['firebaseToken'];

  }
  Map<String, dynamic> toDbMap() {

    return {
      'lat': lat,
      'lon': lon,
      'role': role,
      'friendList': jsonEncode(friendList),
      'sId': sId,
      'phoneNumber': phoneNumber,
      'iV': iV,
      'publicName': publicName,
      'createdAt': createdAt,
      'dateofbirth': dateofbirth,
      'gender': gender,
      'privateName': privateName,
      'noCodeNumber': noCodeNumber,
      'privateProfilePicUrl': privateProfilePicUrl,
      'publicGender': publicGender,
      'publicProfilePicUrl': publicProfilePicUrl,
      'updatedAt': updatedAt,
      'story': jsonEncode(story),
      'firebaseToken': firebaseToken,
      'recieveTime': recieveTime?.toIso8601String(),
      'latestMessage': latestMessage,
      'seenStory': seenStory,
      'newMessage': newMessage,
    };
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['role'] = this.role;
    data['friend_list'] = this.friendList;
    data['phone_number'] = this.phoneNumber;
    data['publicName'] = this.publicName;
    data['dateofbirth'] = this.dateofbirth;
    data['gender'] = this.gender;
    data['public_gender']=this.publicGender;
    data['privateName'] = this.privateName;
    data['noCodeNumber'] = this.noCodeNumber;
    data['private_profile_pic_url'] = this.privateProfilePicUrl;
    data['public_gender'] = this.publicGender;
    data['public_profile_pic_url'] = this.publicProfilePicUrl;
    if (this.story != null) {
      data['story'] = this.story!.map((v) => v.toJson()).toList();
    }
    data['firebaseToken'] = this.firebaseToken;

    return data;
  }
  factory UserDetail.fromDbMap(Map<String, dynamic> map) {
    List<Story>storyList=[];
    if (map['story'] != null) {
      jsonDecode( map['story']).forEach((v) {
        storyList.add(new Story.fromJson(v));
      });
    }

    return UserDetail(
      lat: map['lat'],
      lon: map['lon'],
      role: map['role'],
      friendList: List<String>.from(jsonDecode(map['friendList'])),
      sId: map['sId'],
      phoneNumber: map['phoneNumber'],
      iV: map['iV'],
      publicName: map['publicName'],
      createdAt: map['createdAt'],
      dateofbirth: map['dateofbirth'],
      gender: map['gender'],
      privateName: map['privateName'],
      noCodeNumber: map['noCodeNumber'],
      privateProfilePicUrl: map['privateProfilePicUrl'],
      publicGender: map['publicGender'],
      publicProfilePicUrl: map['publicProfilePicUrl'],
      updatedAt: map['updatedAt'],
      story: storyList,

      firebaseToken: map['firebaseToken'],

      recieveTime: map['recieveTime']!=null?DateTime.parse(map['recieveTime']??""):"",
      latestMessage: map['latestMessage'],
      seenStory: map['seenStory'] ,
      newMessage: map['newMessage'],
    );
  }

}

class Story {
  String? sId;
  String? storyUrl;
  String? postedTime;
  List<SeenBy>? seenBy;

  Story({this.sId, this.storyUrl, this.postedTime, this.seenBy});

  Story.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    storyUrl = json['storyUrl'];
    postedTime = json['postedTime'];
    if (json['seenBy'] != null) {
      seenBy = <SeenBy>[];
      json['seenBy'].forEach((v) {
        seenBy!.add(new SeenBy.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['storyUrl'] = this.storyUrl;
    data['postedTime'] = this.postedTime;
    if (this.seenBy != null) {
      data['seenBy'] = this.seenBy!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

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
