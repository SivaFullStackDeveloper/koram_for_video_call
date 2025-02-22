import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:http/http.dart' as http;

import '../Helper/Helper.dart';
import 'DatingUserGender.dart';

class DatingBirthDay extends StatefulWidget {
  const DatingBirthDay({key});

  @override
  State<DatingBirthDay> createState() => _DatingBirthDayState();
}

class _DatingBirthDayState extends State<DatingBirthDay> {
  var selectedDay;
  var selectedMonth;
  var selectedYear;

   var age;
  void calculateAge() {

    DateTime birthdate = DateTime(selectedYear, selectedMonth, selectedDay);

    Duration difference = DateTime.now().difference(birthdate);
     age = (difference.inDays / 365).floor();
       // if(age<18)
       // {
       //   showDialog(
       //     context: context,
       //     builder: (BuildContext context) {
       //       return AlertDialog(
       //         title: Text(
       //           'You’re $age',
       //           style: TextStyle(
       //             color: Color(0xFF303030),
       //             fontSize: 24,
       //             fontFamily: 'Helvetica',
       //             fontWeight: FontWeight.w700,
       //             height: 0,
       //           ),
       //         ),
       //         content: Text(
       //           'Sorry, you must be at least 18 years old to use this dating app',
       //           textAlign: TextAlign.center,
       //           style: TextStyle(
       //             color: Color(0xFF707070),
       //             fontSize: 14,
       //             fontFamily: 'Helvetica',
       //             fontWeight: FontWeight.w400,
       //             height: 0,
       //           ),
       //         ),
       //         actions: [
       //           TextButton(
       //             onPressed: () {
       //               Navigator.of(context).pop(); // Close the dialog
       //             },
       //             child: Text(
       //               'Cancel',
       //               textAlign: TextAlign.center,
       //               style: TextStyle(
       //                 color: Color(0xFFFF6701),
       //                 fontSize: 14,
       //                 fontFamily: 'Helvetica',
       //                 fontWeight: FontWeight.w400,
       //                 height: 0,
       //               ),
       //             ),
       //           ),
       //           TextButton(
       //             onPressed: () {
       //               Navigator.of(context).pop(); // Close the dialog
       //             },
       //             child: Text(
       //               'Confirm',
       //               textAlign: TextAlign.center,
       //               style: TextStyle(
       //                 color: Color(0xFFFF6701),
       //                 fontSize: 14,
       //                 fontFamily: 'Helvetica',
       //                 fontWeight: FontWeight.w400,
       //                 height: 0,
       //               ),
       //             ),
       //           ),
       //         ],
       //       );
       //     },
       //   );
       // }
         showDialog(
           
           context: context,
           builder: (BuildContext outercontext) {

             return AlertDialog(
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
               title: Row(mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text(
                     'You’re $age',
                     style: TextStyle(
                       color: Color(0xFF303030),
                       fontSize: 24,
                       fontFamily: 'Helvetica',
                       fontWeight: FontWeight.w700,
                     ),
                   ),
                 ],
               ),
               content: Text(
                 'Make sure this is your correct age as you can’t change this later',
                 textAlign: TextAlign.center,
                 style: TextStyle(
                   color: Color(0xFF707070),
                   fontSize: 14,
                   fontFamily: 'Helvetica',
                   fontWeight: FontWeight.w400,
                   height: 0,
                 ),
               ),
               actions: [
                 ButtonBar(
                   alignment: MainAxisAlignment.spaceBetween,
                   children: [
                   TextButton(
                     onPressed: () {
                       Navigator.of(outercontext).pop(); // Close the dialog
                     },
                     child: Text(
                       'Cancel',
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         color: Color(0xFFFF6701),
                         fontSize: 14,
                         fontFamily: 'Helvetica',
                         fontWeight: FontWeight.w400,
                         height: 0,
                       ),
                     ),
                   ),
                   TextButton(
                     onPressed: () async {
                       Navigator.of(outercontext).pop(); // Close the dialog
                       bool isApiUpdated= await callApiUpdate();
                       if(isApiUpdated)
                       {
                         Navigator.of(context)
                             .push(MaterialPageRoute(builder: (context) {
                           return DatingGender();
                         }));
                       }else
                       {
                         showDialog(
                           context: context,
                           builder: (BuildContext context) {
                             return AlertDialog(
                               title: Text(
                                 'Sorry There was an Error',
                                 style: TextStyle(
                                   color: Color(0xFF303030),
                                   fontSize: 24,
                                   fontFamily: 'Helvetica',
                                   fontWeight: FontWeight.w700,
                                   height: 0,
                                 ),
                               ),
                               content: Text(
                                 'please Try again later',
                                 textAlign: TextAlign.center,
                                 style: TextStyle(
                                   color: Color(0xFF707070),
                                   fontSize: 14,
                                   fontFamily: 'Helvetica',
                                   fontWeight: FontWeight.w400,
                                   height: 0,
                                 ),
                               ),
                               actions: [
                                 TextButton(
                                   onPressed: () {
                                     Navigator.of(context).pop(); // Close the dialog
                                   },
                                   child: Text(
                                     'Cancel',
                                     textAlign: TextAlign.center,
                                     style: TextStyle(
                                       color: Color(0xFFFF6701),
                                       fontSize: 14,
                                       fontFamily: 'Helvetica',
                                       fontWeight: FontWeight.w400,
                                       height: 0,
                                     ),
                                   ),
                                 ),
                               ],
                             );
                           },
                         );
                       }


                     },
                     child: Text(
                       'Confirm',
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         color: Color(0xFFFF6701),
                         fontSize: 14,
                         fontFamily: 'Helvetica',
                         fontWeight: FontWeight.w400,
                         height: 0,
                       ),
                     ),
                   ),
                 ],)

               ],
             );
           },
         );

  }

   Future<bool> callApiUpdate()async{

    String uploadUrl = G.HOST + "api/v1/insertDatingDetails";
    var response =
    await http.post(Uri.parse(uploadUrl),body: {"phone_number": G.userPhoneNumber,"insertType":"dob","dob":DateTime(selectedYear, selectedMonth, selectedDay).toString()});


        log("response of insrert ${jsonDecode(response.body)}");
    if (response.statusCode == 200) {
      log("inside success of edit ");
      return true;
    } else {
      return false;
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    selectedDay=1;
    selectedMonth=1;
    selectedYear=DateTime.now().year-19;
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
                              'When’s your birthday',
                              style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 24,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                          )

                      ),
                    ],
                  ),
                  Text(
                    'We only show age to potential matches, not your birthday',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 14,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  SizedBox(height: 46,),
                  Row(

                    children: [
                      Container(
                        width: 60,
                        height: 100,

                        child: Column(
                             mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(
                            'Day',
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          SizedBox(height: 12,),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: Colors.black.withOpacity(0.07999999821186066),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child:

                            Center(
                              child: DropdownButtonHideUnderline(

                                child: DropdownButton<int>(
                                  iconSize: 0,
                                  focusColor: RuntimeStorage().PrimaryOrange,
                                  // padding: EdgeInsets.only(left: 15),
                                  alignment: Alignment.center,
                                  style: TextStyle(
                                    color: Color(0xFF303030),
                                    fontSize: 14,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.w700,

                                  ),

                                  value: selectedDay,
                                  items: List.generate(31, (index) => DropdownMenuItem<int>(

                                    value: index + 1,
                                    child: Center(
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                          color: Color(0xFF303030),
                                          fontSize: 14,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  )),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDay = value!;
                                    });
                                  },
                                ),
                              ),
                            ),


                          )

                        ]),
                      ),
                      SizedBox(width:8,),
                      Container(
                        width: 60,
                        height: 100,

                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Month',
                                style: TextStyle(
                                  color: Color(0xFF707070),
                                  fontSize: 14,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: Colors.black.withOpacity(0.07999999821186066),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child:

                                Center(
                                  child: DropdownButtonHideUnderline(

                                    child: DropdownButton<int>(
                                      iconSize: 0,
                                      focusColor: RuntimeStorage().PrimaryOrange,
                                      // padding: EdgeInsets.only(left: 15),
                                      alignment: Alignment.center,
                                      style: TextStyle(
                                        color: Color(0xFF303030),
                                        fontSize: 14,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.w700,

                                      ),

                                      value: selectedMonth,
                                      items: List.generate(12, (index) => DropdownMenuItem<int>(

                                        value: index + 1,
                                        child: Center(
                                          child: Text(
                                            (index + 1).toString(),
                                            style: TextStyle(
                                              color: Color(0xFF303030),
                                              fontSize: 14,
                                              fontFamily: 'Helvetica',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      )),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedMonth = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),


                              )

                            ]),
                      ),
                      SizedBox(width: 8,),
                      Container(
                        width: 60,
                        height: 100,

                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Year',
                                style: TextStyle(
                                  color: Color(0xFF707070),
                                  fontSize: 14,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: Colors.black.withOpacity(0.07999999821186066),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child:

                                Center(
                                  child: DropdownButtonHideUnderline(

                                    child: DropdownButton<int>(
                                      iconSize: 0,
                                      focusColor: RuntimeStorage().PrimaryOrange,
                                      // padding: EdgeInsets.only(left: 15),
                                      alignment: Alignment.center,
                                      style: TextStyle(
                                        color: Color(0xFF303030),
                                        fontSize: 14,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.w700,

                                      ),

                                      value: selectedYear,
                                      items:  List.generate(100, (index) {
                                        int year = (DateTime.now().year-19) - index;
                                        return DropdownMenuItem<int>(
                                          value: year,
                                          child: Center(
                                            child: Text(
                                              year.toString(),
                                              style: TextStyle(
                                                color: Color(0xFF303030),
                                                fontSize: 14,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedYear = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),


                              )

                            ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomSheet:  Padding(
          padding: const EdgeInsets.only(left: 20, right: 20,bottom: 10),
          child: GestureDetector(
              onTap: () {
                calculateAge();

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
