import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koram_app/Helper/color.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Screens/HomeScreen.dart';

import '../Models/User.dart';
import 'PrivateProfileScreen.dart';

class VerifiedSuccessfully extends StatefulWidget {
  final bool goToHome;
  VerifiedSuccessfully({key, required this.goToHome});

  @override
  State<VerifiedSuccessfully> createState() => _VerifiedSuccessfullyState();
}

class _VerifiedSuccessfullyState extends State<VerifiedSuccessfully> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 1), () {
      // setState(() {
      //   _page = 2;
      // });
      // navigateAnimation(2,true);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return widget.goToHome
            ? HomeScreen()
            : PrivateProfileScreen(
                isFromHome: false,
                userData: UserDetail(),
              );
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        log("prevented back");
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return widget.goToHome
                  ? HomeScreen()
                  : PrivateProfileScreen(
                      isFromHome: false, userData: UserDetail());
            }));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(child: SizedBox()),
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/VerifiedSuccessfully.svg",
                            color: backendColor,
                          ),
                          Icon(
                            Icons.check,
                            size: 100,
                            color: Colors.white,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 26,
                      ),
                      Text(
                        'Verified Successfully',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF303030),
                          fontSize: 24,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w700,
                          height: 0,
                        ),
                      )
                    ],
                  ),
                  Expanded(child: SizedBox())
                ],
              ),
            ],
          ),
        )),
      ),
    );
  }
}
