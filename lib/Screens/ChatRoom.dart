import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:koram_app/Helper/color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Screens/ExploreScreen.dart';
import 'package:koram_app/Screens/NotificationScreen.dart';
import 'package:koram_app/Widget/ChatRoomCard.dart';
import 'package:provider/provider.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/Helper.dart';
import '../Models/ChatRoom.dart';
import '../Models/NewUserModel.dart';
import '../Models/User.dart';
import '../Widget/Badge.dart';
import '../Widget/BottomSheetContent.dart';
import 'package:koram_app/Models/Notification.dart' as N;

import 'ChatRoomScreen.dart';
import 'NewProfileScreen.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen();

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with SingleTickerProviderStateMixin {
  bool explore = false;
  bool isChatroomLoad = false;
  List<ChatRoom> allRooms = [];
  int locationRoomcount = 0;
  int favRoomcount = 0;
  int interestroomCount = 0;
  int trendingroomCount = 0;
  var searchValue = TextEditingController();
  bool isJoinedRoom = false;
  var _tabController;
  String? joinedChatRoomId;
  String ChatRoomTitle = "Chat Room";
  ChatRoom? SelectedRoom;
  String searchcategory = "all";
  bool isPreferenceFetched = false;
  bool isSearchClicked = false;
  late SharedPreferences prefs;
  UserModel loggedUserDetails = UserModel();
  File? profileImage;
  bool canPOP = true;
  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      _tabController = TabController(length: 2, vsync: this, initialIndex: 0);

      // profileImage = await G().getImageFile("private");

      setState(() {
        isChatroomLoad = true;
      });
      prefs = await SharedPreferences.getInstance();

      loggedUserDetails = UserModel.fromJson(
          jsonDecode(prefs.getString("LoggedInUserData") ?? ""));
      await Provider.of<ChatRoomsProvider>(context, listen: false)
          .fetchChatRoom();

      log("isjoinedRoom ${prefs.getBool("isJoinedRoom")} Room Id ${prefs.getString("JoindRoomId")} Room Name ${prefs!.getString("JoindRoomName")}");
      if (mounted) {
        setState(() {
          isChatroomLoad = false;
          isPreferenceFetched = true;
        });
      }
    });

    // TODO: implement initState
    super.initState();
  }

  var title;
  ChangeTab() {
    log("Change tab called ${_tabController.index}");
    _tabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    UsersProviderClass UserClass =
        Provider.of<UsersProviderClass>(context, listen: false);
    List<N.Notification> notification =
        Provider.of<N.Notifications>(context).notification;
    allRooms = Provider.of<ChatRoomsProvider>(context).chatRooms;
    ChatRoomsProvider chatRoomProviderLocal =
        Provider.of<ChatRoomsProvider>(context, listen: true);

    locationRoomcount = 0;
    trendingroomCount = 0;
    interestroomCount = 0;
    favRoomcount = 0;
    if (isPreferenceFetched) {
      allRooms.forEach((element) {
        if (element.id == prefs!.getString("JoinedRoomId")) {
          chatRoomProviderLocal.SelectedRoom = element;
          SelectedRoom = element;

          log(" Matched  room  ${element.name} ${element.id} Prefid ${prefs!.getString("JoinedRoomId")}");
        }
        switch (element.superCategory) {
          case "Location":
            {
              log("" + element.superCategory!);
              locationRoomcount = element.users!.length;

              setState(() {
                locationRoomcount;
              });

              log("location room Count $locationRoomcount");
            }
            break;
          case "Trending":
            {
              setState(() {
                trendingroomCount = element.users!.length;
              });
              log("Trending room Count $trendingroomCount");
            }
            break;
          case "Interest":
            {
              setState(() {
                interestroomCount = element.users!.length;
              });
              log("Interest room Count $interestroomCount");
            }
            break;
          case "Favourite":
            {
              setState(() {
                favRoomcount = element.users!.length;
              });
              log("Favourite room Count $favRoomcount");
            }
            break;
        }
      });
      if (!isChatroomLoad) {
        isJoinedRoom = prefs!.getBool("isJoinedRoom") ?? false;
        ChatRoomTitle = prefs!.getString("JoinedRoomName") ?? "Chat Room";
        joinedChatRoomId = prefs!.getString("JoinedRoomId");

        if (prefs!.getBool("isJoinedRoom") == true &&
            chatRoomProviderLocal.isFromExplore) {
          setState(() {
            _tabController.index = 1;
          });
          chatRoomProviderLocal.isFromExplore = false;
        }
      }
    }
    // DefaultTabController.of(context).addListener(() {
    //   if (DefaultTabController.of(context).index == 1) {
    //     log("inside index one ");
    //      G.isOnChatroom=false;
    //   } else {
    //     log("inside index 0");
    //    G.isOnChatroom=true;
    //   }
    // });
    return PopScope(
      canPop: canPOP,
      onPopInvoked: (t) {
        log("popscope called in chatroom main screen ${_tabController.index}");

        if (explore) {
          setState(() {
            explore = false;
          });
          canPOP = false;
          return;
        } else {
          if (_tabController.index == 0) {
            ChatRoomsProvider.isChangePage = true;
            // chatRoomProviderLocal.ChangeHomePage();
            canPOP = true;
            return;
          } else if (_tabController.index == 1) {
            _tabController.animateTo(1);
            canPOP = false;
            return;
          }
        }
        canPOP = false;
      },
      child: explore
          ? ExploreScreen(
              title: title,
              isSearching: true,
              searchCategory: searchcategory,
              change: () {
                isJoinedRoom = prefs!.getBool("isJoinedRoom") ?? false;
                joinedChatRoomId = prefs!.getString("JoindRoomId");
                ChatRoomTitle =
                    prefs!.getString("JoindRoomName") ?? "Chat Room";
                log("isjoinedRoom $isJoinedRoom Room Id $joinedChatRoomId");

                setState(() {
                  explore = false;
                });
              },
              ChangeTab: ChangeTab,
            )
          : DefaultTabController(
              length: 2,
              animationDuration: Duration(milliseconds: 500),
              initialIndex: 0,
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0.5,
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
                  bottom: TabBar(
                      controller: _tabController,
                      indicatorColor: backendColor,
                      labelColor: backendColor,
                      unselectedLabelColor: Color(0xFF303030),
                      unselectedLabelStyle: TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 14,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                      // controller: ChatTabController,
                      tabs: [
                        Tab(
                          text: "Explore",
                          // child: Text(
                          //   'Messages',
                          //   style: TextStyle(
                          //     // color: ChatTabController.index==0?backendColor:Color(0xFF303030),
                          //     fontSize: 14,
                          //     fontFamily: 'Helvetica',
                          //     fontWeight: FontWeight.w400,
                          //     height: 0,
                          //   ),
                          // ),
                        ),
                        Tab(
                          // child: Text(
                          //   'Stories',
                          //   style: TextStyle(
                          //     // color: ChatTabController.index==1?backendColor:Color(0xFF303030),
                          //     fontSize: 14,
                          //     fontFamily: 'Helvetica',
                          //     fontWeight: FontWeight.w400,
                          //     height: 0,
                          //   ),
                          // ),
                          text: ChatRoomTitle,
                        )
                      ]),
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
                        setState(() {
                          isSearchClicked = true;
                          explore = true;
                          title = "search room";
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(),
                        child: SvgPicture.asset("assets/Vector.svg"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => NotificationScreen()));
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
                              child:
                                  SvgPicture.asset("assets/notify bell.svg")),
                          value: notification.length),
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
                          child: UserClass.LoggedUser != null &&
                                  UserClass.LoggedUser!.privateProfilePicUrl !=
                                      null
                              ? CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/profile.png"),
                                  foregroundImage: CachedNetworkImageProvider(
                                      G.HOST +
                                          "api/v1/images/" +
                                          UserClass.LoggedUser!
                                              .privateProfilePicUrl!),
                                  // onForegroundImageError: (){}AssetImage("assets/profile.png"),
                                  radius: 60,
                                  backgroundColor: Colors.grey[300],
                                )
                              : CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/profile.png"),
                                  radius: 60,
                                  backgroundColor: Colors.grey[300],
                                ),
                        )

                        // Container(
                        //   width: 31.94,
                        //   height: 31.94,
                        //   decoration: ShapeDecoration(
                        //     image: loggedUserDetails.userDetail?.publicProfilePicUrl != ""
                        //         ? DecorationImage(
                        //             image: NetworkImage(G.HOST +
                        //                 "api/v1/images/" +
                        //                 loggedUserDetails.userDetail!.publicProfilePicUrl! ),
                        //             fit: BoxFit.contain,
                        //           )
                        //         : DecorationImage(
                        //             image: AssetImage("assets/profile.png"),
                        //             fit: BoxFit.contain),
                        //     shape: CircleBorder(),
                        //   ),
                        // ),
                        ),
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
                body: TabBarView(
                    controller: _tabController,
                    physics: BouncingScrollPhysics(),
                    children: [
                      Builder(builder: (BuildContext context) {
                        return ListView(
                          physics: BouncingScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 28,
                            ),
                            ChatRoomCard(
                              image: "assets/chatRoomLocation.svg",
                              title: "Location",
                              userCount: locationRoomcount,
                              color: backendColor,
                              change: () {
                                setState(() {
                                  explore = true;
                                  title = "Location";
                                });
                                //    Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>LocationRoom()));
                              },
                            ),
                            ChatRoomCard(
                                userCount: interestroomCount,
                                image: "assets/chatRoomInterest.svg",
                                title: "Interest",
                                color: Colors.red.shade400,
                                change: () {
                                  setState(() {
                                    explore = true;
                                    title = "Interest";
                                  });
                                }),
                            ChatRoomCard(
                                userCount: trendingroomCount,
                                image: "assets/chatRoomTrending.svg",
                                title: "Trending",
                                color: Colors.blue,
                                change: () {
                                  setState(() {
                                    explore = true;
                                    title = "Trending";
                                  });
                                }),
                            ChatRoomCard(
                              userCount: favRoomcount,
                              image: "assets/chatRoomFav.svg",
                              title: "Favourite",
                              color: backendColor,
                              change: () {
                                setState(() {
                                  explore = true;
                                  title = "Favourite";
                                });
                              },
                            ),
                          ],
                        );
                      }),
                      Builder(builder: (BuildContext context) {
                        return chatRoomProviderLocal.SelectedRoom != null
                            ? ChatRoomScreenChat(
                                // LeaveRoom: () {
                                //   log("LEave Room from main Screen Called ");
                                //   // Navigator.pop(context);
                                //   // prefs.setBool("isJoinedRoom", false);
                                //   // prefs.setString("JoindRoomId", "");
                                //   // prefs.setString("JoindRoomName", "");
                                //   //
                                //   //   setState(() {
                                //   //     explore = true;
                                //   //     isJoinedRoom = false;
                                //   //     joinedChatRoomId = "";
                                //   //     ChatRoomTitle = "";
                                //   //   });
                                //
                                // },
                                groupName: chatRoomProviderLocal.SelectedRoom!,
                                changeTab: ChangeTab,
                                // ChatRoomId: joinedChatRoomId,
                                //       isAlreadyJoined: isJoinedRoom,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Stack(
                                      children: [
                                        // Positioned(
                                        //
                                        //     child: SvgPicture.asset("assets/chatRoomBg.svg"),
                                        //   left: 0,
                                        //   right: 0,
                                        //   top: 0,
                                        //
                                        // ),
                                        Icon(
                                          Icons.message,
                                          color: backendColor,
                                          size: 100,
                                        ),
                                        // SvgPicture.asset(
                                        //     "assets/chatRoomFront.svg"),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 268,
                                    child: Text(
                                      'Start your chatroom now!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF303030),
                                        fontSize: 18,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 17, 10, 0),
                                    child: SizedBox(
                                      width: 349,
                                      child: Text(
                                        'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFF707070),
                                          fontSize: 14,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.w400,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _tabController.animateTo(0);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 40, 10, 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 54,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 18),
                                              decoration: ShapeDecoration(
                                                color: backendColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'EXPLORE CHATROOMS',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontFamily: 'Helvetica',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              );
                      })
                    ]),
              ),
            ),
    );
  }
}
