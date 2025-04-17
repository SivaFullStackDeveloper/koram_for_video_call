import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Screens/AddContactScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:koram_app/Models/Notification.dart' as N;

import '../Widget/Badge.dart';
import '../Widget/BottomSheetContent.dart';
import 'NewProfileScreen.dart';
import 'NotificationScreen.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({Key? key}) : super(key: key);

  @override
  _CallHistoryScreenState createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  List<String> callHistory = [];
  int setStateCount = 0;
  File? profileImage;
  UserDetail? loggedUserData;
  List<String> PhoneNumbers = [];
  List<UserDetail> allUser = [];
  bool isLoading = true;
  List<bool> isSelected = [];
  var prefs;
  bool isSearchClicked = false;
  TextEditingController searchValue = TextEditingController();
  @override
  void initState() {
    isLoading = true;
    // TODO: implement initState
    Future.delayed(Duration.zero).then((value) async {
      // profileImage = await G().getImageFile("private");

      init();
    });
    super.initState();
  }

  init() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      callHistory = prefs.getStringList("call_history") ;
      callHistory = callHistory.reversed.toList();
      log("CALL HIstory ${callHistory}");
    });
    isSelected = callHistory.map((e) => false).toList();
    log("isselected length ${isSelected.length}");
    log("the length of call hitory ${callHistory.length}");
    Set<String> phoneNumbersSet = {};
    if (callHistory.isEmpty) {
      log("returnning as callhistory is empty");
      loggedUserData =
          UserDetail.fromJson(jsonDecode(prefs.getString("LoggedInUserData")!));
      isLoading = false;
      setState(() {});

      return;
    }
    for (var call in callHistory) {
      // Parse the JSON string into a map
      Map<String, dynamic> callMap = jsonDecode(call);
      // Add the phone numbers to the set
      phoneNumbersSet.add(callMap['caller']);
      phoneNumbersSet.add(callMap['callTo']);
    }

    // Convert the set back to a list
    List<String> phoneNumbersList = phoneNumbersSet.toList();

    allUser = await G().getUserByPhonenumber(phoneNumbersList);
    if (allUser.isNotEmpty) {
      List<String> modifiedCallHistory = [];
      callHistory.forEach((e) {
        var decoded = json.decode(e);
        List<UserDetail> theUSer =
            allUser.where((e) => e.phoneNumber == decoded["caller"]).toList();
        log("the user ${theUSer}");
        if (theUSer.isNotEmpty) {
          decoded["callerName"] = theUSer[0].publicName;
          decoded["profilePic"] = theUSer[0].publicProfilePicUrl;
          modifiedCallHistory.add(json.encode(decoded));
        } else {
          modifiedCallHistory.add(e);
        }
      });
      callHistory = modifiedCallHistory;
      prefs.setStringList("call_history", callHistory);
      log("the modiffied list ${modifiedCallHistory}");
      log("response of get in call history ${allUser.length}");
    } else {
      log("all users were empty");
    }

    loggedUserData =
        UserDetail.fromJson(jsonDecode(prefs.getString("LoggedInUserData")!));
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    UsersProviderClass UserClass =
        Provider.of<UsersProviderClass>(context, listen: true);
    log("is selected has true ${isSelected.contains(true)}");
    if (!isSearchClicked) {
      if (prefs != null) {
        callHistory = prefs.getStringList("call_history") ?? [];
      }
    }

    String formatDateTimeString(String dateTimeString) {
      // Parse the datetime string
      DateTime dateTime = DateTime.parse(dateTimeString);

      // Get the current date
      DateTime currentDate = DateTime.now();

      // Check if the date is today
      bool isToday = dateTime.year == currentDate.year &&
          dateTime.month == currentDate.month &&
          dateTime.day == currentDate.day;

      // Format the datetime
      String formattedTime = DateFormat.jm().format(dateTime); // 12:30 PM

      // Format the date if it's today, otherwise, show the full date
      String formattedDate =
          isToday ? "Today" : DateFormat.yMd().format(dateTime);

      // Combine the formatted date and time
      String finalFormattedString = '$formattedDate, $formattedTime';

      return finalFormattedString;
    }

    List<N.Notification> notification =
        Provider.of<N.Notifications>(context).notification;
    List<UserDetail> user = allUser;
    for (var i = 0; i < user.length / 2; i++) {
      var temp = user[i];
      user[i] = user[user.length - 1 - i];
      user[user.length - 1 - i] = temp;
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isSelected.contains(true)
          ? AppBar(
              elevation: 0.5,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              title: Text(
                "Selected ${isSelected.where((e) => e == true).length}",
                style: TextStyle(color: RuntimeStorage().PrimaryOrange),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      if (isSelected.contains(false)) {
                        isSelected = isSelected.map((e) => true).toList();

                        setState(() {});
                      } else {
                        isSelected = isSelected.map((e) => false).toList();
                        setState(() {});
                      }
                    },
                    icon: Icon(
                      Icons.select_all_sharp,
                      color: isSelected.contains(false)
                          ? Colors.grey
                          : RuntimeStorage().PrimaryOrange,
                    )),
                IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Are you sure?"),
                            content:
                                Text("Do you really want to delete this log?"),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  log("yes"); // Log or perform delete operation here
                                  try {
                                    log("is selected length +${isSelected.length}");
                                    log("callhistory length ${callHistory.length}");
                                    for (var i = 0;
                                        i <= isSelected.length - 1;
                                        i++) {
                                      if (isSelected[i]) {
                                        log("removed at $i");
                                        callHistory.removeAt(i);
                                      }
                                    }
                                    isSelected =
                                        callHistory.map((e) => false).toList();
                                    prefs.setStringList(
                                        "call_history", callHistory);
                                    setState(() {});
                                  } catch (e) {
                                    log("error while removing $e");
                                  }

                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  isSelected =
                                      callHistory.map((e) => false).toList();
                                  log("no"); // Cancel the deletion
                                  setState(() {});
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.delete,
                      color: RuntimeStorage().PrimaryOrange,
                    ))
              ],
            )
          : AppBar(
              elevation: 0.5,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              title: Column(
                children: [
                  isSearchClicked
                      ? TextField(
                          controller: searchValue,
                          onChanged: (v) {
                            log("the text valuee ${v}");
                            isSelected = isSelected.map((e) => false).toList();

                            setState(() {
                              callHistory =
                                  prefs.getStringList("call_history") ?? [];
                            });

                            log("call history length ${callHistory.length}");
                            callHistory = callHistory.where((e) {
                              var data = json.decode(e);

                              return data["callerName"]!
                                  .toLowerCase()
                                  .startsWith(v.toLowerCase());
                            }).toList();

                            log("callhistory length after search ${callHistory.length}");
                            setState(() {});
                          },
                          decoration: InputDecoration(
                              hintText: 'Search users...',
                              border: InputBorder.none),
                        )
                      : Row(
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
                GestureDetector(
                  onTap: () {
                    isSearchClicked = !isSearchClicked;
                    setState(() {});
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(),
                    child: SvgPicture.asset("assets/Vector.svg"),
                  ),
                ),

                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => NewProfileScreen()));
                    },
                    child: Container(
                      width: 41,
                      child: UserClass.LoggedUser != null
                          ? CircleAvatar(
                              backgroundImage: AssetImage("assets/profile.png"),
                              foregroundImage:
                                  UserClass.LoggedUser!.privateProfilePicUrl !=
                                          null
                                      ? CachedNetworkImageProvider(G.HOST +
                                          "api/v1/images/" +
                                          UserClass.LoggedUser!
                                              .privateProfilePicUrl!)
                                      : null,
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : callHistory.isEmpty
              ? Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/no calls icon.svg"),
                      Padding(
                        padding: const EdgeInsets.only(top: 37),
                        child: Text(
                          'There is no call yet. ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 18,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: callHistory.length,
                  itemBuilder: (ctx, i) {
                    final g = json.decode(callHistory[i]);
                    log("the index $i");
                    UserDetail currentUser;
                    if (allUser.isNotEmpty) {
                      currentUser = allUser
                          .where((e) => e.phoneNumber == g["caller"])
                          .first;
                    } else {
                      currentUser = UserDetail(
                          privateProfilePicUrl: null,
                          publicProfilePicUrl: null,
                          publicName: g["caller"] == G.userPhoneNumber
                              ? G.loggedinUser.publicName
                              : g["caller"]);
                    }

                    // List<UserDetail> u = g["callTo"] == G.userPhoneNumber ? user.where((element) => element.phoneNumber == g["callTo"]).toList()
                    //     : user
                    //         .where((element) => element.phoneNumber == g["caller"])
                    //         .toList();
                    return ListTile(
                        onTap: () {
                          setState(() {
                            if (isSelected.contains(true)) {
                              isSelected[i] = !isSelected[i];
                            }
                          });
                        },
                        onLongPress: () {
                          setState(() {
                            isSelected[i] = !isSelected[i];
                          });
                          log("inside long press ${isSelected[i]} $i");
                        },
                        hoverColor: RuntimeStorage().PrimaryOrange,
                        enabled: true,
                        selected: isSelected[i],
                        selectedTileColor:
                            RuntimeStorage().PrimaryOrange.withOpacity(0.2),
                        leading: g["profilePic"] != null &&
                                g["profilePic"] != ""
                            ? Stack(children: [
                                CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/profile.png"),
                                  foregroundImage: g["profilePic"] != null
                                      ? CachedNetworkImageProvider(
                                          G.HOST +
                                              "api/v1/images/" +
                                              g["profilePic"],
                                        )
                                      : AssetImage("assets/profile.png")
                                          as ImageProvider,
                                ),
                                isSelected[i]
                                    ? Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors
                                                .white, // White border background
                                          ),
                                          padding: EdgeInsets.all(
                                              0), // Space for the border
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            size: 20,
                                            color: RuntimeStorage()
                                                .PrimaryOrange, // Icon color
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ])
                            : CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    AssetImage("assets/profile.png"),
                              ),
                        title: Text(
                          g["callerName"] ?? "",
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 16,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              width: 21,
                              height: 21,
                              child: g["caller"] == G.userPhoneNumber
                                  ? SvgPicture.asset("assets/Dial.svg")
                                  : SvgPicture.asset("assets/received.svg"),
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              formatDateTimeString(g["time"].toString()),
                              style: TextStyle(
                                color: Color(0xFF707070),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          height: 20,
                          width: 35,
                          child: g["call_type"] == "video"
                              ? SvgPicture.asset("assets/videoLogo.svg")
                              : SvgPicture.asset("assets/callLogo.svg"),
                        ));
                  }),
    );
  }
}
