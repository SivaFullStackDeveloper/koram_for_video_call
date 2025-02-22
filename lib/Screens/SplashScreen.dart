import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koram_app/Screens/BoardingScreen.dart';
import 'package:koram_app/Screens/LoginScreen.dart';
import 'package:koram_app/Screens/PrivateProfileScreen.dart';
import 'package:koram_app/Screens/PublicProfileScreen.dart';

class SplashScreen extends StatefulWidget {
  final _page;
  const SplashScreen(this._page);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _page;
  @override
  initState() {
    super.initState();
    setState(() {
      _page = widget._page;
    });
    if (_page == 1) {
      Timer(Duration(seconds: 3), () {
        // setState(() {
        //   _page = 2;
        // });
        // navigateAnimation(2,true);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) {
          return BoardingScreen();
        }));
      });
    }
  }

  getScreen(double height, double width) {
    switch (_page) {
      case 1:
        return GestureDetector(
          onTap: () {
            log("gesture detected");
            setState(() {
              _page = 2;
            });
          },
          child: Scaffold(
            body: Container(
              color: Colors.white,
              child: SafeArea(
                child: Container(
                  height: height,
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 225,
                              height: 198,
                              // height: height * .65,
                              // padding: EdgeInsets.only(top: ),
                              child: SvgPicture.asset(
                                'assets/birbLogo.svg',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 14,
                      ),
                      Text(
                        'Koram',
                        style: TextStyle(
                          color: Color(0xFF303030),
                          fontSize: 58.70,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Let’s connect with the world',
                        style: TextStyle(
                          color: Color(0xFF303030),
                          fontSize: 19.78,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.only(bottom: height * .05),
                      //   width: width * .7,
                      //   child: TextButton(
                      //       onPressed: () {
                      //         setState(() {
                      //           _page = 2;
                      //         });
                      //       },
                      //       child: Text("Get Started"),
                      //       style: TextButton.styleFrom(
                      //           primary: Colors.white,
                      //           backgroundColor: Colors.orangeAccent,
                      //           shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(20)))),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      case 2:
        return Scaffold(
          /*    appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: Colors.red,
            systemOverlayStyle: SystemUiOverlayStyle(
              // systemNavigationBarColor: Colors.blue, // Navigation bar
              statusBarColor: Colors.white, // Status bar
systemNavigationBarContrastEnforced: true
            ),
            elevation: 0,
          ),*/
          body: SafeArea(
            child: Container(
              height: height,
              width: width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top:27.0),
                          child: SizedBox(
                            width: 289,
                            child: Text(
                              'Connect with People',
                              style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 34,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w600,
                                height: 1.15,
                                letterSpacing: -0.41,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),

                        GestureDetector(
                          onTap: () {

                            navigateToPGAnimation(LoginScreen(ispoped: false,));

                            // Navigator.of(context)
                            //     .push(MaterialPageRoute(builder: (context) {
                            //   return LoginScreen();
                            // }));
                          },
                          child: Text(
                            'Skip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF007FFF),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                              height: 0.12,
                            ),
                          ),
                        )
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                        child: Container(
                          // height: height * .7,
                          // width: width * .8,
                          child: SvgPicture.asset(
                            'assets/Splash1.svg',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 105,
                          height: 5,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 33,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(1.00, 0.08),
                                      end: Alignment(-1, -0.08),
                                      colors: [
                                        Color(0xFFFF6701),
                                        Color(0xFFFF8D41)
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 36,
                                top: 0,
                                child: Container(
                                  width: 33,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFFFEADC),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 72,
                                top: 0,
                                child: Container(
                                  width: 33,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFFFEADC),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        // Navigator.of(context)
                        //     .push(MaterialPageRoute(builder: (context) {
                        //   return LoginScreen();
                        // }));

                        navigateAnimation(3,true);
                        },


                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 54,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 18),
                            decoration: ShapeDecoration(
                              color: Color(0xFFFF6701),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Center(
                                child: Text(
                              'Next',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          //       return LoginScreen();
          //     }));
          //   },
          //   child: Icon(
          //     Icons.chevron_right,
          //     size: 50,
          //     color: Colors.white,
          //   ),
          // ),
        );
      case 3:
        return Scaffold(
          body: SafeArea(
            child: Container(
              height: height,
              width: width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 20.0,top: 33),
                    //   child: Text(
                    //     "Create Your Personal\nProfile",
                    //     textAlign: TextAlign.start,
                    //     style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                    //   ),
                    // ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 27.0),
                          child: SizedBox(
                            width: 289,
                            child: Text(
                              'Discover new things',
                              style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 34,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.41,
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: () {
                            navigateToPGAnimation(LoginScreen(ispoped: false,));

                            // Navigator.of(context)
                            //     .push(MaterialPageRoute(builder: (context) {
                            //   return LoginScreen();
                            // }));
                          },
                          child: Text(
                            'Skip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF007FFF),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                              height: 0.12,
                            ),
                          ),
                        ),
                        // SkipWidget()
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: 334,
                      child: Text(
                        'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 14,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: width,
                      // height: height * .7,
                      child: SvgPicture.asset(
                        'assets/Splash2.svg',
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 105,
                          height: 5,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 33,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(1.00, 0.08),
                                      end: Alignment(-1, -0.08),
                                      colors: [
                                        Color(0xFFFF6701),
                                        Color(0xFFFF8D41)
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 36,
                                top: 0,
                                child: Container(
                                  width: 33,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(1.00, 0.08),
                                      end: Alignment(-1, -0.08),
                                      colors: [
                                        Color(0xFFFF6701),
                                        Color(0xFFFF8D41)
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 72,
                                top: 0,
                                child: Container(
                                  width: 33,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFFFEADC),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // navigateAnimation(2,false);
                            // navigateAnimation(2,false);
                            Navigator.pop(context);
                            // setState(() {
                            //   _page = 2;
                            // });
                          },
                          child: Container(
                            width: 100,
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                            decoration: ShapeDecoration(
                              color: Color(0xFFF2F2F2),
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
                                  'Back',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF707070),
                                    fontSize: 16,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.w700,
                                    height: 0,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        GestureDetector(
                          onTap: () {
                            // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            //   return PrivarteProfileScreen();
                            // }));

                            navigateAnimation(4,true);

                            // setState(() {
                            //   _page = 4;
                            // });
                          },
                          child: Container(
                            width: 100,
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
                                )
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
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          //       return PrivarteProfileScreen();
          //     }));
          //   },
          //   child: Icon(
          //     Icons.chevron_right,
          //     size: 50,
          //     color: Colors.white,
          //   ),
          // ),
        );
      case 4:
        return Scaffold(
          body: SafeArea(
            child: Container(
              height: height,
              width: width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 27.0),
                          child: SizedBox(
                            width: 289,
                            child: Text(
                              'Share your moments',
                              style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 34,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w600,
                                height: 1.15,
                                letterSpacing: -0.41,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 20.0),
                    //   child: Text(
                    //     "Create Your Public\nProfile",
                    //     textAlign: TextAlign.start,
                    //     style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
                    //   ),
                    // ),
                    SizedBox(
                      height: 18,
                    ),
                    SizedBox(
                      width: 334,
                      child: Text(
                        'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontSize: 14,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w400,
                          height: 0,
                        ),
                      ),
                    ),
                  SizedBox(height: 65,) ,
                    Container(
                      width: width,
                      // height: height * .7,
                      child: SvgPicture.asset(
                        'assets/Splash3.svg',
                        fit: BoxFit.fill,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 105,
                          height: 5,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 33,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(1.00, 0.08),
                                      end: Alignment(-1, -0.08),
                                      colors: [
                                        Color(0xFFFF6701),
                                        Color(0xFFFF8D41)
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 36,
                                top: 0,
                                child: Container(
                                  width: 33,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(1.00, 0.08),
                                      end: Alignment(-1, -0.08),
                                      colors: [
                                        Color(0xFFFF6701),
                                        Color(0xFFFF8D41)
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 72,
                                top: 0,
                                child: Container(
                                  width: 33,
                                  height: 5,
                                  decoration: ShapeDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(1.00, 0.08),
                                      end: Alignment(-1, -0.08),
                                      colors: [
                                        Color(0xFFFF6701),
                                        Color(0xFFFF8D41)
                                      ],
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    GestureDetector(
                      onTap: () {
                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        //   return PublicProfileScreen();
                        // }));
                        navigateToPGAnimation( LoginScreen(ispoped: false,));

                        // Navigator.of(context)
                        //     .push(MaterialPageRoute(builder: (context) {
                        //   return LoginScreen();
                        // }));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 18),
                              decoration: ShapeDecoration(
                                color: Color(0xFFFF6701),
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
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          //       return PublicProfileScreen();
          //     }));
          //   },
          //   child: Icon(
          //     Icons.chevron_right,
          //     size: 50,
          //     color: Colors.white,
          //   ),
          // ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return getScreen(height, width);
  }

  navigateAnimation(int page_number,bool forward)
  {

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // setState(() {
          //   _page = 3;
          // });
          return SplashScreen(page_number);
        },

        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuint;
          Animatable< Offset> tween;
          if(forward)
          {
            tween =Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
          }else
          {
            tween = Tween(begin: end, end: begin).chain(
              CurveTween(curve: curve),
            );
          }

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),

      ),
    );
  }


  navigateToPGAnimation(Widget w)
  {

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // setState(() {
          //   _page = 3;
          // });
          return w;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuint;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,

          );

        },
      ),
    );
  }

  Widget SkipWidget()
  { return
    TextButton(onPressed: (){navigateToPGAnimation(LoginScreen(ispoped: false,));},  child: Text(
      'Skip',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF007FFF),
        fontSize: 14,
        fontFamily: 'Helvetica',
        fontWeight: FontWeight.w400,
        height: 0.12,
      ),
    ),);
  }
}
