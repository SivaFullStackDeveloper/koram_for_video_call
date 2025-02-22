import 'dart:convert';
import 'dart:developer';

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:koram_app/Helper/CommonWidgets.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Screens/BoardingScreen.dart';
import 'package:koram_app/Screens/OtpScreen.dart';

import 'package:loader_overlay/loader_overlay.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widget/CountryCodeWidget.dart';
import 'SplashScreen.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  bool ispoped = false;
  LoginScreen({Key? key, required this.ispoped}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var phoneNumber;
  var noCodeNumber;
  bool isGettingCountry = true;
  bool isLoading = false;
  bool isLocationEnabled = false;
  bool isPopedforedit = false;
  var userCountry;
  var phonenumberCTRL = TextEditingController();
  var code = CountryCode(name: "United States", code: "US", dialCode: "+1");

  final countryPicker = FlCountryCodePicker(
    searchBarTextStyle: TextStyle(
      color: Color(0xFF303030),
      fontSize: 12,
      fontFamily: 'Helvetica',
      fontWeight: FontWeight.w400,
      height: 0,
    ),
    localize: true,
    searchBarDecoration: InputDecoration(
      hintText: "Search Country Code",
      hintStyle: TextStyle(
        color: Color(0xFF303030),
        fontSize: 12,
        fontFamily: 'Helvetica',
        fontWeight: FontWeight.w400,
        height: 0,
      ),
      suffixIcon: Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          width: 0,
          style: BorderStyle.none,
        ),
      ),
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      fillColor: Color(0xFFF5F5F5),
    ),
    showDialCode: true,
    showSearchBar: true,
    title: Padding(
      padding: const EdgeInsets.only(left: 25.0, top: 25),
      child: Text(
        'Select Country',
        style: TextStyle(
          color: Color(0xFF303030),
          fontSize: 18,
          fontFamily: 'Helvetica',
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // askForNotificationPermission();
    // askForLocationPermission();
    _getCountry();
    requestNotificationPermission();
  }
  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.notification.request();
      if (status == PermissionStatus.granted) {
        print("Notification permission granted");
      } else {
        print("Notification permission denied");
      }
    }
  }

  Future<void> _getCountry() async {
    isGettingCountry = true;
    try {
      final response = await http.get(Uri.parse('https://ipapi.co/json/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        log("country data ${data}");
        setState(() {

          code = CountryCode.fromDialCode(data["country_calling_code"]) ?? code;
          isGettingCountry = false;

        });
      } else {
        setState(() {
          isGettingCountry = false;
        });
        CommanWidgets().showSnackBar(
            context,
            "Unable to get your Country code Please select it Manually ",
            Colors.deepOrange);
        print('Failed to get country: ${response.statusCode}');
      }
    } catch (e) {
      CommanWidgets().showSnackBar(
          context,
          "Unable to get your Country code Please select it Manually ",
          Colors.deepOrange);

      setState(() {
        isGettingCountry = false;
      });
    }
  }

  askForNotificationPermission() async {
    log("executed the asknotificvation");
    var status = await Permission.notification.request();

    if (status.isGranted) {
      print('Notification permission granted');
    } else {
      print('Notification permission denied');
      showPermissionDeniedDialog();
    }
  }

  void showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text(
              'Please grant notification permission to receive Call/ Message alerts.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await Permission.notification.request();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void showLocationPermissionDeniedDialog() {
    // Implement your logic to show a dialog when location permission is denied
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text('Please grant Location permission.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await Permission.location.request();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void showEnableLocationServiceDialog() {
    // Implement your logic to show a dialog asking the user to enable location service
  }
  void askForLocationPermission() async {
    log("executed the askLocationPermission");
    var status = await Permission.location.request();

    if (status.isGranted) {
      var serviceStatus = await Permission.location.serviceStatus;
      if (serviceStatus.isEnabled) {
        isLocationEnabled = true;
      } else {
        isLocationEnabled = false;
        showEnableLocationServiceDialog();
      }
    } else {
      isLocationEnabled = false;
      showLocationPermissionDeniedDialog();
    }
  }

  void askPermissionDialogue() {
    // Implement your logic to show a dialog when location permission is denied
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text('Please grant Location permission.'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await Permission.location.request();
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    if (isLocationEnabled) {
      code;
    }
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return BoardingScreen();
                              }));
                              // Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
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
                                  text: 'Phone Number',
                                  style: TextStyle(
                                    color: Color(0xFFFF6701),
                                    fontSize: 24,
                                    fontFamily: 'Helvetica',
                                    fontWeight: FontWeight.w700,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'Phone Number',
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: width,
                      padding: EdgeInsets.only(left: 0, top: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 0,
                            child: Container(
                              height: 60,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    style: BorderStyle.solid,
                                    strokeAlign: 4,
                                    color: Colors.black
                                        .withOpacity(0.07999999821186066),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  // final code = await countryPicker.showPicker(context: context);
                                  // showModalBottomSheet(
                                  //     context: context,
                                  //     shape:  RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.only(
                                  //           topLeft: Radius.circular(30),
                                  //           topRight: Radius.circular(30),
                                  //         ),),
                                  //     builder: (ctx) => CountryCodeWidget());
                                  code = (await countryPicker.showPicker(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              topRight: Radius.circular(30),
                                            ),
                                          ),
                                          context: context)) ??
                                      CountryCode(
                                          name: "United States",
                                          code: "US",
                                          dialCode: "+1");
                                  setState(() {
                                    code;
                                  });
                                  // Null check
                                  log("logsss${code.code} ${code.name} ${code.dialCode}");
                                },
                                child: isGettingCountry
                                    ? Container(
                                  height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.deepOrange,
                                        strokeWidth: 3,
                                        ),
                                    )
                                    : Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Image.asset(
                                              code.flagUri,
                                              width: 20,
                                              package: code.flagImagePackage,
                                            ),
                                          ),
                                          Text(
                                            "${code.dialCode}",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          SvgPicture.asset(
                                              "assets/ArrowDown.svg")
                                        ],
                                      ),
                                // style: TextButton.styleFrom(
                                //     shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(5)),
                                //     backgroundColor: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Container(
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      style: BorderStyle.solid,
                                      strokeAlign: 6,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: TextField(
                                  maxLines: 1,
                                  onTapOutside: (e) {
                                    log(e.toString());

                                    FocusScope.of(context).unfocus();
                                  },
                                  controller: phonenumberCTRL,
                                  onChanged: (value) {
                                    setState(() {
                                      phoneNumber = "${code.dialCode}$value";
                                      noCodeNumber = value;
                                    });
                                  },
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    filled: true,

                                    label: Text("Enter Number Here"),
                                    fillColor: Colors.white,
                                    // labelText: "  Enter number here",
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    isLoading
                        ? CircularProgressIndicator(
                            color: RuntimeStorage().PrimaryOrange,
                          )
                        : GestureDetector(
                            onTap: () async {
                              if (noCodeNumber == "" || noCodeNumber == null) {
                                CommanWidgets().showSnackBar(context,
                                    "Please enter Phone number", Colors.red);
                                return;
                              }

                              setState(() {
                                isLoading = true;
                              });
                              log("COdeee $phoneNumber");

                              if (phoneNumber == "" || phoneNumber == null) {
                                CommanWidgets().showSnackBar(context,
                                    "Please enter a valid number", Colors.red);

                                setState(() {
                                  isLoading = false;
                                });
                                return;
                              }

                              var response = await G().getOtp("$phoneNumber");
                              if (response == 200) {
                                log("REsponse from jsonnn ${response}");
                                setState(() {
                                  isLoading = false;
                                });
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => OtpScreen(
                                          callBackInitialize: () {
                                            log("initialized callback $phoneNumber  code $noCodeNumber  ${code.code} ");
                                            setState(() {
                                              phonenumberCTRL.clear();
                                              phoneNumber = "";
                                              noCodeNumber = "";
                                              code = CountryCode(
                                                  name: "United States",
                                                  code: "US",
                                                  dialCode: "+1");
                                            });
                                          },
                                          phone: phoneNumber,
                                          noCodeNumber: noCodeNumber,
                                        )));
                              } else if (response == "timeout") {
                                CommanWidgets().showSnackBar(
                                    context,
                                    "Sorry there was an error please try again later",
                                    Colors.red);
                                setState(() {
                                  isLoading = false;
                                });
                              } else if (response == 500) {
                                CommanWidgets().showSnackBar(
                                    context,
                                    "There was an error please try again later",
                                    Colors.red);

                                setState(() {
                                  isLoading = false;
                                });
                              } else {
                                CommanWidgets().showSnackBar(context,
                                    "Please enter a valid number", Colors.red);

                                setState(() {
                                  isLoading = false;
                                });
                              }
                            },
                            child: Container(
                              width: width,
                              height: 54,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 18),
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
                                    'Send OTP',
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
                          )
                  ],
                ),
                // Container(
                //   padding: EdgeInsets.only(
                //       bottom: MediaQuery.of(context).padding.bottom + 30),
                //   width: width * .7,
                //   child: TextButton(
                //       onPressed: () async {
                //         print("clicked");
                //         log("COdeee $phoneNumber");
                //         var response=await G.getOtp("$phoneNumber");
                //         log("REsponse from jsonnn ${response}");
                //         Navigator.of(context).push(MaterialPageRoute(
                //             builder: (context) => OtpScreen(phone: phoneNumber)));
                //       },
                //       child: Text("Get OTP"),
                //       style: TextButton.styleFrom(
                //
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
    );
  }
}
