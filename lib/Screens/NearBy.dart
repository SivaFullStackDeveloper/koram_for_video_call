import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Helper/color.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Models/Notification.dart' as N;
import 'package:koram_app/Screens/NotificationScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/LocationServices.dart';
import '../Widget/Badge.dart';
import '../Widget/BottomSheetContent.dart';
import 'NewProfileScreen.dart';

class NearByScreen extends StatefulWidget {
  const NearByScreen({Key? key}) : super(key: key);

  @override
  _NearByScreenState createState() => _NearByScreenState();
}

class _NearByScreenState extends State<NearByScreen> {
  bool switchValue = false;
  bool isLoading = false;
  List<String> genderList = [
    "Gender",
    "Male",
    "Female",
  ];
  var distance;
  var lat;
  File? profileImage;
  var lon;
  String genderValue = "Gender";
  String maxDistance = "5000";
  List<String> distanceList = [
    "Distance",
    "10 Km",
    "20 Km",
    "30 Km",
    "40 Km",
  ];
  List<UserDetail> nearByUsers = [];
  // double toRadians(double degree) {
  //   // cmath library in C++
  //   // defines the constant
  //   // M_PI as the value of
  //   // pi accurate to 1e-30
  //   double one_deg = (3.14) / 180;
  //   return (one_deg * degree);
  // }
  //
  // double calculateDistance(double lat1, double lat2, double lon1, double lon2) {
  //   // The math module contains a function
  //   // named toRadians which converts from
  //   // degrees to radians.
  //   lon1 = toRadians(lon1);
  //   lon2 = toRadians(lon2);
  //   lat1 = toRadians(lat1);
  //   lat2 = toRadians(lat2);
  //
  //   // Haversine formula
  //   double dlon = lon2 - lon1;
  //   double dlat = lat2 - lat1;
  //   double a =
  //       pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
  //
  //   double c = 2 * asin(sqrt(a));
  //
  //   // Radius of earth in kilometers. Use 3956
  //   // for miles
  //   double r = 6371;
  //
  //   // calculate the result
  //   return (c * r) * 0.621371;
  // }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  initState() {
    super.initState();
    dev.log("inside init of nearBY");
    Future.delayed(Duration(seconds: 0)).then((value) async {
      // users = Provider.of<Users>(context).user;
      // friendList = users
      //     .where((element1) => element1.phoneNumber == G.userId)
      //     .toList()[0]
      //     .friendList;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var isShowYourSelf = prefs.getBool("isShowYourself");
      if (isShowYourSelf == true && isShowYourSelf != null) {
        await onSwitchToggle();
      } else {
        dev.log("isnide shjow yourself not found or false ");
      }

      // profileImage=await G().getImageFile("private");
      var thisUser = G.loggedinUser;

      if (((thisUser.lat ?? 0) != 0) && ((thisUser.lon ?? 0) != 0)) {
        setState(() {
          lat = thisUser.lat;
          lon = thisUser.lon;
        });
      }
    });
  }

  // searchNearby(lat, lon, context)async {
  //   // friendList = users
  //   //     .where((element1) => element1.phoneNumber == G.userPhoneNumber)
  //   //     .toList()[0]
  //   //     .friendList;
  //   setState(() {
  //     isLoading=true;
  //
  //   });
  //
  //   List<UserDetail> NearbyUser=[];
  //   // List<UserDetail> usersss= await G().getAllUser();
  //   //             for(var k in usersss)
  //   //             {
  //   //               if(k.publicGender!.toLowerCase() == genderValue.toLowerCase() &&
  //   //                   k.phoneNumber != G.userPhoneNumber &&
  //   //                   calculateDistance(lat, double.parse(k.lat.toString()) ?? 0, lon, double.parse(k.lon.toString() )?? 0) <=
  //   //                       distance &&
  //   //                   !friendList.contains(k.phoneNumber))
  //   //               {
  //   //                 NearbyUser.add(k);
  //   //               }
  //   //             }
  //   // var u = usersss.where((element) {
  //   //   dev.log("elementss${element}");
  //   //   print(element.phoneNumber);
  //   //   print(element.lat);
  //   //   print(element.lon);
  //   //   print(calculateDistance(lat, element.lat ?? 0, lon, element.lon ?? 0));
  //   //   print(Geolocator.distanceBetween(
  //   //       lat, lon, element.lat ?? 0, element.lon ?? 0));
  //   //
  //   //   return element.publicGender!.toLowerCase() == genderValue.toLowerCase() &&
  //   //       element.phoneNumber != G.userPhoneNumber &&
  //   //       calculateDistance(lat, element.lat ?? 0, lon, element.lon ?? 0) <=
  //   //           distance &&
  //   //       !friendList.contains(element.phoneNumber);
  //   // }).toList();
  //   setState(() {
  //     usersList = NearbyUser;
  //     isLoading= false;
  //   });
  //   dev.log("Usersss List on search ${usersList}");
  // }
  onSwitchToggle() async {
    isLoading = true;
    setState(() {});
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Request user to enable location services
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        dev.log("from nearby location service in not enabled");
        switchValue = false;
      } else {
        switchValue = true;
        Position position = await LocationService().getCurrentLocation();
        lat = position.latitude;
        lon = position.longitude;
        nearByUsers = await G().getNearBy(
            position.latitude, position.longitude, maxDistance, genderValue);
        await Provider.of<UsersProviderClass>(context, listen: false)
            .addLocation(position.latitude, position.longitude);
        dev.log(
            "The location service is turned on. Nearby users found: ${nearByUsers.length}");
      }
    } else {
      switchValue = true;
      Position position = await LocationService().getCurrentLocation();
      lat = position.latitude;
      lon = position.longitude;
      nearByUsers = await G().getNearBy(
          position.latitude, position.longitude, maxDistance, genderValue);
      await Provider.of<UsersProviderClass>(context, listen: false)
          .addLocation(position.latitude, position.longitude);
      dev.log(
          "The location service is already on. Nearby users found: ${jsonEncode(nearByUsers)}");
    }
    isLoading = false;
    setState(() {});
  }

  List friendList = [];
  String distanceValue = "Distance";
  @override
  Widget build(BuildContext context) {
    List<N.Notification> notification =
        Provider.of<N.Notifications>(context).notification;
    UsersProviderClass UserClass =
        Provider.of<UsersProviderClass>(context, listen: true);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    // var us = Provider.of<Users>(context).user;
    // dev.log("userss list us ${us}");
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
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
        actions: [
          // GestureDetector(
          //     onTap: () async {
          //       SharedPreferences prefs =
          //           await SharedPreferences.getInstance();
          //       setState(() {
          //         prefs.setString("userId", "");
          //         prefs.setBool('logedIn', false);
          //         G.userId = "";
          //         G.logedIn = false;
          //       });
          //       Navigator.of(context)
          //           .push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
          //     },
          //     child: Container(
          //         // margin: EdgeInsets.all(8),
          //         height: 30,
          //         child: Text("logout"))),
          // Container(
          //   width: 25,
          //   height: 25,
          //   decoration: BoxDecoration(),
          //   child: SvgPicture.asset("assets/datingConfig.svg"),
          // ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => NotificationScreen()));
              // showModalBottomSheet(
              //     context: context,
              //     elevation: 3,
              //     isScrollControlled: true,
              //     builder: (ctx) => NotificationBottomSheet());
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
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => NewProfileScreen()));
              },
              child: Container(
                width: 41,
                child: UserClass.LoggedUser != null &&
                        UserClass.LoggedUser!.publicProfilePicUrl != null
                    ? CircleAvatar(
                        backgroundImage: AssetImage("assets/profile.png"),
                        foregroundImage: CachedNetworkImageProvider(
                            UserClass.LoggedUser!.publicProfilePicUrl!),
                        // onForegroundImageError: (){}AssetImage("assets/profile.png"),
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                      )
                    : CircleAvatar(
                        backgroundImage: AssetImage("assets/profile.png"),
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                      ),
              )),
          SizedBox(
            width: 19,
          ),
          // IconButton(
          //     onPressed: () {
          //       Navigator.of(context).push(MaterialPageRoute(
          //           builder: (ctx) => PrivarteProfileScreen()));
          //     },
          //     icon: Container(
          //         // margin: EdgeInsets.all(8),
          //         height: 30,
          //         child: Image.asset("assets/Mask Group 1.png"))),
        ],
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          Container(
            width: width,
            // height: 60,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(21, 38, 21, 16),
                  child: Container(
                    width: 348,
                    height: 53,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0xFFE6EAF7),
                          blurRadius: 15,
                          offset: Offset(0, 2),
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 0, 16),
                          child: Text(
                            'Show Yourself',
                            style: TextStyle(
                              color: Color(0xFF303030),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 12, 16),
                          child: Switch(
                              value: switchValue,
                              onChanged: (val) async {
                                setState(() {
                                  switchValue = val;
                                });
                                if (val) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool("isShowYourself", true);
                                  await onSwitchToggle();
                                } else {
                                  await Provider.of<UsersProviderClass>(context,
                                          listen: false)
                                      .addLocation(0, 0);
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool("isShowYourself", false);
                                  nearByUsers = [];
                                  setState(() {});
                                }
                              }),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(21, 16, 0, 22),
                  child: Row(
                    children: [
                      Container(
                        width: 110,
                        height: 30,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 6),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 0.50, color: Color(0xFFF2F2F2)),
                            borderRadius: BorderRadius.circular(63),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0xFFE6EAF7),
                              blurRadius: 5,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: DropdownButton(
                          underline: SizedBox(),
                          style: TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 12,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w500,
                          ),
                          isExpanded: true,
                          iconSize: 18,
                          autofocus: true,
                          items: genderList
                              .map((String item) => DropdownMenuItem<String>(
                                  // enabled: genderList[0] == item ? false : true,
                                  child: Text(item),
                                  value: item))
                              .toList(),
                          onChanged: (value) async {
                            print("previous ${this.genderValue}");
                            print("selected $value");
                            this.genderValue = value.toString();
                            await onSwitchToggle();
                          },
                          value: genderValue,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 110,
                        height: 30,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 6),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 0.50, color: Color(0xFFF2F2F2)),
                            borderRadius: BorderRadius.circular(63),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Color(0xFFE6EAF7),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: DropdownButton(
                          underline: SizedBox(),
                          style: TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 12,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w500,
                          ),
                          isExpanded: true,
                          iconSize: 18,
                          autofocus: true,
                          padding: EdgeInsets.all(0),
                          items: distanceList
                              .map((String item) => DropdownMenuItem<String>(
                                  // enabled: distanceList[0] == item ? false : true,
                                  child: Text(item),
                                  value: item))
                              .toList(),
                          onChanged: (value) async {
                            this.distanceValue = value.toString();
                            if (distanceValue != "Distance") {
                              maxDistance =
                                  (distanceList.indexOf(distanceValue) * 10000)
                                      .toString();
                            } else {
                              maxDistance = "5000";
                            }
                            await onSwitchToggle();
                          },
                          value: distanceValue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? Container(child: Center(child: CircularProgressIndicator()))
              : nearByUsers.isEmpty
                  ? Center(
                      child: Container(
                        child: Text("No users Found"),
                      ),
                    )
                  : Container(
                      height: height - 60,
                      child: ListView.builder(
                          itemCount: nearByUsers.length,
                          itemBuilder: (ctx, i) {
                            var dis;
                            if (lat != null) {
                              dis = (Geolocator.distanceBetween(
                                      lat,
                                      lon,
                                      nearByUsers[i].lat ?? 0,
                                      nearByUsers[i].lon ?? 0)) /
                                  1000;
                              dev.log(
                                  " the distance ${dis.toStringAsFixed(2)}");
                            } else {
                              dev.log("isndie the else when lat is empty ");
                              dis:
                              null;
                            }

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(G.HOST +
                                    "api/v1/images/" +
                                    nearByUsers[i].publicProfilePicUrl!),
                              ),
                              title: Text(nearByUsers[i].publicName ?? ""),
                              subtitle: dis != null
                                  ? Text("${dis.toStringAsFixed(2)} km")
                                  : SizedBox(),
                              trailing: Container(
                                width: 200,
                                child: nearByUsers[i] == G.userPhoneNumber
                                    ? Container()
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                              onPressed: () async {
                                                await Provider.of<
                                                            N.Notifications>(
                                                        context,
                                                        listen: false)
                                                    .addNotification(
                                                        "Hello",
                                                        nearByUsers[i]
                                                            .phoneNumber!,
                                                        G.userPhoneNumber);
                                                // SnackBar
                                              },
                                              child: Text(
                                                "Say Hello",
                                                style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline),
                                              )),
                                          GestureDetector(
                                            onTap: () {
                                              String txt = "";
                                              showDialog(
                                                  context: context,
                                                  builder: (ctx) => Dialog(
                                                        child: Container(
                                                          height: 200,
                                                          width: 100,
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                  "Send Message"),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey)),
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child:
                                                                    TextField(
                                                                  onChanged:
                                                                      (c) {
                                                                    txt = c;
                                                                  },
                                                                  maxLines: 6,
                                                                  decoration: InputDecoration
                                                                      .collapsed(
                                                                          hintText:
                                                                              "Write here"),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  await Provider.of<
                                                                              N
                                                                              .Notifications>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .addNotification(
                                                                          txt,
                                                                          nearByUsers[i]
                                                                              .phoneNumber!,
                                                                          G.userPhoneNumber);
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                  // SnackBar
                                                                },
                                                                child: Container(
                                                                    width: 70,
                                                                    height: 30,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(20),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                              color: Colors.grey.shade200,
                                                                              spreadRadius: 4,
                                                                              offset: Offset(2, 3),
                                                                              blurRadius: 2)
                                                                        ],
                                                                        color: Colors.orange),
                                                                    child: Center(
                                                                        child: Text(
                                                                      "Send",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              10),
                                                                    ))),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ));
                                            },
                                            child: Container(
                                                width: 100,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                        color: backendColor),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors
                                                              .grey.shade200,
                                                          spreadRadius: 4,
                                                          offset: Offset(2, 3),
                                                          blurRadius: 2)
                                                    ],
                                                    color: Colors.white),
                                                child: Center(
                                                    child: Text(
                                                  "Custom Message",
                                                  style: TextStyle(
                                                      color: backendColor,
                                                      fontSize: 10),
                                                ))),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          }),
                    )
        ],
      ),
    );
  }
}
