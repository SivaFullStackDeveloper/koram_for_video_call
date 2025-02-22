import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Screens/LoginScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/Helper.dart';
import '../Models/MenuOption.dart';
import '../Models/NewUserModel.dart';
import '../Models/User.dart';
import 'PrivateProfileScreen.dart';
import 'PublicProfileScreen.dart';

class NewProfileScreen extends StatefulWidget {
  final Future<dynamic>? callbackToinitialize;
  NewProfileScreen({key, this.callbackToinitialize});

  @override
  State<NewProfileScreen> createState() => _NewProfileScreenState();
}

class _NewProfileScreenState extends State<NewProfileScreen> {
  File? profileImage;
  UserDetail userData = UserDetail();
  bool isSearchClicked = false;
  var searchValue = TextEditingController();
  List<MenuOption> tempList = [];
  List<MenuOption> MenuList = [];
  List<MenuOption> MenuListCopy = [];
  FocusNode searchFocusNode = FocusNode();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Perform initialization that requires context here.
    // Initialize your MenuList and MenuListCopy here, if they depend on context.
    MenuList = [
      MenuOption(
          title: "Public Profile",
          description: "Change Name, Profile Photo",
          imgURl: "assets/user.svg",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => PublicProfileScreen(
                      isFromHome: true,
                      userData: userData,
                    )));
          }),
      MenuOption(
          title: "Private Profile",
          description: "Change Name, Profile Photo",
          imgURl: "assets/user.svg",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => PrivateProfileScreen(
                      isFromHome: true,
                      userData: userData,
                    )));
          }),
      MenuOption(title: "Privacy", description: "", imgURl: "assets/lock.svg"),
      MenuOption(
          title: "Starred Messages",
          description: "",
          imgURl: "assets/star.svg"),
      MenuOption(
          title: "Payments",
          description: "",
          imgURl: "assets/heroicons_currency-rupee.svg"),
      MenuOption(
          title: "Linked devices",
          description: "",
          imgURl: "assets/airplay.svg"),
      MenuOption(title: "Account", description: "", imgURl: "assets/key.svg"),
      MenuOption(
          title: "Chats", description: "", imgURl: "assets/message-square.svg"),
      MenuOption(
          title: "Notification", description: "", imgURl: "assets/bell.svg"),
      MenuOption(
          title: "App Language", description: "", imgURl: "assets/globe.svg"),
      MenuOption(
          title: "Help", description: "", imgURl: "assets/help-circle.svg"),
      MenuOption(
          title: "Storage and Data",
          description: "",
          imgURl: "assets/database.svg"),
      MenuOption(
          title: "Invite Friends",
          description: "",
          imgURl: "assets/user-plus.svg"),
      MenuOption(
          title: 'Logout',
          description: "",
          imgURl: "assets/log-out.svg",
          onTap: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            setState(() {
              prefs.setString("userId", "");
              prefs.setBool('logedIn', false);
              G.userPhoneNumber = "";
              G.logedIn = false;
            });
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => LoginScreen(
                      ispoped: false,
                    )));
          })
    ];
    MenuListCopy = List.from(MenuList);
  }

  @override
  Widget build(BuildContext context) {
    UsersProviderClass UserPro =
        Provider.of<UsersProviderClass>(context, listen: true);
    UserDetail? loggedUser=UserPro.LoggedUser;
    userData=loggedUser!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isSearchClicked
          ? AppBar(
              backgroundColor: Colors.white,
              title: TextField(
                enabled: true,
                autofocus: true,
                controller: searchValue,
                focusNode: searchFocusNode,
                onChanged: (v) {
                  log("onchanged executed $v");
                  if (v.isEmpty) {
                    setState(() {
                      MenuList = MenuListCopy;
                    });
                  }
                  tempList = MenuListCopy.where((element) {
                    return element.title
                        .toLowerCase()
                        .startsWith(v.toLowerCase());
                  }).toList();

                  setState(() {
                    MenuList = tempList;
                    log("Templist  in setstate ${tempList.length}");
                  });
                },
                decoration: InputDecoration(
                    hintText: 'Search...', border: InputBorder.none),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: RuntimeStorage.instance.PrimaryOrange),
                onPressed: () {
                  setState(() {
                    isSearchClicked = false;
                  });
                  // Handle search button tap
                },
              ),
            )
          : AppBar(
              elevation: 0.5,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  height: 32,
                  child: InkWell(
                      onTap: () {
                        if (widget.callbackToinitialize != null) {
                          log("callback from newprofile view ");
                          widget.callbackToinitialize!;
                        }
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(
                          "assets/mingcute_arrow-up-fill.svg")),
                ),
              ),
              leadingWidth: 40,
              backgroundColor: Colors.white,
              title: Text(
                'You',
                style: TextStyle(
                  color: Color(0xFF303030),
                  fontSize: 16,
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    if (isSearchClicked) {
                      // When search is clicked, focus on the TextField
                      FocusScope.of(context).requestFocus(searchFocusNode);
                    }
                    setState(() {
                      isSearchClicked = !isSearchClicked;
                    });
                  },
                  child: Container(
                    // width: 22,
                    // height: 22,
                    decoration: BoxDecoration(),
                    child:
                        Container(child: SvgPicture.asset("assets/Vector.svg")),
                  ),
                ),
                const SizedBox(width: 15),
                // SvgPicture.asset("assets/more-vertical.svg"),
                // SizedBox(width: 15.11),
              ],
            ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 24, 0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 87,
                    height: 87,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 6.21,
                          top: 6.21,
                          child: Container(
                            width: 74.57,
                            height: 74.57,

                            child:  G.loggedinUser.privateProfilePicUrl != null
                                ?

                            ClipOval(
                              child: CachedNetworkImage(
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                progressIndicatorBuilder:
                                    (context, url, progress) =>
                                    Center(
                                      child:
                                      CircularProgressIndicator(
                                        value: progress.progress,
                                      ),
                                    ),
                                imageUrl: G.HOST +
                                    "api/v1/images/" +
                                    loggedUser
                                        !.privateProfilePicUrl!,
                              ),
                            )
                            // CachedNetworkImage(imageUrl:  G.HOST +
                            //     "api/v1/images/" +
                            //     G.loggedinUser.privateProfilePicUrl!,
                            //         filterQuality: FilterQuality.low,)
                                : CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/profile.png"),
                                    radius: 60,
                                  ),

                            // widget.loggedUser.userDetail!.publicProfilePicUrl != ""
                            //     ? Image.network(G.HOST +
                            //         "api/v1/images/" +
                            //     widget.loggedUser.userDetail!.publicProfilePicUrl!)
                            //     : Image.asset("assets/profile.png"),
                          ),
                        ),
                        Positioned(
                          left: 56.13,
                          top: 56.13,
                          child: Container(
                            width: 24.56,
                            height: 24.56,
                            decoration: ShapeDecoration(
                              color: Color(0xFFFF6701),
                              shape: OvalBorder(),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 61.74,
                          top: 61.74,
                          child: Container(
                              width: 14.03,
                              height: 14.03,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: SvgPicture.asset(
                                  "assets/carbon_qr-code.svg")),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${loggedUser?.privateName??""}',
                        style: TextStyle(
                          color: Color(0xFF303030),
                          fontSize: 16,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        width: 200,
                        height: 14,
                        child: AutoSizeText(
                          'Currently there is no option of adding status what should i do?',
                          style: TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 12,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              for (MenuOption m in MenuList)
                MenuOptionWidget(
                    m.imgURl, m.title, m.description, m.onTap ?? () {}),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  MenuOptionWidget(
      String imgUrl, String Title, String Description, Function onTapFunc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        highlightColor:
            Colors.transparent, // Make the highlight color transparent
        overlayColor: WidgetStateColor.resolveWith(
            (states) => Colors.deepOrangeAccent.shade100.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          onTapFunc();
        },
        child: Row(
          children: [
            Container(
                width: 20,
                height: 20,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(),
                child: SvgPicture.asset(imgUrl)),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Title,
                  style: TextStyle(
                    color: Color(0xFF303030),
                    fontSize: 14,
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.w700,
                    height: 0,
                  ),
                ),
                Text(
                  Description,
                  style: TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 12,
                    fontFamily: 'Helvetica',
                    fontWeight: FontWeight.w400,
                    height: 0,
                  ),
                )
              ],
            ),
            Expanded(child: SizedBox()),
            SvgPicture.asset("assets/chevron-right.svg")
          ],
        ),
      ),
    );
  }
}
