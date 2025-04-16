import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:koram_app/Models/Notification.dart' as N;
import 'package:koram_app/Helper/color.dart';
import '../Helper/Helper.dart';
import '../Models/User.dart';

class NotificationScreen extends StatefulWidget {
  final Future<dynamic>? callBackInitialize;
  NotificationScreen({key, this.callBackInitialize});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UsersProviderClass>(context).LoggedUser;
    List<N.Notification> notification =
        Provider.of<N.Notifications>(context, listen: true).notification;

    final thisUser = user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Notification',
          style: TextStyle(
            color: Color(0xFF303030),
            fontSize: 16,
            fontFamily: 'Helvetica',
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: GestureDetector(
            onTap: () async {
              if (await widget.callBackInitialize != null) {
                log("callback from notification screen");
                widget.callBackInitialize!;
              }
              Navigator.of(context).pop();
            },
            child: Container(
                height: 22,
                width: 22,
                child: SvgPicture.asset(
                  "assets/backArrow.svg",
                )),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: notification.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //SvgPicture.asset("assets/noNotification.svg"),
                    Icon(
                      Icons.notifications_off_outlined,
                      color: backendColor,
                      size: 100,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No Notification Found',
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
                )
              : ListView.builder(
                  itemCount: notification.length,
                  itemBuilder: (ctx, i) {
                    final u = [];
                    //  user
                    //      .where((element){
                    //        log("element PHHH ${element.phoneNumber}");
                    //  return  element.phoneNumber == notification[i].sentBy;
                    //  }
                    // ).toList();
                    log("Lengthh of U${u.length}");
                    return Padding(
                      padding: const EdgeInsets.only(left: 20, bottom: 20),
                      child: Column(
                        children: [
                          Container(
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      image: u[0].publicProfilePicUrl != ""
                                          ? DecorationImage(
                                              image: AssetImage(
                                                  "assets/profile.png"),

                                              // NetworkImage(G.HOST +
                                              //
                                              //
                                              //     "api/v1/images/" +
                                              //     ((u.length > 0)
                                              //         ? u[0].public_profile_pic_url
                                              //         : "")),
                                              fit: BoxFit.fill,
                                            )
                                          : DecorationImage(
                                              image: AssetImage(
                                                  "assets/profile.png"),
                                              fit: BoxFit.fill),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 222,
                                              child: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: u[0].privateName,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF303030),
                                                        fontSize: 14,
                                                        fontFamily: 'Helvetica',
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        height: 0,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          ' sent you a friend request',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF667084),
                                                        fontSize: 14,
                                                        fontFamily: 'Helvetica',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '3m ago',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: Color(0xFF707070),
                                                fontSize: 12,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )
                                          ],
                                        ),
                                        Text(
                                          notification[i].message,
                                          style: TextStyle(
                                            color: Color(0xFF707070),
                                            fontSize: 12,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w400,
                                            height: 0,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                Provider.of<N.Notifications>(
                                                        context,
                                                        listen: false)
                                                    .deleteNotification(
                                                        notification[i].id);
                                              },
                                              child: Container(
                                                width: 120,
                                                height: 44,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 14),
                                                decoration: ShapeDecoration(
                                                  color: Color(0xFFF2F2F2),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Decline',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Color(0xFF707070),
                                                    fontSize: 14,
                                                    fontFamily: 'Helvetica',
                                                    fontWeight: FontWeight.w700,
                                                    height: 0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                // await Provider.of<Users>(
                                                //     context,
                                                //     listen: false)
                                                //     .addFriend(
                                                //     notification[i]
                                                //         .sentTo,
                                                //     u[0].id);
                                                // await Provider.of<Users>(
                                                //     context,
                                                //     listen: false)
                                                //     .addFriend(
                                                //     notification[i]
                                                //         .sentBy,
                                                //     thisUser.id);
                                                // await Provider.of<
                                                //     N.Notifications>(
                                                //     context,
                                                //     listen: false)
                                                //     .deleteNotification(
                                                //     notification[i]
                                                //         .id);
                                                // Navigator.of(context)
                                                //     .pop();
                                              },
                                              child: Container(
                                                width: 120,
                                                height: 44,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 14),
                                                decoration: ShapeDecoration(
                                                  color: backendColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Accept',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontFamily: 'Helvetica',
                                                    fontWeight: FontWeight.w700,
                                                    height: 0,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Divider(
                                              thickness: 1,
                                            ))
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    );

                    // ListTile(
                    //   contentPadding: EdgeInsets.all(10),
                    //   leading: CircleAvatar(
                    //     radius: 30,
                    //     backgroundImage: NetworkImage(G.HOST +
                    //         "api/v1/images/" +
                    //         ((u.length > 0) ? u[0].profilePicUrl : "")),
                    //   ),
                    //   title: Text(
                    //     u[0].name,
                    //     style: TextStyle(fontWeight: FontWeight.bold),
                    //   ),
                    //   subtitle: Text(
                    //     "People Nearby",
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold,
                    //         color: backendColor),
                    //   ),
                    //   trailing: Container(
                    //     width: 150,
                    //     child: Row(
                    //       mainAxisAlignment:
                    //           MainAxisAlignment.spaceEvenly,
                    //       children: [
                    //         GestureDetector(
                    //           onTap: () {
                    //             showDialog(
                    //                 context: context,
                    //                 builder: (ctx) => Dialog(
                    //                       child: Container(
                    //                         height: 150,
                    //                         child: Column(
                    //                           mainAxisAlignment:
                    //                               MainAxisAlignment
                    //                                   .spaceEvenly,
                    //                           children: [
                    //                             Text(
                    //                               u[0].alias,
                    //                               style: TextStyle(
                    //                                   fontWeight:
                    //                                       FontWeight
                    //                                           .bold),
                    //                             ),
                    //                             Text(notification[i]
                    //                                 .message),
                    //                             Container(
                    //                               width: 150,
                    //                               child: Row(
                    //                                 mainAxisAlignment:
                    //                                     MainAxisAlignment
                    //                                         .spaceEvenly,
                    //                                 children: [
                    //                                   GestureDetector(
                    //                                     onTap: () async {
                    //                                       await Provider.of<
                    //                                                   Users>(
                    //                                               context,
                    //                                               listen:
                    //                                                   false)
                    //                                           .addFriend(
                    //                                               notification[i]
                    //                                                   .sentTo,
                    //                                               u[0].id);
                    //                                       await Provider.of<
                    //                                                   Users>(
                    //                                               context,
                    //                                               listen:
                    //                                                   false)
                    //                                           .addFriend(
                    //                                               notification[i]
                    //                                                   .sentBy,
                    //                                               thisUser
                    //                                                   .id);
                    //                                       await Provider.of<
                    //                                                   N.Notifications>(
                    //                                               context,
                    //                                               listen:
                    //                                                   false)
                    //                                           .deleteNotification(
                    //                                               notification[i]
                    //                                                   .id);
                    //                                       Navigator.of(
                    //                                               context)
                    //                                           .pop();
                    //                                     },
                    //                                     child: Container(
                    //                                       width: 70,
                    //                                       height: 30,
                    //                                       decoration:
                    //                                           BoxDecoration(
                    //                                               borderRadius:
                    //                                                   BorderRadius.circular(
                    //                                                       20),
                    //                                               boxShadow: [
                    //                                                 BoxShadow(
                    //                                                     color: Colors.grey.shade200,
                    //                                                     spreadRadius: 4,
                    //                                                     offset: Offset(2, 3),
                    //                                                     blurRadius: 2)
                    //                                               ],
                    //                                               color: Colors
                    //                                                   .orange),
                    //                                       child: Row(
                    //                                         mainAxisAlignment:
                    //                                             MainAxisAlignment
                    //                                                 .center,
                    //                                         children: [
                    //                                           SizedBox(
                    //                                             width: 3,
                    //                                           ),
                    //                                           Text(
                    //                                             "Accept",
                    //                                             style: TextStyle(
                    //                                                 color: Colors
                    //                                                     .white,
                    //                                                 fontSize:
                    //                                                     10),
                    //                                           )
                    //                                         ],
                    //                                       ),
                    //                                     ),
                    //                                   ),
                    //                                   GestureDetector(
                    //                                     onTap: () async {
                    //                                       Provider.of<N.Notifications>(
                    //                                               context,
                    //                                               listen:
                    //                                                   false)
                    //                                           .deleteNotification(
                    //                                               notification[i]
                    //                                                   .id);
                    //                                     },
                    //                                     child: Container(
                    //                                         width: 70,
                    //                                         height: 30,
                    //                                         decoration: BoxDecoration(
                    //                                             borderRadius: BorderRadius.circular(20),
                    //                                             border: Border.all(color: backendColor),
                    //                                             boxShadow: [
                    //                                               BoxShadow(
                    //                                                   color: Colors
                    //                                                       .grey.shade200,
                    //                                                   spreadRadius:
                    //                                                       4,
                    //                                                   offset: Offset(2,
                    //                                                       3),
                    //                                                   blurRadius:
                    //                                                       2)
                    //                                             ],
                    //                                             color: Colors.white),
                    //                                         child: Center(
                    //                                             child: Text(
                    //                                           "Decline",
                    //                                           style: TextStyle(
                    //                                               color: Colors
                    //                                                   .orange,
                    //                                               fontSize:
                    //                                                   10),
                    //                                         ))),
                    //                                   ),
                    //                                 ],
                    //                               ),
                    //                             ),
                    //                           ],
                    //                         ),
                    //                       ),
                    //                     ));
                    //           },
                    //           child: Container(
                    //             width: 70,
                    //             height: 30,
                    //             decoration: BoxDecoration(
                    //                 borderRadius:
                    //                     BorderRadius.circular(20),
                    //                 boxShadow: [
                    //                   BoxShadow(
                    //                       color: Colors.grey.shade200,
                    //                       spreadRadius: 4,
                    //                       offset: Offset(2, 3),
                    //                       blurRadius: 2)
                    //                 ],
                    //                 color: backendColor),
                    //             child: Row(
                    //               mainAxisAlignment:
                    //                   MainAxisAlignment.center,
                    //               children: [
                    //                 Container(
                    //                     height: 20,
                    //                     width: 15,
                    //                     child: Image.asset(
                    //                         "assets/email.png")),
                    //                 SizedBox(
                    //                   width: 3,
                    //                 ),
                    //                 Text(
                    //                   "View",
                    //                   style: TextStyle(
                    //                       color: Colors.white,
                    //                       fontSize: 10),
                    //                 )
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //         GestureDetector(
                    //           onTap: () async {
                    //             Provider.of<N.Notifications>(context,
                    //                     listen: false)
                    //                 .deleteNotification(
                    //                     notification[i].id);
                    //           },
                    //           child: Container(
                    //               width: 70,
                    //               height: 30,
                    //               decoration: BoxDecoration(
                    //                   borderRadius:
                    //                       BorderRadius.circular(20),
                    //                   border: Border.all(
                    //                       color: backendColor),
                    //                   boxShadow: [
                    //                     BoxShadow(
                    //                         color: Colors.grey.shade200,
                    //                         spreadRadius: 4,
                    //                         offset: Offset(2, 3),
                    //                         blurRadius: 2)
                    //                   ],
                    //                   color: Colors.white),
                    //               child: Center(
                    //                   child: Text(
                    //                 "Decline",
                    //                 style: TextStyle(
                    //                     color: backendColor,
                    //                     fontSize: 10),
                    //               ))),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // );
                  }),
        ),
      ),
    );
  }
}
