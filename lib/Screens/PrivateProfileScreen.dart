import 'dart:convert';
import 'dart:developer';

import 'dart:io';
import 'package:koram_app/Helper/color.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:koram_app/Helper/CommonWidgets.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Helper/LocationServices.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Screens/BoardingScreen.dart';
import 'package:koram_app/Screens/SplashScreen.dart';
import 'package:koram_app/Screens/test.dart';
import 'package:koram_app/Widget/uploda.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/RuntimeStorage.dart';
import 'HomeScreen.dart';
import 'PublicProfileScreen.dart';

class PrivateProfileScreen extends StatefulWidget {
  var isFromHome = false;
  UserDetail userData = UserDetail();
  PrivateProfileScreen(
      {Key? key, required UserDetail this.userData, required this.isFromHome})
      : super(key: key);

  @override
  _PrivateProfileScreenState createState() => _PrivateProfileScreenState();
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

class _PrivateProfileScreenState extends State<PrivateProfileScreen> {
  var _focusNode = new FocusNode();
  var _dobFocuseNode = new FocusNode();
  UserDetail userData = UserDetail();
  final _gender = ["Male", "Female", "Other"];
  var _name;
  int counter = 0;
  var UserDob = DateTime.now().toString();
  DateTime initialDate = DateTime.now();
  var genderValue;
  bool checked = false;
  bool SendingData = false;
  bool loadingImage = false;
  var uploadedImageData;
  TextEditingController _nameController = TextEditingController();
  bool isNewUser = true;
  bool isprofile = false;
  ImagePicker picker = ImagePicker();
  File? tempImagePrivate;
  var lat = 0.0;
  var long = 0.0;
  _focusListener() {
    setState(() {});
  }

  cropAndAssign(XFile pickedFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 10,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPresetCustom(),
          ],
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(
            width: 520,
            height: 520,
          ),
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        tempImagePrivate = File(croppedFile.path);
      });
    }
  }

  @override
  void initState() {
    // log("DATEOFBBBB" + widget.userData.dateofbirth.toString());
    //
    //
    // if (widget.isFromHome) {
    //   tempImagePrivate = null;
    //   _nameController.text = widget.userData!.privateName!;
    //   if (widget.userData!.dateofbirth != null ||
    //       widget.userData!.dateofbirth != "") {
    //     UserDob = DateTime.parse(widget.userData!.dateofbirth!).toString();
    //     initialDate = DateTime.parse(widget.userData!.dateofbirth!);
    //     log("userDOb${initialDate.toString()}");
    //   }
    //   genderValue = widget.userData!.gender;
    //   checked = true;
    // }
    _focusNode.addListener(_focusListener);
    _dobFocuseNode.addListener(_focusListener);
    log("isnewloggedinUser ${G.loggedinUser}  ");
    assignLatLong();
    super.initState();
  }

  assignLatLong() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Request user to enable location services
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        log("from private profile  service in not enabled");
      } else {
        Position position = await LocationService().getCurrentLocation();
        lat = position.latitude;
        long = position.longitude;
        await Provider.of<UsersProviderClass>(context, listen: false)
            .addLocation(position.latitude, position.longitude);
        log("The location service is turned on. from private profile screen");
      }
    } else {
      Position position = await LocationService().getCurrentLocation();
      lat = position.latitude;
      long = position.longitude;

     if(mounted){
       await Provider.of<UsersProviderClass>(context, listen: false)
          .addLocation(position.latitude, position.longitude);
     }
      log("The location service is already on. from private profile screen");
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    _dobFocuseNode.removeListener(_focusListener);

    if (_name != null) {
      _name.dispose();
    }
    super.dispose();
  }

  getImage() {
    if (tempImagePrivate == null) {
      if (G.loggedinUser != null &&
          G.loggedinUser.privateProfilePicUrl != null) {
        if (G.loggedinUser.privateProfilePicUrl != "") {
          log("private pic url in g." +
              G.loggedinUser.privateProfilePicUrl.toString());
          return NetworkImage(
              G.HOST + "api/v1/images/" + G.loggedinUser.privateProfilePicUrl!);
        }
      } else {
        return null;
      }
    } else {
      return FileImage(File(tempImagePrivate!.path));
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    UsersProviderClass userModel =
        Provider.of<UsersProviderClass>(context, listen: false);

    //log("DATEOFBBBB" + userModel.LoggedUser!.dateofbirth.toString());

    if (widget.isFromHome) {
      tempImagePrivate = null;
      _nameController.text = userModel.LoggedUser!.privateName ?? "No Name";
      if (userModel.LoggedUser!.dateofbirth != null ||
          userModel.LoggedUser!.dateofbirth != "") {
        UserDob = userModel.LoggedUser?.dateofbirth != null
            ? DateTime.parse(userModel.LoggedUser!.dateofbirth!).toString()
            : DateTime(1994, 4, 18).toString();

        initialDate = userModel.LoggedUser?.dateofbirth != null
            ? DateTime.parse(userModel.LoggedUser!.dateofbirth!)
            : DateTime(1994, 4, 18);

        log("userDOb ${initialDate.toString()}");
      }
      genderValue = userModel.LoggedUser!.gender;
      checked = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    UsersProviderClass userModel =
        Provider.of<UsersProviderClass>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [Text("actionno")],
          centerTitle: true,
          title: Container(
            width: 93,
            height: 5,
            child: !widget.isFromHome
                ? Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(1.00, 0.08),
                              end: Alignment(-1, -0.08),
                              colors: [backendColor, Color(0xFFFF8D41)],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 49,
                        top: 0,
                        child: Container(
                          width: 44,
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
                  )
                : null,
          ),
          leading: GestureDetector(
              onTap: () {
                if (!widget.isFromHome) {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return BoardingScreen();
                  }));
                } else {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset("assets/CaretLeft.svg"),
              ))),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 15, 0, 15),
                child: SizedBox(
                  width: 258,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Create ',
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 24,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                        TextSpan(
                          text: 'Private Profile',
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 23),
                child: SizedBox(
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        showModalBottomSheet(
                            context: context,
                            builder: (ctx) {
                              return StatefulBuilder(builder: (ctx, setSate) {
                                return Container(
                                    height: 200,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          onTap: () async {
                                            var pickedFile =
                                                await picker.pickImage(
                                                    source: ImageSource.camera,
                                                    imageQuality: 25);
                                            if (pickedFile != null) {
                                              cropAndAssign(pickedFile);
                                            }

                                            Navigator.pop(context);
                                          },
                                          leading: Icon(Icons.camera_alt),
                                          title: Text("Camera"),
                                        ),
                                        ListTile(
                                          onTap: () async {
                                            XFile? pickedFile =
                                                await picker.pickImage(
                                                    source: ImageSource.gallery,
                                                    imageQuality: 25);
                                            if (pickedFile != null) {
                                              cropAndAssign(pickedFile);
                                            }

                                            Navigator.pop(context);
                                          },
                                          leading: Icon(
                                            Icons.image_rounded,
                                            color: Colors.orange,
                                          ),
                                          title: Text("Gallery"),
                                        )
                                      ],
                                    ));
                              });
                            });
                      },
                      child: Stack(children: [
                        Container(
                            // margin: EdgeInsets.only(top: 20, bottom: 20),
                            // height: height * .2,
                            width: 89,
                            height: 89,
                            child:
                                // widget.isFromHome
                                //     ?
                                tempImagePrivate != null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            AssetImage("assets/profile.png"),
                                        foregroundImage:
                                            FileImage(tempImagePrivate!),
                                        // onForegroundImageError: (){}AssetImage("assets/profile.png"),
                                        radius: 60,
                                        backgroundColor: Colors.grey[300],
                                      )
                                    : widget.isFromHome &&
                                            userModel.LoggedUser
                                                    ?.privateProfilePicUrl !=
                                                null
                                        ? CommanWidgets().cacheProfileDisplay(
                                            userModel.LoggedUser!
                                                .privateProfilePicUrl!)
                                        : CircleAvatar(
                                            backgroundImage: AssetImage(
                                                "assets/profile.png"),
                                            radius: 60,
                                            backgroundColor: Colors.grey[300],
                                          )

                            //     : CircleAvatar(
                            //         radius: 60,
                            //         backgroundColor: Colors.grey[300],
                            //         child: image == null
                            //             ? (G.loggedinUser != null)
                            //                 ? null
                            //                 : Container(
                            //                     // height: 30,
                            //                     child: Image.asset(
                            //                       'assets/profile.png',
                            //                       fit: BoxFit.cover,
                            //                     ),
                            //                   )
                            //             : null,
                            //         backgroundImage: getImage()
                            // ),
                            ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: RuntimeStorage.instance.PrimaryOrange,
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: SvgPicture.asset("assets/editPic.svg")),
                        )
                      ]),
                    ),
                  ],
                ),
              ),
              Stack(children: [
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      'Full Name',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 14,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 7, 20, 16),
                    child: TextField(
                      textAlign: TextAlign.start,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 14,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w700,
                      ),
                      controller: _nameController,
                      // onChanged: (v) {
                      //   setState(() {
                      //     // _name = v;
                      //     _nameController.text = v;
                      //   });
                      // },
                      onTap: () {
                        _nameController.selection = TextSelection.collapsed(
                            offset: _nameController.text.length);
                      },
                      onSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_focusNode);
                      },
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                          border: _focusNode.hasFocus
                              ? OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(10))
                              : OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black
                                          .withOpacity(0.07999999821186066)),
                                  borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),
                // Positioned(
                //     right: 30,
                //     bottom: 20,
                //     child: Container(
                //         height: 30, child: Image.asset("assets/Group 632.png")))
              ]),
              Stack(children: [
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      'Date of birth',
                      style: TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 14,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 7, 20, 16),
                    child: DateTimeField(
  style: TextStyle(
    color: Color(0xFF303030),
    fontSize: 14,
    fontFamily: 'Helvetica',
    fontWeight: FontWeight.w700,
  ),
  initialValue: widget.isFromHome && widget.userData.dateofbirth != null
      ? _parseDate(widget.userData.dateofbirth.toString())
      : _defaultDate(),
  onChanged: (v) {
    setState(() {
      UserDob = v.toString();
    });
  },
  format: DateFormat("dd-MM-yyyy"),
  focusNode: _dobFocuseNode,
  decoration: InputDecoration(
    suffixIcon: Icon(Icons.calendar_today),
    border: _dobFocuseNode.hasFocus
        ? OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.circular(10))
        : OutlineInputBorder(
            borderRadius: BorderRadius.circular(10))),
  onShowPicker: (BuildContext context, DateTime? currentValue) async {
    var date = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        initialDate: currentValue ?? DateTime.now(),
        lastDate: DateTime.now());
    return date ?? currentValue;
  },
),
                    // DateTimeField(
                    //   style: TextStyle(
                    //     color: Color(0xFF303030),
                    //     fontSize: 14,
                    //     fontFamily: 'Helvetica',
                    //     fontWeight: FontWeight.w700,
                    //   ),
                    //   initialValue: widget.isFromHome
                    //       ? DateTime.parse(
                    //           widget.userData.dateofbirth.toString())
                    //       : initialDate,
                    //   onChanged: (v) {
                    //     setState(() {
                    //       UserDob = v.toString();
                    //     });
                    //   },
                    //   format: DateFormat("dd-MM-yyyy"),
                    //   focusNode: _dobFocuseNode,
                    //   decoration: InputDecoration(
                    //       suffixIcon: Icon(Icons.calendar_today),
                    //       // Container(
                    //       //     width: 10,
                    //       //     height: 10,
                    //       //     child: SvgPicture.asset("assets/calendar.svg")),

                    //       border: _dobFocuseNode.hasFocus
                    //           ? OutlineInputBorder(
                    //               borderSide: BorderSide(color: Colors.orange),
                    //               borderRadius: BorderRadius.circular(10))
                    //           : OutlineInputBorder(
                    //               borderRadius: BorderRadius.circular(10))),
                    //   onShowPicker:
                    //       (BuildContext context, DateTime? currentValue) async {
                    //     var date = await showDatePicker(
                    //         context: context,
                    //         firstDate: DateTime(1900),
                    //         initialDate: currentValue ?? DateTime.now(),
                    //         lastDate: DateTime.now());
                    //     if (date != null) {
                    //       return date;
                    //     } else {
                    //       return currentValue;
                    //     }
                    //   },
                    // ),
                  ),
                ),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 25, bottom: 12),
                        child: Text(
                          'Gender',
                          style: TextStyle(
                            color: Color(0xFF707070),
                            fontSize: 14,
                            fontFamily: 'Helvetica',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(13, 0, 20, 20),
                        child: Row(
                          children: [
                            for (var i in _gender)
                              Padding(
                                padding: const EdgeInsets.only(left: 7),
                                child: GestureDetector(
                                  child: Container(
                                    width: 90,
                                    height: 60,
                                    // padding: const EdgeInsets.all(25),
                                    decoration: ShapeDecoration(
                                      color: genderValue == "$i"
                                          ? Color(0xFFFFEADC)
                                          : Color(0xFFF5F5F5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$i',
                                        style: TextStyle(
                                          color: genderValue == "$i"
                                              ? backendColor
                                              : Colors.black,
                                          fontSize: 14,
                                          fontFamily: 'Helvetica',
                                          fontWeight: FontWeight.w400,
                                          height: 1.71,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      genderValue = "$i";
                                    });
                                  },
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: checked,
                            // activeColor: Colors.white,
                            onChanged: (value) {
                              setState(() {
                                checked = value ?? false;
                              });
                            },
                            checkColor: Colors.white,
                          ),
                          Text(
                            'I accept the ',
                            style: TextStyle(
                              color: Color(0xFF303030),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                          Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Color(0xFF3064FF),
                              fontSize: 14,
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                        ]),
                  ),
                ],
              ),
              SendingData
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 41, 20, 31),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: 350,
                              height: 54,
                              // padding: const EdgeInsets.symmetric(
                              //     horizontal: 10, vertical: 18),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: backendColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 41, 20, 31),
                      child: GestureDetector(
                        onTap: () async {
                          if (tempImagePrivate == null &&
                              widget.isFromHome == false) {
                            log("inside image null");
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  Colors.red, // Set the background color
                              content: Text(
                                "Please add a Profile Pic",
                                style: TextStyle(
                                  color: Colors.white, // Set the text color
                                ),
                              ),
                            ));
                            return;
                          }

                          if (_nameController.text == "") {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  Colors.red, // Set the background color
                              content: Text(
                                "Please enter Full Name",
                                style: TextStyle(
                                  color: Colors.white, // Set the text color
                                ),
                              ),
                            ));
                            return;
                          }
                          //validate dob
                          if (UserDob == "" ||
                              UserDob == DateTime.now().toString()) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  Colors.red, // Set the background color
                              content: Text(
                                "Please select a valid Date of birth",
                                style: TextStyle(
                                  color: Colors.white, // Set the text color
                                ),
                              ),
                            ));
                            return;
                          } else {
                            log("user dob value ${UserDob}");
                            int age = G().validateAge(DateTime.parse(UserDob));
                            log("the age $age");
                            if (age < 18) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                backgroundColor:
                                    Colors.red, // Set the background color
                                content: Text(
                                  "You must be at least 18 years old.",
                                  style: TextStyle(
                                    color: Colors.white, // Set the text color
                                  ),
                                ),
                              ));
                              return;
                            } else {
                              log("age is greated than 18 $age");
                            }
                          }
                          log("gender value" + genderValue.toString());
                          if (genderValue == "" || genderValue == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor:
                                  Colors.red, // Set the background color
                              content: Text(
                                "Please select a Gender",
                                style: TextStyle(
                                  color: Colors.white, // Set the text color
                                ),
                              ),
                            ));
                            return;
                          }

                          if (!checked) {
                            CommanWidgets().showSnackBar(
                                context,
                                "Please check the box to agree to terms & condition.",
                                Colors.red);
                            return;
                          }

                          setState(() {
                            SendingData = true;
                          });
                          if (tempImagePrivate != null) {
                           // Call the uploadImage method to get the final data
  var final_data = await ImageUpload().uploadImage(tempImagePrivate!);
  
  // Decode the JSON response
  final Map<String, dynamic> data = jsonDecode(final_data);
  final String url = data['url'];

  log("Uploaded Image URL: $url");
                              G.loggedinUser = UserDetail(
                                ///private info
                                privateName: _nameController.text,
                                phoneNumber: G.userPhoneNumber,
                                gender: genderValue,
                                privateProfilePicUrl: url,
                                dateofbirth: UserDob,

                                ///public info
                                publicProfilePicUrl: widget.isFromHome
                                    ? userModel.LoggedUser!.publicProfilePicUrl
                                    : "",
                                publicGender: widget.isFromHome
                                    ? userModel.LoggedUser!.publicGender
                                    : "",
                                publicName: widget.isFromHome
                                    ? userModel.LoggedUser!.publicName
                                    : "",

                                ///common
                                noCodeNumber: widget.isFromHome
                                    ? userModel.LoggedUser!.noCodeNumber
                                    : "",
                                role: "user",
                                lat: lat,
                                lon: long,
                              );
                              await userModel.addUser(G.loggedinUser, true);
                            
                            setState(() {
                              SendingData = false;
                            });
                            if (widget.isFromHome) {
                              Navigator.pop(context);
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PublicProfileScreen(
                                        isFromHome: false,
                                        userData: UserDetail(),
                                      )));
                            }
                          } else if (widget.isFromHome &&
                              tempImagePrivate == null) {
                            log("no image change and from home  ");
                            G.loggedinUser = UserDetail(
                              ///private info
                              privateName: _nameController.text,
                              phoneNumber: G.userPhoneNumber,
                              gender: genderValue,
                              privateProfilePicUrl: widget.isFromHome
                                  ? userModel.LoggedUser!.privateProfilePicUrl
                                  : "",
                              dateofbirth: UserDob,

                              ///public info
                              publicProfilePicUrl: widget.isFromHome
                                  ? userModel.LoggedUser!.publicProfilePicUrl
                                  : "",
                              publicGender: widget.isFromHome
                                  ? userModel.LoggedUser!.publicProfilePicUrl
                                  : "",
                              publicName: widget.isFromHome
                                  ? userModel.LoggedUser!.publicName
                                  : "",

                              ///common
                              noCodeNumber: widget.isFromHome
                                  ? userModel.LoggedUser!.noCodeNumber
                                  : "",
                              role: "user",
                              lat: lat,
                              lon: long,
                            );
                            await userModel.addUser(G.loggedinUser, true);
                            setState(() {
                              SendingData = false;
                            });

                            Navigator.pop(context);
                          }
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                width: 350,
                                height: 54,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 18),
                                decoration: ShapeDecoration(
                                  color: backendColor,
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
                                      widget.isFromHome ? "Update" : 'Next',
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
  DateTime _parseDate(String date) {
  try {
    return DateTime.parse(date);
  } catch (e) {
    return _defaultDate(); // Return default date if parsing fails
  }
}

/// ✅ Default date (April 18, 1994)
DateTime _defaultDate() {
  return DateTime(1994, 4, 18);
}
}