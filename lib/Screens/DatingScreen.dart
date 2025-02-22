// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:geolocator/geolocator.dart';
// import 'dart:math'as math;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:http/http.dart';
// import 'package:koram_app/Helper/CommonWidgets.dart';
// import 'package:koram_app/Models/NewUserModel.dart';
// import 'package:koram_app/Models/datingProfileModel.dart';
// import 'package:path/path.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:swipable_stack/swipable_stack.dart';
// import 'package:koram_app/Models/Notification.dart' as N;
// import 'package:http/http.dart' as http;
//
// import '../Helper/Helper.dart';
// import '../Models/User.dart';
// import '../Widget/Badge.dart';
// import 'ExampleCard.dart';
// import 'NewProfileScreen.dart';
// import 'NotificationScreen.dart';
// import 'bottomButtonRow.dart';
// import 'cardLabel.dart';
// import 'cardOverlay.dart';
//
// class datingScreen extends StatefulWidget {
//   datingScreen({key, required this.sortedProfiles});
//   DatingProfiles sortedProfiles;
//   @override
//   State<datingScreen> createState() => _datingScreenState();
// }
//
// class _datingScreenState extends State<datingScreen> {
//   late final SwipableStackController _controller;
//
//   void _listenController() => setState(() {});
//   DatingProfiles sortedProfiles = DatingProfiles();
//   var CurrentIndex;
//   bool isListEnded = false;
//   bool isEmptySorted = false;
//
//   Future<void> showMatchDialog(BuildContext context, imagePath) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("It's a Match"),
//           content: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             decoration: ShapeDecoration(
//               image: DecorationImage(
//                   image: NetworkImage(
//                       G.HOST + "api/v1/datingImage/" + imagePath),
//                   fit: BoxFit.fitWidth),
//
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(18),
//               ),
//             ),
//           ),
//           actions: <Widget>[
//             Row(children: [
//
//               TextButton(
//                 child: const Text('Ok'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//               Expanded(child: SizedBox(),),
//               TextButton(
//                 child: const Text('Chat'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],),
//
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = SwipableStackController()..addListener(_listenController);
//     _selectedGenderPref = _dropdownItems.first;
//     if (widget.sortedProfiles != null) {
//
//       if (widget.sortedProfiles.profiles!.isEmpty) {
//         setState(() {
//           isEmptySorted = true;
//         });
//       }
//     }
//     _getCurrentLocation();
//
//     log("the sorted list ${widget.sortedProfiles.toJson()}");
//   }
//   late Position _currentPosition;
//   List<Profiles> _nearbyUsers = [];
//
//   final double minDistanceInMiles = 1.0;
//   final double maxDistanceInMiles = 10.0;
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);
//       setState(() {
//         _currentPosition = position;
//       });
//       log("currentPosition ${_currentPosition}");
//       _fetchNearbyUsers();
//     } catch (e) {
//       print(e);
//     }
//   }
//   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const double earthRadius = 6371; // Radius of the earth in km
//
//     double dLat = _degreesToRadians(lat2 - lat1);
//     double dLon = _degreesToRadians(lon2 - lon1);
//
//     double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
//             math.sin(dLon / 2) * math.sin(dLon / 2);
//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     double distanceInKm = earthRadius * c;
//
//     // Convert distance from kilometers to miles
//     return distanceInKm * 0.621371;
//   }
//
//   double _degreesToRadians(double degrees) {
//     return degrees * (math.pi / 180);
//   }
//
//   void _fetchNearbyUsers() {
//     log("insde fetchnewarby");
//     DatingProfiles  nearbyUsersData = widget.sortedProfiles; // Fetch nearby users data from your backend
//              log("nearbydata ${nearbyUsersData.profiles?.length}");
//     List<Profiles> usersWithinRange = [];
//     for (Profiles user in widget.sortedProfiles.profiles??[]) {
//       log("Lattt ${user.lat}  longg ${user.lon}");
//       double distanceInMiles = _calculateDistance(
//         _currentPosition.latitude,
//         _currentPosition.longitude,
//         user.lat?.toDouble()??0.0,
//         user.lon?.toDouble()??0.0,
//       );
//
//       if (distanceInMiles >= minDistanceInMiles && distanceInMiles <= maxDistanceInMiles) {
//         usersWithinRange.add(user);
//       }
//     }
//
//     setState(() {
//       _nearbyUsers = usersWithinRange;
//     });
//     log("nearBy users"+_nearbyUsers.first.toJson().toString());
//   }
//
//
//   Future<Response> upDateSwipe(String directionOfSwipe, Profiles shownProfile,
//       BuildContext context) async {
//     log("DIRECTION of swipe " + directionOfSwipe);
//     log("shownProfile ${shownProfile.phoneNumber}");
//
//     String status = "";
//     switch (directionOfSwipe) {
//       case "SwipeDirection.right":
//         {
//           status = "accepted";
//         }
//         break;
//       case "SwipeDirection.left":
//         {
//           status = "rejected";
//         }
//         break;
//       case "Up":
//         {}
//     }
//
//     Response response =
//         await http.post(Uri.parse(G.HOST + "api/v1/swiped"), body: {
//       "displayedUserPhoneNumber": shownProfile.phoneNumber,
//       "swipingUserPhoneNumber": G.userPhoneNumber,
//       "status": status
//     });
//
//     if (response.statusCode == 200) {
//       log("successful swipe ${response.body}");
//       if (jsonDecode(response.body)["message"] == "Matched") {
//         showMatchDialog(context, shownProfile.datingPic1Url);
//       } else {
//         log("not matched");
//       }
//     } else {
//       log("unsuccessful swipe ${response.body}  ");
//     }
//     return response;
//   }
//
//   // GetDatingList()async
//   // {final url = G.HOST + "api/v1/getDatingList";
//   //   try {
//   //     var response = await http.post(Uri.parse(url),
//   //         body: {"phoneNumber": G.userPhoneNumber}).timeout(
//   //       Duration(seconds: 10), // Adjust the timeout duration as needed
//   //     );
//   //
//   //     log("Otp responseee${json.decode(response.statusCode.toString())}");
//   //
//   //     if(response.statusCode==200)
//   //     {
//   //       final jsonData = json.decode(response.body);
//   //       // Pass jsonData to DatingProfiles.fromJson
//   //       print(jsonData);
//   //       sortedProfiles = DatingProfiles.fromJson(jsonData);
//   //     }else if(response.statusCode==201)
//   //     {
//   //
//   //     }
//   //     else
//   //     {
//   //        log("No matched profiles");
//   //     }
//   //
//   //   } on TimeoutException catch (_) {
//   //     // Handle timeout exception here
//   //     log("TimeoutException: Server request timed out");
//   //     return "timeout"; // Replace with your specific error code
//   //   } catch (error) {
//   //     // Handle other exceptions here
//   //     log("Error in otp: $error");
//   //     return 500; // Replace with your generic error code
//   //   }
//   // }
//
//   List<String> _dropdownItems = [
//     'Male',
//     'Female',
//   ];
//   var _selectedGenderPref;
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller
//       ..removeListener(_listenController)
//       ..dispose();
//   }
//
//   double _sliderValue = 0.0;
//   RangeValues _ageRange = RangeValues(18, 50);
//
//   @override
//   Widget build(BuildContext context) {
//     List<N.Notification> notification =
//         Provider.of<N.Notifications>(context).notification;
//     List<UserDetail> user = Provider.of<UsersProviderClass>(context).user;
//     for (var i = 0; i < user.length / 2; i++) {
//       var temp = user[i];
//       user[i] = user[user.length - 1 - i];
//       user[user.length - 1 - i] = temp;
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0.5,
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.white,
//         title: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SvgPicture.asset("assets/Layer 2.svg"),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Text(
//                   "Koram",
//                   style: TextStyle(
//                     color: Color(0xFF303030),
//                     fontSize: 23.96,
//                     fontFamily: 'Helvetica',
//                     fontWeight: FontWeight.w600,
//                   ),
//                 )
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           // GestureDetector(
//           //     onTap: () async {
//           //       SharedPreferences prefs =
//           //           await SharedPreferences.getInstance();
//           //       setState(() {
//           //         prefs.setString("userId", "");
//           //         prefs.setBool('logedIn', false);
//           //         G.userId = "";
//           //         G.logedIn = false;
//           //       });
//           //       Navigator.of(context)
//           //           .push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
//           //     },
//           //     child: Container(
//           //         // margin: EdgeInsets.all(8),
//           //         height: 30,
//           //         child: Text("logout"))),
//           GestureDetector(
//             onTap: () {
//               showModalBottomSheet(
//                 backgroundColor: Colors.white,
//
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30),
//                   ),
//                 ),
//                 // context and builder are
//                 // required properties in this widget
//                 context: context,
//                 builder: (BuildContext context) {
//                   // we set up a container inside which
//                   // we create center column and display text
//
//                   // Returning SizedBox instead of a Container
//                   return StatefulBuilder(
//                       builder: (BuildContext context, StateSetter setState) {
//                     return Container(
//                       width: 390,
//                       height: 427,
//                       // decoration: ShapeDecoration(
//                       //   color: Colors.white,
//                       //   shape: RoundedRectangleBorder(
//                       //     borderRadius: BorderRadius.only(
//                       //       topLeft: Radius.circular(30),
//                       //       topRight: Radius.circular(30),
//                       //     ),
//                       //   ),
//                       // ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(21, 28, 20, 24),
//                             child: Row(
//                               children: [
//                                 SvgPicture.asset("assets/charm_cross.svg"),
//                                 Expanded(child: SizedBox()),
//                                 Text(
//                                   'Filter',
//                                   style: TextStyle(
//                                     color: Color(0xFF303030),
//                                     fontSize: 18,
//                                     fontFamily: 'Helvetica',
//                                     fontWeight: FontWeight.w700,
//                                     height: 0,
//                                   ),
//                                 ),
//                                 Expanded(child: SizedBox()),
//                                 GestureDetector(
//                                   onTap: () async {
//                                     SharedPreferences pref =
//                                         await SharedPreferences.getInstance();
//                                     await pref.setBool(
//                                         'isDatingRegistered', false);
//                                     setState(() {});
//                                   },
//                                   child: Text(
//                                     'Clear',
//                                     textAlign: TextAlign.right,
//                                     style: TextStyle(
//                                       color: Color(0xFF707070),
//                                       fontSize: 14,
//                                       fontFamily: 'Helvetica',
//                                       fontWeight: FontWeight.w400,
//                                       height: 0,
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(21, 0, 20, 15),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   'Distance',
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 16,
//                                     fontFamily: 'Helvetica',
//                                     fontWeight: FontWeight.w700,
//                                     height: 0,
//                                   ),
//                                 ),
//                                 Expanded(child: SizedBox()),
//                                 Text(
//                                   '${_sliderValue.round()} miles',
//                                   textAlign: TextAlign.right,
//                                   style: TextStyle(
//                                     color: Color(0xFFFF6701),
//                                     fontSize: 14,
//                                     fontFamily: 'Helvetica',
//                                     fontWeight: FontWeight.w700,
//                                     height: 0,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           Slider(
//                             value: _sliderValue,
//                             min: 0.0,
//                             max: 100.0,
//                             onChanged: (double value) {
//                               setState(() {
//                                 _sliderValue = value;
//                               });
//                             },
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(21, 0, 20, 15),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   'Age',
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 16,
//                                     fontFamily: 'Helvetica',
//                                     fontWeight: FontWeight.w700,
//                                     height: 0,
//                                   ),
//                                 ),
//                                 Expanded(child: SizedBox()),
//                                 Text(
//                                   '${_ageRange.start.round()} - ${_ageRange.end.round()}',
//                                   textAlign: TextAlign.right,
//                                   style: TextStyle(
//                                     color: Color(0xFFFF6701),
//                                     fontSize: 14,
//                                     fontFamily: 'Helvetica',
//                                     fontWeight: FontWeight.w700,
//                                     height: 0,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           RangeSlider(
//                             values: _ageRange,
//                             min: 18,
//                             max: 100,
//                             onChanged: (RangeValues values) {
//                               setState(() {
//                                 _ageRange = values;
//                               });
//                             },
//                             labels: RangeLabels(
//                               _ageRange.start.round().toString(),
//                               _ageRange.end.round().toString(),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(21, 0, 20, 15),
//                             child: Container(
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     'Interested in',
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 14,
//                                       fontFamily: 'Helvetica',
//                                       fontWeight: FontWeight.w400,
//                                       height: 0,
//                                     ),
//                                   ),
//                                   DropdownButton<String>(
//                                     items: _dropdownItems
//                                         .map((String item) => DropdownMenuItem(
//                                               value: item,
//                                               child: Text(item),
//                                             ))
//                                         .toList(),
//                                     onChanged: (e) {
//                                       log("object of dropdown ${jsonEncode(e)}");
//                                       setState(() {
//                                         _selectedGenderPref = e;
//                                       });
//                                     },
//                                     borderRadius: BorderRadius.circular(30),
//                                     value: _selectedGenderPref,
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 14,
//                                       fontFamily: 'Helvetica',
//                                       fontWeight: FontWeight.w700,
//                                       height: 0,
//                                     ),
//                                   ),
//                                 ],
//                                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                               ),
//                               width: MediaQuery.of(context).size.width - 30,
//                             ),
//                           ),
//                           Expanded(
//                               child: SizedBox(
//                             height: 30,
//                           )),
//                           Container(
//                             width: 348,
//                             height: 54,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 18),
//                             decoration: ShapeDecoration(
//                               color: Color(0xFFFF6701),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'Apply Filter',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontFamily: 'Helvetica',
//                                     fontWeight: FontWeight.w700,
//                                     height: 0,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 10)
//                         ],
//                       ),
//                     );
//                   });
//                 },
//               );
//             },
//             child: Container(
//               width: 25,
//               height: 25,
//               decoration: BoxDecoration(),
//               child: SvgPicture.asset("assets/datingSlider.svg"),
//             ),
//           ),
//           const SizedBox(width: 10),
//           GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(
//                   MaterialPageRoute(builder: (ctx) => NotificationScreen()));
//               // showModalBottomSheet(
//               //     context: context,
//               //     elevation: 3,
//               //     isScrollControlled: true,
//               //     builder: (ctx) => NotificationBottomSheet());
//             },
//             child: BadgeWidget(
//                 child: Container(
//                     margin: EdgeInsets.all(8),
//                     height: 30,
//                     child: SvgPicture.asset("assets/notify bell.svg")),
//                 value: notification.length),
//           ),
//           SizedBox(
//             width: 10,
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(MaterialPageRoute(
//                   builder: (ctx) => NewProfileScreen(
//                         loggedUser: G.loggedinUser,
//                       )));
//             },
//             child: Container(
//               width: 31.94,
//               height: 31.94,
//               decoration: ShapeDecoration(
//                 image: G.loggedinUser.publicProfilePicUrl != ""
//                     ? DecorationImage(
//                         image: NetworkImage(G.HOST +
//                             "api/v1/images/" +
//                             G.loggedinUser.publicProfilePicUrl!),
//                         fit: BoxFit.contain,
//                       )
//                     : DecorationImage(
//                         image: AssetImage("assets/profile.png"),
//                         fit: BoxFit.contain),
//                 shape: CircleBorder(),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 19,
//           ),
//           // IconButton(
//           //     onPressed: () {
//           //       Navigator.of(context).push(MaterialPageRoute(
//           //           builder: (ctx) => PrivarteProfileScreen()));
//           //     },
//           //     icon: Container(
//           //         // margin: EdgeInsets.all(8),
//           //         height: 30,
//           //         child: Image.asset("assets/Mask Group 1.png"))),
//         ],
//       ),
//       body: SafeArea(
//         top: false,
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: isEmptySorted
//                   ? Center(
//                       child: Text("Sorry No Profiles were matched"),
//                     )
//                   : isListEnded == false
//                       ? SwipableStack(
//                           detectableSwipeDirections: const {
//                             SwipeDirection.right,
//                             SwipeDirection.left,
//                           },
//                           controller: _controller,
//                           onSwipeCompleted: (index, direction) async {
//                             log("Swipe Completed  current index $CurrentIndex  controller ${_controller.currentIndex} length ${widget.sortedProfiles.profiles?.length}");
//
//                             log("direction on swipe complete $direction ${_controller.currentIndex}");
//                             upDateSwipe(
//                                 direction.toString(),
//                                 widget.sortedProfiles
//                                     .profiles![_controller.currentIndex],
//                                 context);
//
//
//                             if (_controller.currentIndex + 1 ==
//                                 widget.sortedProfiles.profiles?.length) {
//                               setState(() {
//                                 isListEnded = true;
//                               });
//                             }
//
//                           },
//                           viewFraction: 0,
//                           horizontalSwipeThreshold: 1,
//                           verticalSwipeThreshold: 1,
//                           swipeAnchor: SwipeAnchor.top,
//                           itemCount: widget.sortedProfiles.profiles?.length,
//                           builder: (context, properties) {
//                             final itemIndex = properties.index %
//                                 widget.sortedProfiles.profiles!.length;
//                             CurrentIndex = properties.index;
//                             return Stack(
//                               children: [
//                                 Center(
//                                   child: ExampleCard(
//                                     name: widget.sortedProfiles
//                                             .profiles![itemIndex].name ??
//                                         "Sample",
//                                     imagePath: widget
//                                             .sortedProfiles
//                                             .profiles![itemIndex]
//                                             .datingPic1Url! ??
//                                         "",
//                                     interests: widget
//                                             .sortedProfiles
//                                             .profiles![itemIndex]
//                                             .datingYourInterest ??
//                                         ["sport"],
//                                   ),
//                                 ),
//
//                                 // more custom overlay possible than with overlayBuilder
//                                 if (properties.stackIndex == 0 &&
//                                     properties.direction != null)
//                                   CardOverlay(
//                                     swipeProgress: properties.swipeProgress,
//                                     direction: properties.direction!,
//                                   )
//                               ],
//                             );
//                           },
//                         )
//                       : Center(child: Text("List Has Ended")),
//             ),
//             // BottomButtonsRow(
//             //   onSwipe: (direction) {
//             //     _controller.next(swipeDirection: direction);
//             //   },
//             //   onRewindTap: _controller.rewind,
//             //   canRewind: _controller.canRewind,
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
