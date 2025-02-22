import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:http/http.dart' as http;

import '../Helper/CommonDatingWidgets.dart';
import '../Helper/Helper.dart';
import 'DatingEducation.dart';

class DatingUserHeight extends StatefulWidget {
  const DatingUserHeight({key});

  @override
  State<DatingUserHeight> createState() => _DatingUserHeightState();
}

class _DatingUserHeightState extends State<DatingUserHeight> {
  List<String> HeightList = ["Not Selected"];


  var SelectedHeight;
  @override
  void initState() {
    SelectedHeight = "Not Selected";
    // TODO: implement initState
    for (int i = 91; i <= 250; i++) {
      if(i==91){
        HeightList.add("< 91");
      }else
      {
        HeightList.add(i.toString());

      }
    }
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
                  Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 14.0),
                          child: SizedBox(
                            width: 258,
                            child: Text(
                              'What is your height?',
                              style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 24,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )),
                    ],
                  ),

                  Expanded(
                    child: SizedBox(
                      height: 30,
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: Container(
                      height: 250,
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
                        child:      SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              for(String i in HeightList)
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      SelectedHeight=i;

                                    });
                                  },
                                  child: Container(
                                    width: 348,
                                    height: 60,
                                    decoration: ShapeDecoration(
                                      color:SelectedHeight==i? Color(0xFFFFEADC):Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),

                                    child: Center(child: Text(
                                     i=="Not Selected"?'$i': '$i cm',
                                      style: TextStyle(
                                        color: SelectedHeight==i?Color(0xFFFF6701):Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.w700,
                                        height: 0,
                                      ),
                                    )),
                                  ),
                                )

                            ],),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: GestureDetector(
              onTap: ()async {

                if(SelectedHeight=="Not Selected")
                {
                  CommonDatingWidgets().heightErrorDialog(context);
                }else
                {
                  String uploadUrl = G.HOST + "api/v1/insertDatingDetails";
                  var response =
                  await http.post(Uri.parse(uploadUrl),body: {"phone_number": G.userPhoneNumber,"insertType":"height","height":SelectedHeight});
                  if (response.statusCode == 200) {

                    log("inside success of edit ");

                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DatingEducation();
                    }));
                  } else {
                    await CommonDatingWidgets().errorDialog(context);
                  }

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
              )),
        ),
      ),
    );
  }
}
