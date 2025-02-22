// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';

class ChatRoomCard extends StatelessWidget {
  final String title;
  final String image;
  final Color color;
  final Function change;
  final int userCount;

  const ChatRoomCard(
      {required this.image,
      required this.userCount,
      required this.title,
      required this.color,
      required this.change});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 6, top: 6),
      child: GestureDetector(
        onTap: () {
          change();
        },
        child: Container(
          // width: MediaQuery.of(context).size.width/1,
          height: MediaQuery.of(context).size.height/6.2,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            shadows: [
              BoxShadow(
                color: Color(0xFFE6EAF7),
                blurRadius: 10,
                offset: Offset(0, 5),
                spreadRadius: 5,
              )
            ],
          ),

          // decoration:
          //     BoxDecoration(borderRadius: BorderRadius.circular(20), color: color),
          // height: height * .22,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 6,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 17, 0, 12),
                          child:
                          Row(children: [
                            Container(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Color(0xFF303030),
                                  fontSize: 18,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              width: 88,
                            ),

                            Container(

                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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
                                    '${userCount} Online',
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
                            // Container(
                            //   width: 91,
                            //   height: 16,
                            //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            //   decoration: ShapeDecoration(
                            //     color: Color(0xFFF5F4F4),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(50),
                            //     ),
                            //   ),
                            //   child: Row(
                            //     mainAxisSize: MainAxisSize.min,
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     crossAxisAlignment: CrossAxisAlignment.center,
                            //     children: [
                            //       Container(
                            //         width: 8,
                            //         height: 8,
                            //         decoration: ShapeDecoration(
                            //           color: Color(0xFF667084),
                            //           shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(5.50),
                            //           ),
                            //         ),
                            //       ),
                            //       const SizedBox(width: 4),
                            //       Text(
                            //         '200,452 Member',
                            //         style: TextStyle(
                            //           color: Color(0xFF667084),
                            //           fontSize: 8,
                            //           fontFamily: 'Helvetica',
                            //           fontWeight: FontWeight.w400,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // )
                          ]),
                        ),
                        // Text(
                        //   "More than 2M Joined.",
                        //   style: TextStyle(color: Colors.yellow),
                        // ),
                      ],
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(
                        'Now you have the ability to engage in location-based conversations.',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 10,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: (){
                        change();
                      },
                      child: Container(
                        child: Column(
                          children: [

                            Text(
                              'Explore Now',
                              style: TextStyle(

                                color: Color(0xFFFF6701),
                                fontSize: 10,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(top:2.0),
                              child: Container( width:55,child: Divider(height: 2,color: RuntimeStorage().PrimaryOrange,thickness: 1)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () {
                    //         change();
                    //       },
                    //       child: Container(
                    //         // height: 40,
                    //         // width: 100,
                    //         // decoration: BoxDecoration(
                    //         //     borderRadius: BorderRadius.circular(20),
                    //         //     color: Colors.white),
                    //         width: 61,
                    //         height: 17,
                    //         padding: const EdgeInsets.symmetric(vertical: 3),
                    //         decoration: BoxDecoration(
                    //           // border: Border(
                    //           //   left: BorderSide(
                    //           //     width: 0,
                    //           //     strokeAlign: BorderSide.strokeAlignOutside,
                    //           //     color: Color(0xFFFF6701),
                    //           //   ),
                    //           //   top: BorderSide(
                    //           //     width: 0,
                    //           //     strokeAlign: BorderSide.strokeAlignOutside,
                    //           //     color: Color(0xFFFF6701),
                    //           //   ),
                    //           //   right: BorderSide(
                    //           //     width: 0,
                    //           //     strokeAlign: BorderSide.strokeAlignOutside,
                    //           //     color: Color(0xFFFF6701),
                    //           //   ),
                    //           //   bottom: BorderSide(
                    //           //     width: 1,
                    //           //     strokeAlign: BorderSide.strokeAlignOutside,
                    //           //     color: Color(0xFFFF6701),
                    //           //   ),
                    //           // ),
                    //         ),
                    //         child: Column(
                    //           children: [
                    //             Center(
                    //                 child: Text(
                    //               'Explore Now',
                    //               style: TextStyle(
                    //
                    //                 color: Color(0xFFFF6701),
                    //                 fontSize: 10,
                    //                 fontFamily: 'Helvetica',
                    //                 fontWeight: FontWeight.w700,
                    //               ),
                    //             )),
                    //
                    //             Divider(height: 2,color: RuntimeStorage().PrimaryOrange,thickness: 1,endIndent: 5,)
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //
                    //
                    //     // Container(
                    //     //     margin: EdgeInsets.only(right: 20),
                    //     //     height: 80,
                    //     //     child: Image.asset("assets/Group 385.png"))
                    //   ],
                    // )
                  ],
                ),
                 Padding(
                   padding: const EdgeInsets.fromLTRB(0, 20, 10, 20),
                   child: SvgPicture.asset(image),
                 )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
