import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Models/Notification.dart' as N;
import 'package:koram_app/Models/User.dart';
import 'package:provider/provider.dart';

import '../Helper/Helper.dart';
import '../Screens/NewProfileScreen.dart';
import 'Badge.dart';
import 'BottomSheetContent.dart';

class AppBarWidget extends StatefulWidget {
  const AppBarWidget({super.key});

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<N.Notification> notification =
        Provider.of<N.Notifications>(context).notification;
    UsersProviderClass UserPro =
        Provider.of<UsersProviderClass>(context, listen: true);
    UserDetail? loggedUser = UserPro.LoggedUser;
    return AppBar(
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
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(),
          child: SvgPicture.asset("assets/Vector.svg"),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
                context: context,
                elevation: 3,
                isScrollControlled: true,
                builder: (ctx) => NotificationBottomSheet());
          },
          child: BadgeWidget(
              child: Container(
                  margin: EdgeInsets.all(8),
                  height: 30,
                  child: SvgPicture.asset("assets/notify bell.svg")),
              value: notification.length),
        ),
        SizedBox(
          width: 10,
        ),
        
        GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (ctx) => NewProfileScreen()));
          },
          child: Container(
            width: 31.94,
            height: 31.94,
            decoration: ShapeDecoration(
              image: loggedUser!.publicProfilePicUrl != ""
                  ? DecorationImage(
                      image: NetworkImage(loggedUser.publicProfilePicUrl!),
                      fit: BoxFit.contain,
                    )
                  : DecorationImage(
                      image: AssetImage("assets/profile.png"),
                      fit: BoxFit.contain),
              shape: CircleBorder(),
            ),
          ),
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
    );
  }
}
