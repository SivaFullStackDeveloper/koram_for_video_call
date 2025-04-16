import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'DatingPhotos.dart';
import 'package:koram_app/Helper/color.dart';
class DatingSplash extends StatefulWidget {
  const DatingSplash({key});

  @override
  State<DatingSplash> createState() => _DatingSplashState();
}

class _DatingSplashState extends State<DatingSplash> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   leading: Padding(
        //     padding: const EdgeInsets.only(left: 20.0),
        //     child: SvgPicture.asset("assets/CaretLeft.svg"),
        //   ),
        //   leadingWidth: 50,
        //   elevation: 0,
        // ),
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
                    child: GestureDetector(
                      child: SvgPicture.asset("assets/CaretLeft.svg"),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 14.0),
                          child: SizedBox(
                            width: 289,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Find your \n',
                                    style: TextStyle(
                                      color: backendColor,
                                      fontSize: 34,
                                      fontFamily: 'Helvetica',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.41,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'best match',
                                    style: TextStyle(
                                      color: Color(0xFF303030),
                                      fontSize: 34,
                                      fontFamily: 'Helvetica',
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.41,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 18, bottom: 20),
                      child: Text(
                        'Join us to discover your ideal partner.',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 14,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Container(
                      color: Colors.white,
                      child: SvgPicture.asset(
                        "assets/DatingSplash.svg",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return DatingPhotos();
              }));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 18),
                      decoration: ShapeDecoration(
                        color: backendColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
