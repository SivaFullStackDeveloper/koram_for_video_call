class DatingProfiles {
  List<Profiles>? profiles;

  DatingProfiles({this.profiles});

  DatingProfiles.fromJson(Map<String, dynamic> json) {
    if (json['profiles'] != null) {
      profiles = <Profiles>[];
      json['profiles'].forEach((v) {
        profiles!.add(new Profiles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.profiles != null) {
      data['profiles'] = this.profiles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Profiles {
  int? lat;
  int? lon;
  String? role;
  List<String>? friendList;
  List<String>? datingYourInterest;
  String? sId;
  String? phoneNumber;
  int? iV;
  String? alias;
  String? createdAt;
  String? dateofbirth;
  String? gender;
  String? name;
  String? noCodeNumber;
  String? privateProfilePicUrl;
  String? publicGender;
  String? publicProfilePicUrl;
  String? updatedAt;
  String? firebaseToken;
  String? datingPic1Url;
  String? datingPic2Url;
  String? datingDob;
  String? datingGender;
  String? datingHopingTofind;
  String? datingDrink;
  String? datingSmoke;
  String? datingHeight;
  String? datingEducation;
  String? datingRelegion;
  String? datingActive;

  Profiles(
      {this.lat,
        this.lon,
        this.role,
        this.friendList,
        this.datingYourInterest,
        this.sId,
        this.phoneNumber,
        this.iV,
        this.alias,
        this.createdAt,
        this.dateofbirth,
        this.gender,
        this.name,
        this.noCodeNumber,
        this.privateProfilePicUrl,
        this.publicGender,
        this.publicProfilePicUrl,
        this.updatedAt,
        this.firebaseToken,
        this.datingPic1Url,
        this.datingPic2Url,
        this.datingDob,
        this.datingGender,
        this.datingHopingTofind,
        this.datingDrink,
        this.datingSmoke,
        this.datingHeight,
        this.datingEducation,
        this.datingRelegion,
        this.datingActive});

  Profiles.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lon = json['lon'];
    role = json['role'];
    friendList = json['friend_list'].cast<String>();
    datingYourInterest = json['datingYourInterest'].cast<String>();
    sId = json['_id'];
    phoneNumber = json['phone_number'];
    alias = json['alias'];
    createdAt = json['createdAt'];
    dateofbirth = json['dateofbirth'];
    gender = json['gender'];
    name = json['name'];
    noCodeNumber = json['noCodeNumber'];
    privateProfilePicUrl = json['private_profile_pic_url'];
    publicGender = json['public_gender'];
    publicProfilePicUrl = json['public_profile_pic_url'];
    updatedAt = json['updatedAt'];
    firebaseToken = json['firebaseToken'];
    datingPic1Url = json['datingPic1Url'];
    datingPic2Url = json['datingPic2Url'];
    datingDob = json['datingDob'];
    datingGender = json['datingGender'];
    datingHopingTofind = json['datingHopingTofind'];
    datingDrink = json['datingDrink'];
    datingSmoke = json['datingSmoke'];
    datingHeight = json['datingHeight'];
    datingEducation = json['datingEducation'];
    datingRelegion = json['datingRelegion'];
    datingActive = json['datingActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    data['role'] = this.role;
    data['friend_list'] = this.friendList;
    data['datingYourInterest'] = this.datingYourInterest;
    data['_id'] = this.sId;
    data['phone_number'] = this.phoneNumber;
    data['alias'] = this.alias;
    data['createdAt'] = this.createdAt;
    data['dateofbirth'] = this.dateofbirth;
    data['gender'] = this.gender;
    data['name'] = this.name;
    data['noCodeNumber'] = this.noCodeNumber;
    data['private_profile_pic_url'] = this.privateProfilePicUrl;
    data['public_gender'] = this.publicGender;
    data['public_profile_pic_url'] = this.publicProfilePicUrl;
    data['updatedAt'] = this.updatedAt;
    data['firebaseToken'] = this.firebaseToken;
    data['datingPic1Url'] = this.datingPic1Url;
    data['datingPic2Url'] = this.datingPic2Url;
    data['datingDob'] = this.datingDob;
    data['datingGender'] = this.datingGender;
    data['datingHopingTofind'] = this.datingHopingTofind;
    data['datingDrink'] = this.datingDrink;
    data['datingSmoke'] = this.datingSmoke;
    data['datingHeight'] = this.datingHeight;
    data['datingEducation'] = this.datingEducation;
    data['datingRelegion'] = this.datingRelegion;
    data['datingActive'] = this.datingActive;
    return data;
  }
}

