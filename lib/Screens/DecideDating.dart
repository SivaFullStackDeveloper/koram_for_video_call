// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:koram_app/Helper/Helper.dart';
// import 'package:koram_app/Models/Notification.dart' as N;
// import 'package:koram_app/Screens/DatingScreen.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// import '../Helper/CommonDatingWidgets.dart';
// import '../Models/datingIncompleteReg.dart';
// import '../Models/datingProfileModel.dart';
// import '../Widget/Badge.dart';
// import 'DatingSplash.dart';
// import 'NewProfileScreen.dart';
// import 'NotificationScreen.dart';
//
// class DecideDating extends StatefulWidget {
//   DecideDating({key,required this.isJustRegistered});
//   bool isJustRegistered=false;
//   @override
//   State<DecideDating> createState() => _DecideDatingState();
// }
//
// class _DecideDatingState extends State<DecideDating> {
//   var selectedValue = "No";
//   bool isRegistered = false;
//   bool displayDatingScreen = false;
//   bool isDeactivated=false;
//   DatingProfiles sortedProfiles = DatingProfiles();
//   List<String>imcompleteRegList=[];
//   @override
//   void initState() {
//     // TODO: implement initState
// if(widget.isJustRegistered==true)
// {
//   setState(() {
//     displayDatingScreen=true;
//   });
// }
//     GetDatingList();
//     super.initState();
//   }
//
//   GetDatingList() async {
//     final url = G.HOST + "api/v1/getDatingList";
//     try {
//       log("phonenumberr ${G.userPhoneNumber}");
//       var response = await http.post(Uri.parse(url),
//           body: {"phoneNumber": G.userPhoneNumber}).timeout(
//         Duration(seconds: 10), // Adjust the timeout duration as needed
//       );
//
//       log("dating list  responseee${json.decode(response.statusCode.toString())}");
//
//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         sortedProfiles = DatingProfiles.fromJson(jsonData);
//         setState(() {
//           displayDatingScreen=true;
//         });
//       } else if (response.statusCode == 201 ) {
//
//         final jsonData = json.decode(response.body);
//         log("TYPE od 201"+jsonData["type"]);
//         if(jsonData["type"]=="RegistrationIncomplete")
//         {
//          imcompleteRegList=incompleteDatingReg.fromJson(jsonData).imcompleteList??[];
//          Navigator.of(context).push(
//              MaterialPageRoute(builder: (context) {
//                return DatingSplash();
//              }));
//
//         }
//         else if(jsonData["type"]=="notActive")
//         {
//           setState(() {
//             displayDatingScreen=false;
//             isDeactivated=true;
//           });
//
//         }
//       } else {
//         log("error $response.statusCode");
//        CommonDatingWidgets().errorDialog(context);
//       }
//     } on TimeoutException catch (_) {
//       // Handle timeout exception here
//       log("TimeoutException: Server request timed out");
//       return "timeout"; // Replace with your specific error code
//     } catch (error) {
//       // Handle other exceptions here
//       log("Error in otp: $error");
//       return 500; // Replace with your generic error code
//     }
//   }
//
//   // setIsResgistered() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   setState(() {
//   //     isRegistered = prefs.getBool('isDatingRegistered') ?? false;
//   //   });
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     List<N.Notification> notification =
//         Provider.of<N.Notifications>(context).notification;
//     return displayDatingScreen != true
//         ? Scaffold(
//             appBar: AppBar(
//               elevation: 0.5,
//               automaticallyImplyLeading: false,
//               backgroundColor: Colors.white,
//               title: Column(
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SvgPicture.asset("assets/Layer 2.svg"),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Text(
//                         "Koram",
//                         style: TextStyle(
//                           color: Color(0xFF303030),
//                           fontSize: 23.96,
//                           fontFamily: 'Helvetica',
//                           fontWeight: FontWeight.w600,
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//               actions: [
//                 // GestureDetector(
//                 //     onTap: () async {
//                 //       SharedPreferences prefs =
//                 //           await SharedPreferences.getInstance();
//                 //       setState(() {
//                 //         prefs.setString("userId", "");
//                 //         prefs.setBool('logedIn', false);
//                 //         G.userId = "";
//                 //         G.logedIn = false;
//                 //       });
//                 //       Navigator.of(context)
//                 //           .push(MaterialPageRoute(builder: (ctx) => LoginScreen()));
//                 //     },
//                 //     child: Container(
//                 //         // margin: EdgeInsets.all(8),
//                 //         height: 30,
//                 //         child: Text("logout"))),
//                 Container(
//                   width: 25,
//                   height: 25,
//                   decoration: BoxDecoration(),
//                   child: SvgPicture.asset("assets/Vector.svg"),
//                 ),
//                 const SizedBox(width: 10),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (ctx) => NotificationScreen()));
//                     // showModalBottomSheet(
//                     //     context: context,
//                     //     elevation: 3,
//                     //     isScrollControlled: true,
//                     //     builder: (ctx) => NotificationBottomSheet());
//                   },
//                   child: BadgeWidget(
//                       child: Container(
//                           margin: EdgeInsets.all(8),
//                           height: 30,
//                           child: SvgPicture.asset("assets/notify bell.svg")),
//                       value: notification.length),
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (ctx) => NewProfileScreen(
//                               loggedUser: G.loggedinUser,
//                             )));
//                   },
//                   child: Container(
//                     width: 31.94,
//                     height: 31.94,
//                     decoration: ShapeDecoration(
//                       image: G.loggedinUser.publicProfilePicUrl != ""
//                           ? DecorationImage(
//                               image: NetworkImage(G.HOST +
//                                   "api/v1/images/" +
//                                   G.loggedinUser.publicProfilePicUrl!),
//                               fit: BoxFit.contain,
//                             )
//                           : DecorationImage(
//                               image: AssetImage("assets/profile.png"),
//                               fit: BoxFit.contain),
//                       shape: CircleBorder(),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 19,
//                 ),
//                 // IconButton(
//                 //     onPressed: () {
//                 //       Navigator.of(context).push(MaterialPageRoute(
//                 //           builder: (ctx) => PrivarteProfileScreen()));
//                 //     },
//                 //     icon: Container(
//                 //         // margin: EdgeInsets.all(8),
//                 //         height: 30,
//                 //         child: Image.asset("assets/Mask Group 1.png"))),
//               ],
//             ),
//             backgroundColor: Colors.white,
//             body: Center(
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text("Create a Dating Profile ?"),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Row(
//                           children: [
//                             Text("Yes"),
//                             Radio(
//                               value: "Yes",
//                               groupValue: selectedValue,
//                               onChanged: (value) async {
//                                 setState(
//                                     () => selectedValue = value.toString());
//                                 log("Yes selected");
//
//                                 String uploadUrl =
//                                     G.HOST + "api/v1/activateDating";
//                                 var response = await http
//                                     .post(Uri.parse(uploadUrl), body: {
//                                   "phone_number": G.userPhoneNumber,
//                                   "datingActive": "yes"
//                                 });
//                                 if (response.statusCode == 200) {
//                                   log("inside success of edit ");
//
//                                   Navigator.of(context).push(
//                                       MaterialPageRoute(builder: (context) {
//                                     return DatingSplash();
//                                   }));
//                                 } else {
//                                   await CommonDatingWidgets()
//                                       .errorDialog(context);
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Text("No"),
//                             Radio(
//                               value: "No",
//                               groupValue: selectedValue,
//                               onChanged: (value) async {
//                                 setState(
//                                     () => selectedValue = value.toString());
//                                 log("Yes selected");
//
//                                 String uploadUrl =
//                                     G.HOST + "api/v1/activateDating";
//                                 var response = await http
//                                     .post(Uri.parse(uploadUrl), body: {
//                                   "phone_number": G.userPhoneNumber,
//                                   "datingActive": "no"
//                                 });
//                                 if (response.statusCode == 200) {
//                                   log("inside success of edit ");
//                                 } else {
//                                   await CommonDatingWidgets()
//                                       .errorDialog(context);
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           )
//         : datingScreen(sortedProfiles:sortedProfiles ,);
//   }
// }
