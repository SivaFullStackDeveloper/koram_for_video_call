// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:koram_app/Helper/Helper.dart';
// import 'package:koram_app/Models/Notification.dart' as N;
// import 'package:koram_app/Models/User.dart';
// import 'package:provider/provider.dart';
//
// class ParticipantSheet extends StatefulWidget {
//   List user = [];
//   ParticipantSheet(this.user);
//   @override
//   _ParticipantSheetState createState() => _ParticipantSheetState();
// }
//
// class _ParticipantSheetState extends State<ParticipantSheet> {
//   bool showSearchBar = false;
//   var temp;
//   @override
//   Widget build(BuildContext context) {
//     var u = Provider.of<UsersProviderClass>(context);
//     return Column(
//       children: [
//         Container(
//           height: 50,
//           padding: EdgeInsets.all(10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Participants",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//               ),
//               Container(
//                 // width: 100,
//                 height: 50,
//                 child: Row(
//                   children: [
//                     if (showSearchBar)
//                       Container(
//                         width: 200,
//                         child: TextField(
//                           onChanged: (v) {
//                             if (v.isEmpty) {
//                               setState(() {
//                                 widget.user = temp;
//                               });
//                             }
//                             List us = widget.user.where((element) {
//                               var p = u.user.firstWhere((element1) =>
//                                   element1.phoneNumber == element.toString());
//                               return p.publicName!.startsWith(v);
//                             }).toList();
//                             setState(() {
//                               widget.user = us;
//                             });
//                           },
//                           decoration: InputDecoration(
//                               suffix: GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 showSearchBar = !showSearchBar;
//                                 widget.user = temp;
//                               });
//                             },
//                             child: Icon(Icons.close),
//                           )),
//                         ),
//                       )
//                     else
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             showSearchBar = !showSearchBar;
//                             temp = widget.user;
//                           });
//                         },
//                         child: Icon(
//                           Icons.search,
//                           size: 30,
//                         ),
//                       ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Icon(
//                         Icons.close,
//                         color: Colors.orange,
//                         size: 30,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//             child: Container(
//                 child: ListView.builder(
//                     itemCount: widget.user.length,
//                     itemBuilder: (ctx, i) {
//                       var p = u.user.firstWhere(
//                           (element) => element.phoneNumber == widget.user[i]);
//                       return ListTile(
//                         title: Container(width: 100, child: Text(p.publicName!)),
//                         subtitle: Text("online"),
//                         leading: CircleAvatar(
//                           backgroundImage: NetworkImage(
//                               G.HOST + "api/v1/images/" + p.publicProfilePicUrl!),
//                         ),
//                         trailing: Container(
//                           width: 200,
//                           child: widget.user[i] == G.userPhoneNumber
//                               ? Container()
//                               : Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     TextButton(
//                                         onPressed: () async {
//                                           await Provider.of<N.Notifications>(
//                                                   context,
//                                                   listen: false)
//                                               .addNotification("Hello",
//                                                   widget.user[i], G.userPhoneNumber);
//                                           // SnackBar
//                                         },
//                                         child: Text(
//                                           "Say Hello",
//                                           style: TextStyle(
//                                               decoration:
//                                                   TextDecoration.underline),
//                                         )),
//                                     GestureDetector(
//                                       onTap: () {
//                                         String txt = "";
//                                         showDialog(
//                                             context: context,
//                                             builder: (ctx) => Dialog(
//                                                   child: Container(
//                                                     height: 200,
//                                                     width: 100,
//                                                     child: Column(
//                                                       children: [
//                                                         Text("Send Message"),
//                                                         Container(
//                                                           decoration: BoxDecoration(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           5),
//                                                               border: Border.all(
//                                                                   color: Colors
//                                                                       .grey)),
//                                                           margin:
//                                                               EdgeInsets.all(
//                                                                   8.0),
//                                                           child: TextField(
//                                                             onChanged: (c) {
//                                                               txt = c;
//                                                             },
//                                                             maxLines: 6,
//                                                             decoration:
//                                                                 InputDecoration
//                                                                     .collapsed(
//                                                                         hintText:
//                                                                             "Write here"),
//                                                           ),
//                                                         ),
//                                                         GestureDetector(
//                                                           onTap: () async {
//                                                             await Provider.of<
//                                                                         N.Notifications>(
//                                                                     context,
//                                                                     listen:
//                                                                         false)
//                                                                 .addNotification(
//                                                                     txt,
//                                                                     widget.user[
//                                                                         i],
//                                                                     G.userPhoneNumber);
//                                                             Navigator.of(
//                                                                     context)
//                                                                 .pop();
//                                                             // SnackBar
//                                                           },
//                                                           child: Container(
//                                                               width: 70,
//                                                               height: 30,
//                                                               decoration:
//                                                                   BoxDecoration(
//                                                                       borderRadius:
//                                                                           BorderRadius.circular(
//                                                                               20),
//                                                                       boxShadow: [
//                                                                         BoxShadow(
//                                                                             color: Colors
//                                                                                 .grey.shade200,
//                                                                             spreadRadius:
//                                                                                 4,
//                                                                             offset: Offset(2,
//                                                                                 3),
//                                                                             blurRadius:
//                                                                                 2)
//                                                                       ],
//                                                                       color: Colors
//                                                                           .orange),
//                                                               child: Center(
//                                                                   child: Text(
//                                                                 "Send",
//                                                                 style: TextStyle(
//                                                                     color: Colors
//                                                                         .white,
//                                                                     fontSize:
//                                                                         10),
//                                                               ))),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ));
//                                       },
//                                       child: Container(
//                                           width: 100,
//                                           height: 30,
//                                           decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(20),
//                                               border: Border.all(
//                                                   color: Colors.orange),
//                                               boxShadow: [
//                                                 BoxShadow(
//                                                     color: Colors.grey.shade200,
//                                                     spreadRadius: 4,
//                                                     offset: Offset(2, 3),
//                                                     blurRadius: 2)
//                                               ],
//                                               color: Colors.white),
//                                           child: Center(
//                                               child: Text(
//                                             "Custom Message",
//                                             style: TextStyle(
//                                                 color: Colors.orange,
//                                                 fontSize: 10),
//                                           ))),
//                                     ),
//                                   ],
//                                 ),
//                         ),
//                       );
//                     })))
//       ],
//     );
//   }
// }
