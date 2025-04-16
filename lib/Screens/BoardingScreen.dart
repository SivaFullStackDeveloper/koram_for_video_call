import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koram_app/Helper/color.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'LoginScreen.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({key});

  @override
  State<BoardingScreen> createState() => _BoardingScreenState();
}

List<String> onboardingImages = [
  'assets/Splash1.svg',
  'assets/Splash2.svg',
  'assets/Splash3.svg',
];
List<String> onboardingTitles = ['Connect\n', 'Discover\n', 'Share\n'];
List<String> onboardingSub = ['with People', 'new things', 'your moments'];

class _BoardingScreenState extends State<BoardingScreen> {
  final PgController = PageController();

  @override
  void dispose() {
    // TODO: implement dispose
    PgController.dispose();
    super.dispose();
  }

  int pageNumber = 0;
  bool isSecondPage = false;

  Navigate() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return LoginScreen(
        ispoped: false,
      );
    }));
  }

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: width,
          height: height,
          child: Stack(clipBehavior: Clip.none, children: <Widget>[
            PageView.builder(
              itemCount: 3,
              physics: BouncingScrollPhysics(),

              onPageChanged: (i) {
                setState(() {
                  pageNumber = i;
                });
              },
              controller: PgController,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Container(
                    color: Colors.white,
                    child: SvgPicture.asset(
                      onboardingImages[index],
                    ),
                  ),
                );
              },
              // children: [
              //   firstBoard(height, width),
              //   secondBoard(height, width),
              //   thirdBoard(height, width)
              // ],
            ),
            Container(
              height: height,
              width: width,
              // color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 27.0),
                            child: SizedBox(
                              width: 289,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: onboardingTitles[pageNumber],
                                      style: TextStyle(
                                        color: backendColor,
                                        fontSize: 34,
                                        fontFamily: 'Helvetica',
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.41,
                                      ),
                                    ),
                                    TextSpan(
                                      text: onboardingSub[pageNumber],
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
                            )
                            // SizedBox(
                            //   width: 280,
                            //   child: Text(
                            //     onboardingTitles[pageNumber],
                            //     style: TextStyle(
                            //       color: Color(0xFF303030),
                            //       fontSize: 34,
                            //       fontFamily: 'Helvetica',
                            //       fontWeight: FontWeight.w600,
                            //       height: 1.15,
                            //       letterSpacing: -0.41,
                            //     ),
                            //   ),
                            // ),
                            ),
                        // Expanded(child: SizedBox()),

                        // TextButton(
                        //
                        //   onPressed: () {
                        //     log("clicked");
                        //   },
                        //   child: Text(
                        //     'Skip',
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(
                        //       color: Color(0xFF007FFF),
                        //       fontSize: 16,
                        //       fontFamily: 'Helvetica',
                        //       fontWeight: FontWeight.w400,
                        //     ),
                        //   ),
                        // )
                        // SkipWidget()
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 18, bottom: 20),
                        child: Text(
                          'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
                          style: TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 14,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        )),
                  ],
                ),
              ),
            ),
            Positioned(
                right: 30,
                top: 20,
                child: pageNumber != 2
                    ? GestureDetector(
                        // behavior: HitTestBehavior.translucent,
                        onTap: () {
                          // setState(() {
                          //   PgController.jumpTo(2);
                          //
                          // });
                          Navigate();
                          log("clickeddd");
                        },
                        child: Container(
                          width: 40,
                          child: Text(
                            'Skip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF007FFF),
                              fontSize: 16,
                              height: 2,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      )
                    : SizedBox()),
          ]),
        ),
        bottomSheet: nextSkip(PgController),
      ),
    );
  }

  nextSkip(PageController pg) {
    return Container(
      height: 150,
      color: Colors.white,
      child: Column(
        children: [
          Center(
            child: SmoothPageIndicator(
              controller: pg,
              count: 3,
              effect: WormEffect(
                  strokeWidth: 2,
                  dotColor: Color(0xFFFFEADC),
                  activeDotColor: backendColor,
                  dotWidth: 33,
                  dotHeight: 5),
            ),
          ),
          Expanded(child: SizedBox()),
          pageNumber == 2
              ? Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      //   return PublicProfileScreen();
                      // }));
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return LoginScreen(
                          ispoped: false,
                        );
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
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      //   return PublicProfileScreen();
                      // }));
                      log("Pageee ${pg.page}");
                      pg.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut);
                      // Navigator.of(context)
                      //     .push(MaterialPageRoute(builder: (context) {
                      //   return LoginScreen();
                      // }));
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
                                'Next',
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

          // Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Visibility(
          //             visible: pageNumber == 1,
          //             child: Padding(
          //               padding: const EdgeInsets.all(20),
          //               child: GestureDetector(
          //                 onTap: () {
          //                   setState(() {});
          //                   // navigateAnimation(2,false);
          //                   // navigateAnimation(2,false);
          //                   // setState(() {
          //                   //   _page = 2;
          //                   // });
          //                   log("Pageee ${pg.page}");
          //
          //                   pg.previousPage(
          //                       duration: Duration(milliseconds: 500),
          //                       curve: Curves.easeOut);
          //                 },
          //                 child: Container(
          //                   width: 100,
          //                   height: 54,
          //                   padding: const EdgeInsets.symmetric(
          //                       horizontal: 10, vertical: 18),
          //                   decoration: ShapeDecoration(
          //                     color: Color(0xFFF2F2F2),
          //                     shape: RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(12),
          //                     ),
          //                   ),
          //                   child: Row(
          //                     mainAxisSize: MainAxisSize.min,
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     crossAxisAlignment: CrossAxisAlignment.center,
          //                     children: [
          //                       Text(
          //                         'Back',
          //                         textAlign: TextAlign.center,
          //                         style: TextStyle(
          //                           color: Color(0xFF707070),
          //                           fontSize: 16,
          //                           fontFamily: 'Helvetica',
          //                           fontWeight: FontWeight.w700,
          //                           height: 0,
          //                         ),
          //                       )
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //           Padding(
          //             padding: const EdgeInsets.all(20),
          //             child: GestureDetector(
          //               onTap: () {
          //                 // Navigator.of(context)
          //                 //     .push(MaterialPageRoute(builder: (context) {
          //                 //   return LoginScreen();
          //                 // }));
          //
          //                 // navigateAnimation(3,true);
          //
          //                 log("Pageee ${pg.page}");
          //                 pg.nextPage(
          //                     duration: Duration(milliseconds: 500),
          //                     curve: Curves.easeInOut);
          //               },
          //               child: Row(
          //                 mainAxisAlignment: MainAxisAlignment.end,
          //                 children: [
          //                   Container(
          //                     width: 100,
          //                     height: 54,
          //                     padding: const EdgeInsets.symmetric(
          //                         horizontal: 10, vertical: 18),
          //                     decoration: ShapeDecoration(
          //                       color: backendColor,
          //                       shape: RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.circular(12),
          //                       ),
          //                     ),
          //                     child: Center(
          //                         child: Text(
          //                       'Next',
          //                       textAlign: TextAlign.center,
          //                       style: TextStyle(
          //                         color: Colors.white,
          //                         fontSize: 16,
          //                         fontFamily: 'Helvetica',
          //                         fontWeight: FontWeight.w700,
          //                         height: 0,
          //                       ),
          //                     )),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           )
          //         ],
          //       ),
        ],
      ),
    );
  }
}
