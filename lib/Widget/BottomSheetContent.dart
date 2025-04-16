import 'dart:developer';
import 'package:koram_app/Helper/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Models/Notification.dart' as N;
import 'package:koram_app/Models/User.dart';
import 'package:provider/provider.dart';

class NotificationBottomSheet extends StatefulWidget {
  // List<N.Notification> notification;
  NotificationBottomSheet();

  @override
  State<NotificationBottomSheet> createState() =>
      _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<NotificationBottomSheet> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    log("inside notification screen");
  }

  @override
  Widget build(BuildContext context) {
    List<UserDetail> user =
        Provider.of<UsersProviderClass>(context).finalFriendsList;
    List<N.Notification> notification =
        Provider.of<N.Notifications>(context).notification;
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Scaffold(
          // appBar: AppBar(
          //   leading: Padding(
          //     padding: const EdgeInsets.only(left: 10),
          //     child: Container(
          //       height: 32,
          //       child: InkWell(
          //           onTap: () {
          //             Navigator.pop(context);
          //           },
          //           child: SvgPicture.asset("assets/mingcute_arrow-up-fill.svg")),
          //     ),
          //   ),
          //   leadingWidth: 40,
          //   backgroundColor: Colors.white,
          //   title: Text(
          //     'Select Contact',
          //     style: TextStyle(
          //       color: Color(0xFF303030),
          //       fontSize: 16,
          //       fontFamily: 'Helvetica',
          //       fontWeight: FontWeight.w700,
          //       height: 0,
          //     ),
          //   ),
          //   actions: [
          //     Container(
          //       width: 25,
          //       height: 25,
          //       decoration: BoxDecoration(),
          //       child: Container(child: SvgPicture.asset("assets/Vector.svg")),
          //     ),
          //     const SizedBox(width: 15),
          //     SvgPicture.asset("assets/more-vertical.svg"),
          //     SizedBox(width: 15.11),
          //   ],
          // ),
          body: SafeArea(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: AppBar(
                      elevation: 0,
                      backgroundColor: Colors.white,
                      title: Text(
                        'Notification',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      leading: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: GestureDetector(
                          onTap: () {
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
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 600,
                    child: ListView.builder(
                        itemCount: notification.length,
                        itemBuilder: (ctx, i) {
                          var u = user
                              .where((element) =>
                                  element.phoneNumber == notification[i].sentBy)
                              .toList();
                          var thisUser = user
                              .where((element) =>
                                  element.phoneNumber == G.userPhoneNumber)
                              .toList()[0];
                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 20, bottom: 20),
                            child: Column(
                              children: [
                                Container(
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: ShapeDecoration(
                                            image: u[0].publicProfilePicUrl !=
                                                    ""
                                                ? DecorationImage(
                                                    image: NetworkImage(G.HOST +
                                                        "api/v1/images/" +
                                                        ((u.length > 0)
                                                            ? u[0]
                                                                .publicProfilePicUrl!
                                                            : "")),
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
                                                            text: u[0]
                                                                .privateName,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF303030),
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              height: 0,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                ' sent you a friend request',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xFF667084),
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Helvetica',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
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
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                                      Provider.of<
                                                                  N
                                                                  .Notifications>(
                                                              context,
                                                              listen: false)
                                                          .deleteNotification(
                                                              notification[i]
                                                                  .id);
                                                    },
                                                    child: Container(
                                                      width: 120,
                                                      height: 44,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 14),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color:
                                                            Color(0xFFF2F2F2),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Decline',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF707070),
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontWeight:
                                                              FontWeight.w700,
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
                                                      await Provider.of<
                                                                  UsersProviderClass>(
                                                              context,
                                                              listen: false)
                                                          .addFriend(
                                                              notification[i]
                                                                  .sentTo,
                                                              u[0].sId!);
                                                      await Provider.of<
                                                                  UsersProviderClass>(
                                                              context,
                                                              listen: false)
                                                          .addFriend(
                                                              notification[i]
                                                                  .sentBy,
                                                              thisUser.sId!);
                                                      await Provider.of<
                                                                  N
                                                                  .Notifications>(
                                                              context,
                                                              listen: false)
                                                          .deleteNotification(
                                                              notification[i]
                                                                  .id);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                      width: 120,
                                                      height: 44,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 14),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: backendColor,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Accept',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Helvetica',
                                                          fontWeight:
                                                              FontWeight.w700,
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
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  NotifiyWidget(List<UserDetail> u) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage("https://via.placeholder.com/48x48"),
                fit: BoxFit.fill,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 222,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Athalia Putri ',
                            style: TextStyle(
                              color: Color(0xFF303030),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: 'sent you a friend request',
                            style: TextStyle(
                              color: Color(0xFF667084),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
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
                'Hi Tauha, How are you?',
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
                  Container(
                    width: 120,
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 14),
                    decoration: ShapeDecoration(
                      color: Color(0xFFF2F2F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    width: 120,
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 14),
                    decoration: ShapeDecoration(
                      color: backendColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                  )
                ],
              )
            ],
          ),
        ]),
      ),
    );
  }
}
