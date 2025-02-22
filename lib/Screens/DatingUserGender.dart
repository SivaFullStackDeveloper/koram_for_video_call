import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import '../Helper/CommonDatingWidgets.dart';
import '../Helper/Helper.dart';
import 'DatingHopingToFind.dart';

class DatingGender extends StatefulWidget {
  const DatingGender({key});

  @override
  State<DatingGender> createState() => _DatingGenderState();
}

class _DatingGenderState extends State<DatingGender> {
  List<String> GenderList=["Male","Female","Other"];
  var SelectedGender;
  @override
  void initState() {
    SelectedGender="Male";
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
                          onTap: (){
                            Navigator.pop(context);
                          },

                        ),
                        SizedBox(width: MediaQuery.of(context).size.width/4,),
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
                          child:
                          SizedBox(
                            width: 258,
                            child: Text(
                              'What’s your gender',
                              style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 24,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )

                      ),
                    ],
                  ),SizedBox(height: 4,),
                  Text(
                    'Pick which best describes you.',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 14,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  SizedBox(height: 46,),
                  Text(
                    'Gender',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 14,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  SizedBox(height: 12,),
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
              for(String i in GenderList)
                      GestureDetector(
                        onTap: (){
                          setState(() {
                             SelectedGender=i;
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width/4,
                          height: 60,
                          decoration: ShapeDecoration(
                            color: SelectedGender==i?Color(0xFFFFEADC):Color(0xFFF6F6F6),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '$i',
                                style: TextStyle(
                                  color: SelectedGender==i?Color(0xFFFF6701):Colors.black,
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


                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        bottomSheet:  Padding(
          padding: const EdgeInsets.only(left: 20, right: 20,bottom: 10),
          child: GestureDetector(
              onTap: ()async {
                String uploadUrl = G.HOST + "api/v1/insertDatingDetails";
                var response =
                    await http.post(Uri.parse(uploadUrl),body: {"phone_number": G.userPhoneNumber,"insertType":"gender","gender":SelectedGender});

                if (response.statusCode == 200) {

                  log("inside success of edit ");

                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return DatingHopingToFind();
                  }));
                } else {
                   await CommonDatingWidgets().errorDialog(context);
                }

              },
              child:
              Container(
                width: 350,
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
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

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     Expanded(
            //       child: Padding(
            //         padding: const EdgeInsets.only(bottom: 20.0),
            //         child: Container(
            //           height: 54,
            //           padding: const EdgeInsets.symmetric(
            //               horizontal: 10, vertical: 18),
            //           decoration: ShapeDecoration(
            //             color: Color(0xFFFF6701),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(12),
            //             ),
            //           ),
            //           child: Text(
            //             'Next',
            //             textAlign: TextAlign.center,
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 16,
            //               fontFamily: 'Helvetica',
            //               fontWeight: FontWeight.w700,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }
}
