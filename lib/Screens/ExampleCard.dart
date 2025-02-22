import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';

import '../Helper/Helper.dart';
import 'bottomButtonRow.dart';

class ExampleCard extends StatelessWidget {
  ExampleCard({
    required this.name,
    required this.imagePath,
    required this.interests,
    key,
  });

  final String name;
  final String imagePath;
  List<String> interests;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(21, 10, 21, 0),
          child: Container(
            width: 348,
            height: MediaQuery.of(context).size.height - 50,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
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
            child: Column(
              children: [
                Container(
                  width: 348,
                  height: 438,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            G.HOST + "api/v1/datingImage/" + imagePath),
                        fit: BoxFit.cover),
                    gradient: LinearGradient(
                      begin: Alignment(0.00, -1.00),
                      end: Alignment(0, 1),
                      colors: [
                        Colors.black.withOpacity(0),
                        Colors.black.withOpacity(0.5699999928474426)
                      ],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset("assets/MapPinLine.svg"),
                            Text(
                              'Lives in Mumbai',
                              style: TextStyle(
                                color: Color(0xFFF2F2F2),
                                fontSize: 14,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 18,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                    image: AssetImage("assets/love.png")),
                                color: Color(0xFFFF6701),
                                shape: OvalBorder(),
                              ),
                              // child: SvgPicture.asset(
                              //   "assets/love.svg",
                              //   width: 32,
                              //   height: 32,
                              // ),
                            ),
                            Container(
                              height: 54,
                              width: 54,
                              decoration: ShapeDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/star-inside-circle.png")),
                                color: Color(0xFFFF6701),
                                shape: OvalBorder(),
                              ),
                              // child: SvgPicture.asset(
                              //   "assets/star-inside-circle.svg",
                              //   width: 32,
                              //   height: 32,
                              // ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 5, 0, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Interests in common',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 14,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: Container(
                    height: 60,
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center,
                        children: [
                          for (var interest in interests)
                            Container(
                              height: 25,
                              // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      width: 1, color: Color(0xFFF2F2F2)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 2.0, bottom: 2, left: 3, right: 3),
                                    child: Text(
                                      '$interest',
                                      style: TextStyle(
                                        color: Color(0xFF303030),
                                        fontSize: 12,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Row(
                //   children: [
                //     SizedBox(width: 14,),
                //     Container(
                //       width: 81,
                //       height: 26,
                //       // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                //       decoration: ShapeDecoration(
                //         color: Colors.white,
                //         shape: RoundedRectangleBorder(
                //           side: BorderSide(width: 1, color: Color(0xFFF2F2F2)),
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //       ),
                //       child: Center(
                //         child: Text(
                //           'Travelling',
                //           style: TextStyle(
                //             color: Color(0xFF303030),
                //             fontSize: 12,
                //             fontFamily: 'Helvetica',
                //             fontWeight: FontWeight.w700,
                //             height: 0,
                //           ),
                //         ),
                //       ),
                //     ),
                //
                //   ],
                // )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
