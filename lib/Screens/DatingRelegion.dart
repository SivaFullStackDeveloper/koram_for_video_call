import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Helper/CommonDatingWidgets.dart';
import '../Helper/Helper.dart';
import '../Helper/RuntimeStorage.dart';
import 'DatingScreen.dart';
import 'HomeScreen.dart';

class DatingRelegion extends StatefulWidget {
  const DatingRelegion({key});

  @override
  State<DatingRelegion> createState() => _DatingRelegionState();
}

class _DatingRelegionState extends State<DatingRelegion> {

  List<String> RelegionList = [
      "Hindu",
      "Muslim",
      "Christian",
      "Sikh",
      "Buddhist",
      "Jain",
      "Zoroastrian",
      "Jewish",
      "Bahá'í",
      "Atheist",
      "Agnostic",
      "Spiritual but not religious",
      "Interfaith",
      "Pagan",
      "Wiccan",
      "Unitarian Universalist",
      "Humanist",
      "Other"
  ];
  var SelectedRelegion;
  @override
  void initState() {
    SelectedRelegion =  "Hindu";
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: width,
          height: height,
          child: Container(
            height: height,
            width: width,
            // color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: SvgPicture.asset("assets/CaretLeft.svg"),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                        ),
                        Text(
                          'Koram',
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 23.96,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 14.0),
                      child: Text(
                        'Do you identify with a religion?',
                        style: TextStyle(
                          color: Color(0xFF303030),
                          fontSize: 24,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w700,
                        ),
                      )

                  ),

                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height/1.5,
                    child: ShaderMask(
                      shaderCallback: (Rect rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [RuntimeStorage().PrimaryOrange, Colors.transparent, Colors.transparent, RuntimeStorage().PrimaryOrange],
                          stops: [0.0, 0.0, 0.5, 1.0], // 10% purple, 80% transparent, 10% purple
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstOut,

                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(

                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (String i in RelegionList)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      SelectedRelegion = i;
                                    });
                                  },
                                  child: Container(
                                    // width: MediaQuery.of(context).size.width/4,
                                    height: 60,
                                    width: 348,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: Color(0xFFF6F6F6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    // decoration: ShapeDecoration(
                                    //   color: SelectedDrinkOption==i?Color(0xFFFFEADC):Color(0xFFF6F6F6),
                                    //
                                    //   shape: RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.circular(16),
                                    //   ),
                                    // ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.only(left: 24.0, right: 24),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$i',
                                            style: TextStyle(
                                              color: SelectedRelegion == i
                                                  ? Color(0xFFFF6701)
                                                  : Colors.black,
                                              fontSize: 14,
                                              fontFamily: 'Helvetica',
                                              fontWeight: FontWeight.w400,
                                              height: 0,
                                            ),
                                          ),
                                          Expanded(child: SizedBox()),
                                          Radio(
                                              value: i,
                                              groupValue: SelectedRelegion,
                                              onChanged: (e) {
                                                setState(() {
                                                  SelectedRelegion = i;
                                                });
                                              })
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: GestureDetector(
              onTap: () async{
                // Navigator.of(context)
                //     .push(MaterialPageRoute(builder: (context) {
                //   return datingScreen();
                // }));

                String uploadUrl = G.HOST + "api/v1/insertDatingDetails";
                var response =
                await http.post(Uri.parse(uploadUrl),body: {"phone_number": G.userPhoneNumber,"insertType":"relegion","relegion":SelectedRelegion});
                if (response.statusCode == 200) {

                  log("inside success of edit ");

                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  await prefs.setBool('isDatingRegistered',true);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(justRegisteredDate: true,)),
                        (route) => false,
                  );
                } else {
                  await CommonDatingWidgets().errorDialog(context);
                }

                },
              child: Container(
                width: 350,
                height: 54,
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                decoration: ShapeDecoration(
                  color: Color(0xFFFF6701),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              )


          ),
        ),
      ),
    );
  }
}
