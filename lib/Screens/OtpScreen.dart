import 'dart:async';
import 'dart:developer';
import 'package:koram_app/Helper/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Screens/HomeScreen.dart';
import 'package:koram_app/Screens/LoginScreen.dart';
import 'package:koram_app/Screens/PrivateProfileScreen.dart';
import 'package:koram_app/Screens/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'VerifiedScreen.dart';

class OtpScreen extends StatefulWidget {
  final phone;
  final noCodeNumber;
  final Function callBackInitialize;
  OtpScreen({this.phone, this.noCodeNumber, required this.callBackInitialize});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  var otpCode;
  var appSign;
  String _textContent = 'Waiting for messages...';
  var _timer;
  int _start = 25;
  bool isLoading = false;
  bool showResendLoader = false;
  void startTimer() {
    _start = 25;

    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
    // Future.delayed(Duration.zero).then(
    //     (value) => Provider.of<UsersProviderClass>(context, listen: false).fetchUsers());
  }

  // listenOTP() async {
  //   await SmsAutoFill().listenForCode;
  // }

  @override
  void dispose() {
    _timer.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    var user = Provider.of<UsersProviderClass>(context).LoggedUser;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              height: height,
              width: width,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: SvgPicture.asset("assets/CaretLeft.svg"),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          // height: height * .3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 258,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Enter ',
                                        style: TextStyle(
                                          color: Color(0xFF303030),
                                          fontSize: 24,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.w700,
                                          height: 0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'OTP',
                                        style: TextStyle(
                                          color: backendColor,
                                          fontSize: 24,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.w700,
                                          height: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )

                              // Text(
                              //   "Enter Your OTP",
                              //   style: TextStyle(
                              //       fontWeight: FontWeight.bold, fontSize: 20),
                              // ),
                              // Container(
                              //     padding: EdgeInsets.only(
                              //         top: MediaQuery.of(context).padding.top + 10),
                              //     height: height * .3,
                              //     width: width * .5,
                              //     child: Image.asset(
                              //       "assets/Group3.png",
                              //       fit: BoxFit.cover,
                              //     ))
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12.73, 0, 28),
                        child: SizedBox(
                          width: 327,
                          child: Text(
                            'We have sent the OTP verification code to your mobile number',
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${widget.phone}',
                            style: TextStyle(
                              color: Color(0xFF303030),
                              fontSize: 16,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                widget.callBackInitialize();
                                Navigator.of(context).pop();
                              },
                              child: SvgPicture.asset(
                                "assets/Edit.svg",
                                color: backendColor,
                              ))
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 25, 0, 57),
                        child: Container(
                          // height: 60,
                          // width: 73,
                          height: 82,
                          // decoration: ShapeDecoration(
                          //   color: Colors.white,
                          //   shape: RoundedRectangleBorder(
                          //     side: BorderSide(
                          //       width: 1,
                          //       color: Colors.black.withOpacity(0.07999999821186066),
                          //     ),
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          // ),
                          // margin: EdgeInsets.fromLTRB(0, 25, 0, 57),
                          child: PinFieldAutoFill(
                            enableInteractiveSelection: false,
                            decoration: BoxLooseDecoration(
                              strokeColorBuilder: FixedColorBuilder(Colors.black
                                  .withOpacity(0.07999999821186066)),
                            ),
                            // decoration: UnderlineDecoration(),
                            codeLength: 4,
                            cursor: Cursor(
                              color: backendColor,
                              width: 10,
                              height: 3,
                              enabled: true,
                            ),
                            currentCode: otpCode,
                            onCodeSubmitted: (code) {
                              G.verifyOtp(widget.phone, otpCode);
                            },
                            onCodeChanged: (code) {
                              if (code!.length == 4) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              }
                              otpCode = code;
                              log("codedee $code");
                            },

                            // decoration: UnderlineDecoration(bgColorBuilder: ),
                          ),
                        ),
                      ),
                      showResendLoader
                          ? Container(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator())
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '00:${_start}',
                                  style: TextStyle(
                                    color: Color(0xFF007FFF),
                                    fontSize: 12,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                _start != 0
                                    ? Text(
                                        ' RESEND CODE',
                                        style: TextStyle(
                                          color: Color(0xFF707070),
                                          fontSize: 12,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            showResendLoader = true;
                                            isLoading = false;
                                          });
                                          startTimer();

                                          var response = await G()
                                              .getOtp("${widget.phone}");
                                          if (response == 200) {
                                            showResendLoader = false;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              backgroundColor: Colors
                                                  .green, // Set the background color
                                              content: Center(
                                                child: Text(
                                                  "Otp sent successfully",
                                                  style: TextStyle(
                                                    color: Colors
                                                        .white, // Set the text color
                                                  ),
                                                ),
                                              ),
                                              duration: Duration(seconds: 2),
                                            ));
                                          } else {
                                            showResendLoader = false;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              backgroundColor: Colors
                                                  .red, // Set the background color
                                              content: Center(
                                                child: Text(
                                                  "Error sending otp please try after sometime",
                                                  style: TextStyle(
                                                    color: Colors
                                                        .white, // Set the text color
                                                  ),
                                                ),
                                              ),
                                              duration: Duration(seconds: 2),
                                            ));
                                          }
                                        },
                                        child: Text(
                                          ' RESEND CODE',
                                          style: TextStyle(
                                            color: RuntimeStorage
                                                .instance.PrimaryOrange,
                                            fontSize: 12,
                                            fontFamily: 'Helvetica',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                      // Container(
                      //   height: height * .1,
                      //   width: width,
                      //   padding: EdgeInsets.only(left: 8),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     children: [
                      //       Text("Didn't received OTP? "),
                      //       GestureDetector(
                      //           onTap: () {
                      //             G.getOtp(widget.phone);
                      //           },
                      //           child: Text(
                      //             "Resend",
                      //             style: TextStyle(color: backendColor),
                      //           ))
                      //     ],
                      //   ),
                      // ),
                      // Container(
                      //   height: height * .1,
                      //   width: width,
                      //   padding: EdgeInsets.only(left: 8),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     mainAxisAlignment: MainAxisAlignment.start,
                      //     children: [
                      //       Text("Sending OTP to ${widget.phone}."),
                      //       GestureDetector(
                      //           onTap: () {
                      //             Navigator.of(context).pop();
                      //           },
                      //           child: Text(
                      //             "Change Number",
                      //             style: TextStyle(color: backendColor),
                      //           ))
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(
                    height: 46,
                  ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : GestureDetector(
                          onTap: () async {
                            print("clicked");
                            print(otpCode);
                            setState(() {
                              isLoading = true;
                            });

                            var v = await G.verifyOtp(widget.phone, otpCode);
                            if (!v) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                backgroundColor:
                                    Colors.red, // Set the background color
                                content: Text(
                                  "Wrong OTP. Please check the code and try again.",
                                  style: TextStyle(
                                    color: Colors.white, // Set the text color
                                  ),
                                ),
                              ));
                              setState(() {
                                isLoading = false;
                              });

                              return;
                            }

                            if (v) {
                              setState(() {
                                isLoading = false;
                                if (!G.isNewUser) {
                                  G.logedIn = true;
                                }
                                G.userPhoneNumber = widget.phone;
                                G.noCodeNumber = widget.noCodeNumber;
                              });
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              // await prefs.setBool('logedIn', G.logedIn);
                              await prefs.setString(
                                  'userId', G.userPhoneNumber);
                              prefs.setBool("isShowYourself", false);

                              user = user;

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => VerifiedSuccessfully(
                                      goToHome: !G.isNewUser)));
                            }
                          },
                          child: Container(
                            // width: 350,

                            height: 54,
                            // padding: const EdgeInsets.symmetric(
                            //     horizontal: 10, vertical: 18),
                            decoration: ShapeDecoration(
                              color: backendColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Verify',
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
                  // Container(
                  //   padding: EdgeInsets.only(
                  //       bottom: MediaQuery.of(context).padding.bottom + 10),
                  //   width: width * .7,
                  //   child: TextButton(
                  //       onPressed: () async {
                  //         print("clicked");
                  //         print(otpCode);
                  //         setState(() {
                  //           _loading = true;
                  //         });
                  //
                  //         final v = await G.verifyOtp(widget.phone, otpCode);
                  //         print("dsdf");
                  //         setState(() {
                  //           _loading = false;
                  //           G.logedIn = true;
                  //           G.userId = widget.phone;
                  //         });
                  //         SharedPreferences prefs =
                  //             await SharedPreferences.getInstance();
                  //         await prefs.setBool('logedIn', G.logedIn);
                  //         await prefs.setString('userId', G.userId);
                  //         print("sdlsf" + prefs.getString("userId")!);
                  //         print("sdlsf" + prefs.getBool('logedIn').toString());
                  //         setState(() {
                  //           _loading = false;
                  //         });
                  //         if (v) {
                  //           user = user
                  //               .where(
                  //                   (element) => element.phoneNumber == widget.phone)
                  //               .toList();
                  //           if (user.length > 0)
                  //             Navigator.of(context).push(MaterialPageRoute(
                  //                 builder: (context) => HomeScreen()));
                  //           else
                  //             Navigator.of(context).push(MaterialPageRoute(
                  //                 builder: (context) => SplashScreen(3)));
                  //         }
                  //       },
                  //       child: _loading
                  //           ? CircularProgressIndicator(
                  //               color: Colors.white,
                  //             )
                  //           : Text("Verify"),
                  //       style: TextButton.styleFrom(
                  //           primary: Colors.white,
                  //           backgroundColor: backendColorAccent,
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
  }
}
