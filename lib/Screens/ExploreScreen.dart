// import 'dart:ffi';

import 'dart:convert';
import 'dart:developer';

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Models/ChatRoom.dart';
import 'package:koram_app/Models/Message.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Screens/ChatRoomScreen.dart';
import 'package:koram_app/Screens/ChattingScreen.dart';
import 'package:koram_app/Widget/ExploreCard.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatRoom.dart';

class ExploreScreen extends StatefulWidget {
  final Function change;
  final String title;
  Function ChangeTab;
  bool isSearching = false;
  String searchCategory;

  ExploreScreen({
    required this.ChangeTab,
    required this.change,
    required this.title,
    required this.isSearching,
    required this.searchCategory,
  });

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  var _selected1;
  var _selected2;
  var _page = 0;
  var chatElementItemSelected = false;
  late bool isLoading = false;
  var _chatUser;
  var searchValue = TextEditingController();
  bool isExploreSearchClicked = false;
  bool isShowChatroomName = false;
  List<ChatRoom> chatElement = [];
  List<ChatRoom> SelectedRoom = [];
  List<ChatRoom> allRooms = [];
  List<ChatRoom> locationRoom = [];
  List<String> locationCategories = [];
  List<ChatRoom> allRoomCopy = [];
  bool showLocationList = false;
  String? selectedLocationCategory;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero).then((value) async {
      setState(() {
        isLoading = true;
      });
      await Provider.of<ChatRoomsProvider>(context, listen: false)
          .fetchChatRoom();

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var location = Provider.of<ChatRoomsProvider>(context).chatRooms;

    ChatRoomsProvider ProChatrooms =
        Provider.of<ChatRoomsProvider>(context, listen: true);
    ProChatrooms.isFromExplore = true;
    allRoomCopy = location;
    Set s = Set();
    locationCategories = [];
    locationRoom = [];

    final subCategory = location.where((element) {
      if (element.superCategory == "Location") {
        log("inside location addd");
        setState(() {
          if (locationCategories.isEmpty) {
            locationCategories.add(element.category!);
          } else if (!locationCategories.contains(element.category)) {
            locationCategories.add(element.category!);
          }
          locationRoom.add(element);
        });
        log("locationCateforie length ${locationCategories.length} locationRoom adedd ${element.name}");
      }
      log("inside location ${element.subCategory}");
      if (s.contains(element.subCategory)) {
        log("if block");
        return false;
      } else {
        log("inside else block");
        s.add((element.subCategory));
        print(element.superCategory);
        print(widget.title);
        return (element.category == _selected1 &&
            element.superCategory == widget.title);
      }
    }).toList();

    setState(() {});
    // _chatUser = Provider.of<UsersProviderClass>(context).LoggedUser;
    // _chatUser =
    //     _chatUser.where((element) => element.phoneNumber != G.userPhoneNumber).toList();

    final groupMessages = Provider.of<Messages>(context).groupMessage;

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return PopScope(
        // onWillPop: () {
        //   print("somthing");
        //   setState(() {
        //     widget.change();
        //   });
        //   return Future.value(false);
        // },

        onPopInvoked: (bool didPop) {
          if (didPop) {}
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: isExploreSearchClicked
              ? AppBar(
                  backgroundColor: Colors.white,
                  title: TextField(
                    controller: searchValue,
                    onChanged: (v) {
                      log("SearchValue $v");
                      if (v.isEmpty) {
                        setState(() {
                          allRoomCopy = location;
                        });
                      }
                      List<ChatRoom> tempList = allRoomCopy.where((element) {
                        log("element name ${element.name}");
                        return element.name!
                            .toLowerCase()
                            .startsWith(v.toLowerCase());
                      }).toList();
                      log("templist size ${tempList.length}");
                      setState(() {
                        allRoomCopy = tempList;
                      });
                      log("roomm lengrth ${allRoomCopy.length}");
                    },
                    decoration: InputDecoration(
                        hintText: 'Search rooms...', border: InputBorder.none),
                  ),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: RuntimeStorage.instance.PrimaryOrange),
                    onPressed: () {
                      setState(() {
                        isExploreSearchClicked = false;
                      });
                      // Handle search button tap
                    },
                  ),
                )
              : AppBar(
                  elevation: 0.5,
                  backgroundColor: Colors.white,
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      height: 32,
                      child: InkWell(
                          onTap: () {
                            // Navigator.pop(context);
                            // log("location list bool $showLocationList");

                            if (showLocationList) {
                              setState(() {
                                showLocationList = false;
                              });
                            } else {
                              setState(() {
                                widget.change();
                              });
                            }
                          },
                          child: SvgPicture.asset(
                              "assets/mingcute_arrow-up-fill.svg")),
                    ),
                  ),
                  leadingWidth: 40,
                  title: showLocationList == true
                      ? Text(
                          "$selectedLocationCategory chat room",
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 16,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : Text(
                          'Select ${widget.title == "Location" ? "Country" : widget.title}',
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 16,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  actions: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExploreSearchClicked = true;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Container(
                          decoration: BoxDecoration(),
                          child: SvgPicture.asset("assets/Vector.svg"),
                        ),
                      ),
                    ),
                  ],
                ),
          body: isExploreSearchClicked
              ? Column(
                  children:[
                    Padding(
                    padding: EdgeInsets.all(20),
                    child:
                    ListView.builder(
                      
                      itemCount: allRoomCopy.length,
                      itemBuilder: (ctx,index)
                      {
                        return RoomRow(allRoomCopy[index], ProChatrooms);
                      },
                    ),
                    // Column(
                    //   children: [
                    //     for (var c in allRoomCopy) RoomRow(c, ProChatrooms),
                    //   ],
                    // ),
                  ),
                  ]
                )
              : ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    getPage(height, width, subCategory, location, groupMessages,
                        ProChatrooms)
                  ],
                ),
        ));
  }

  RoomRow(ChatRoom r, ChatRoomsProvider ProChat) {
    return GestureDetector(
      onTap: () async {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(
                  "Join ${r.name} room"),
              actions: [
                TextButton(
                    onPressed: () async {
                      ProChat.updateChatroom(r);
                      setState(() {
                        chatElementItemSelected = !chatElementItemSelected;
                      });
                      // Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (ctx) => ChatRoomScreenChat(groupName: r)));
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isJoinedRoom', true);
                      await prefs.setString("JoinedRoomId", r.id.toString());
                      await prefs.setString("JoinedRoomName", r.name.toString());

                      RuntimeStorage.instance.selectedRoom = r;
                      widget.change();
                      Navigator.pop(context);
                    },
                    child: Text("Yes")),
                TextButton(
                    onPressed: () {
                      Navigator.pop(
                          context);
                      return;
                    },
                    child: Text("No"))
              ],
            ));


      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: [
              BoxShadow(
                color: Color(0xFFE6EAF7),
                blurRadius: 15,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          // width: MediaQuery.of(context).size.width-80,
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            horizontalTitleGap: 2,
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
            title: Text(
              r.name!,
              style: TextStyle(
                color: Color(0xFF303030),
                fontSize: 12,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
            leading: Container(
                width: 36,
                height: 36,
                decoration: new BoxDecoration(
                  // color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Image.asset("assets/Mumbai.png")),
            subtitle: Row(children: [
              Container(
                width: 81,
                height: 16,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: ShapeDecoration(
                  color: Color(0xFFEBFFEE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: ShapeDecoration(
                        color: Color(0xFF22BC3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${r.users?.length} Online',
                      style: TextStyle(
                        color: Color(0xFF667084),
                        fontSize: 8,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 6,
              ),
            ]),
            trailing: Container(
                width: 21,
                height: 21,
                child: SvgPicture.asset("assets/CaretRight.svg")),
          ),
        ),
      ),
    );
  }

  LocarionRoomRow(ChatRoom r, String category, ChatRoomsProvider ProChat) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text("Join ${r.name} Room"),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          ProChat.updateChatroom(r);

                          setState(() {
                            chatElementItemSelected = !chatElementItemSelected;
                          });
                          // Navigator.of(context).push(
                          //     MaterialPageRoute(builder: (ctx) => ChatRoomScreenChat(groupName: r)));
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('isJoinedRoom', true);
                          await prefs.setString(
                              "JoinedRoomId", r.id.toString());
                          await prefs.setString(
                              "JoinedRoomName", r.name.toString());

                          RuntimeStorage.instance.selectedRoom = r;
                          widget.change();
                          Navigator.pop(context);
                        },
                        child: Text("Yes")),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          return;
                        },
                        child: Text("No"))
                  ],
                ));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: [
              BoxShadow(
                color: Color(0xFFE6EAF7),
                blurRadius: 15,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          // width: MediaQuery.of(context).size.width-80,
          child: ListTile(
            contentPadding: EdgeInsets.all(12),
            horizontalTitleGap: 2,
            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
            title: Text(
              r.name!,
              style: TextStyle(
                color: Color(0xFF303030),
                fontSize: 12,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
            leading: Container(
                width: 36,
                height: 36,
                decoration: new BoxDecoration(
                  // color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Image.asset("assets/Mumbai.png")),
            subtitle: Row(children: [
              Container(
                width: 81,
                height: 16,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: ShapeDecoration(
                  color: Color(0xFFEBFFEE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: ShapeDecoration(
                        color: Color(0xFF22BC3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${r.users?.length} Online',
                      style: TextStyle(
                        color: Color(0xFF667084),
                        fontSize: 8,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 6,
              ),
            ]),
            trailing: Container(
                width: 21,
                height: 21,
                child: SvgPicture.asset("assets/CaretRight.svg")),
          ),
        ),
      ),
    );
  }

  LocationRow(List<ChatRoom> i, String Title) {
    log("inside location row");
    List<ChatRoom> separetedRoom = [];
    i.forEach((element) {
      if (element.category == Title) {
        separetedRoom.add(element);
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: ShapeDecoration(
          color: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          // shadows: [
          //   BoxShadow(
          //     color: Color(0xFFE6EAF7),
          //     blurRadius: 2,
          //     offset: Offset(0, 2),
          //     spreadRadius: 2,
          //   ),
          // ]
        ),
        child: ExpansionTileCard(
            elevation: 1.5,
            initialElevation: 1,
            leading: Container(
                width: 36,
                height: 36,
                decoration: new BoxDecoration(
                  // color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Image.asset("assets/Ind_Flag.png")),
            title: Text(
              Title,
              style: TextStyle(
                color: Color(0xFF303030),
                fontSize: 14,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w700,
                height: 0,
              ),
            ),
            subtitle: Text(
              "${separetedRoom.length} Chat Rooms",
              style: TextStyle(
                color: Color(0xFF707070),
                fontSize: 10,
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
            children: <Widget>[
              Divider(
                thickness: 1.0,
                height: 1.0,
                indent: 10,
                endIndent: 10,
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        // decoration: ShapeDecoration(
                        //   color: Colors.white,
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   shadows: [
                        //     BoxShadow(
                        //       color: Color(0xFFE6EAF7),
                        //       blurRadius: 15,
                        //       offset: Offset(0, 2),
                        //       spreadRadius: 0,
                        //     )
                        //   ],
                        // ),
                        // width: MediaQuery.of(context).size.width-80,
                        child: Column(
                          children: separetedRoom
                              .map((data) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Container(
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: Color(0xFFECEFFB),
                                            blurRadius: 8.90,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    content: Text(
                                                        "Join ${data.name} room"),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              chatElementItemSelected =
                                                                  !chatElementItemSelected;
                                                            });
                                                            // Navigator.of(context).push(
                                                            //     MaterialPageRoute(builder: (ctx) => ChatRoomScreenChat(groupName: r)));
                                                            SharedPreferences
                                                                prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                            await prefs.setBool(
                                                                'isJoinedRoom',
                                                                true);
                                                            await prefs.setString(
                                                                "JoinedRoomId",
                                                                data.id
                                                                    .toString());
                                                            await prefs.setString(
                                                                "JoinedRoomName",
                                                                data.name
                                                                    .toString());

                                                            RuntimeStorage
                                                                    .instance
                                                                    .selectedRoom =
                                                                data;
                                                            widget.change();
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text("Yes")),
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            return;
                                                          },
                                                          child: Text("No"))
                                                    ],
                                                  ));

                                          // Navigator.of(context).push(
                                          //     MaterialPageRoute(builder: (ctx) => ChatRoomScreenChat(groupName: data)));
                                        },
                                        contentPadding: EdgeInsets.all(12),
                                        horizontalTitleGap: 2,
                                        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
                                        title: Text(
                                          data.subCategory.toString(),
                                          style: TextStyle(
                                            color: Color(0xFF303030),
                                            fontSize: 12,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w700,
                                            height: 0,
                                          ),
                                        ),
                                        leading: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: new BoxDecoration(
                                              // color: Colors.orange,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.asset(
                                                "assets/Mumbai.png")),
                                        subtitle: Row(children: [
                                          Container(
                                            height: 16,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: ShapeDecoration(
                                              color: Color(0xFFEBFFEE),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: ShapeDecoration(
                                                    color: Color(0xFF22BC3D),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.50),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${data.users?.length} Online',
                                                  style: TextStyle(
                                                    color: Color(0xFF667084),
                                                    fontSize: 8,
                                                    fontFamily: 'Helvetica',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                        trailing: Container(
                                            width: 21,
                                            height: 21,
                                            child: SvgPicture.asset(
                                                "assets/CaretRight.svg")),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            selectedLocationCategory = Title;
                            showLocationList = true;
                          });
                          log("clicked");
                        },
                        child: Text(
                          'View More',
                          style: TextStyle(
                            color: Color(0xFF007FFF),
                            fontSize: 12,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ))
                  ],
                ),
              )
            ]),
      ),
    );
  }

  getPage(height, width, subCategory, List<ChatRoom> location, groupMessage,
      ChatRoomsProvider ProChatRoom) {
    print(subCategory);

    switch (_page) {
      ///firstPage
      case 0:
        {
          if (widget.title == "Location")

          ///by location screen
          {
            return showLocationList
                ? Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var c in locationRoom)
                            c.category == selectedLocationCategory
                                ? LocarionRoomRow(c,
                                    selectedLocationCategory ?? "", ProChatRoom)
                                : SizedBox(),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        for (String i in locationCategories)
                          LocationRow(locationRoom, i)
                      ],
                    ),
                  );
          }

          ///interest or trending
          else {
            // location.forEach((element) {log("elementt location${element}");});
            // var chatElement = location
            //     .where((element) => (
            //
            //     element.superCategory == widget.title))
            //     .toList();
            chatElement = location.toList();
            return Container(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      for (var c in chatElement) RoomRow(c, ProChatRoom),
                    ],
                  ),
                ),
              ),
            );
          }
          // setState(() {
          //   _page = 2;
          // });
        }
        break;
      case 1:
        return Container(
          height: height - 200,
          child: Row(
            children: [
              Container(
                width: width,
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: subCategory.length,
                    itemBuilder: (ctx, i) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _page = 2;
                            _selected2 = subCategory[i].subCategory;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40)),
                          margin:
                              // i % 2 != 0
                              // ? EdgeInsets.only(top: 70)
                              // :
                              EdgeInsets.all(10),
                          height: 170,
                          width: 100,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40)),
                                height: 170,
                                child: Image.network(
                                  subCategory[i].image,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              Center(
                                child: Container(
                                  height: 30,
                                  width: 170,
                                  color: Colors.black.withOpacity(.5),
                                  child: Center(
                                    child: Text(
                                      subCategory[i].subCategory,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
        );
      case 2:
        var chatElement;
        if (widget.title == "Location")
          chatElement = location
              .where((element) => (element.subCategory == _selected2 &&
                  element.category == _selected1 &&
                  element.superCategory == widget.title))
              .toList();
        else
          chatElement = location
              .where((element) => (element.superCategory == widget.title))
              .toList();

        return Container(
          height: height - 100,
          child: Column(
            children: [
              Container(
                height: 70,
                padding: EdgeInsets.all(8),
                child: Stack(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          hintText: "Search case 2",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: chatElementItemSelected
                                      ? Colors.orange
                                      : Colors.black))),
                    ),
                    Positioned(
                        right: 20, bottom: 15, child: Icon(Icons.search)),
                  ],
                ),
              ),
              Container(
                height: height - 70,
                child: ListView.builder(
                    itemCount: chatElement.length,
                    itemBuilder: (ctx, i) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            chatElementItemSelected = !chatElementItemSelected;
                          });

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ChatRoomScreenChat(
                                  changeTab: () {
                                    widget.ChangeTab();
                                  },
                                  groupName: chatElement[i])));
                        },
                        child: Container(
                          height: 70,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: chatElementItemSelected
                                    ? Colors.orange
                                    : Colors.black),
                          ),
                          child: ListTile(
                            leading: Container(
                                height: 40,
                                child: Image.asset("assets/Group 639.png")),
                            title: Text(
                              chatElement[i].privateName,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              chatElement[i].usersList.length.toString(),
                              style: TextStyle(color: Colors.grey),
                            ),
                            trailing: GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.all(8),
                                width: 100,
                                // height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.orange.shade100),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Join Now"),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.orange,
                                    )
                                  ],
                                ),
                              ),
                            ),
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
}
