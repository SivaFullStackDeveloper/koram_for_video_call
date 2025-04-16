import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:koram_app/Helper/color.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Screens/HomeScreen.dart';
import 'package:koram_app/Screens/NewProfileScreen.dart';
import 'package:koram_app/Screens/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'dart:io' as Io;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../Helper/CommonWidgets.dart';
import '../Helper/LocationServices.dart';
import '../Helper/RuntimeStorage.dart';

class PublicProfileScreen extends StatefulWidget {
  var isFromHome = false;
  UserDetail? userData;
  PublicProfileScreen(
      {Key? key, required this.isFromHome, required this.userData})
      : super(key: key);

  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState();
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  var _focusNode = new FocusNode();
  ImagePicker picker = ImagePicker();

  List<UserDetail> userfETCHED = [];
  TextEditingController _nameController = TextEditingController();
  File? tempImageFile;
  var lat = 0.0;
  var long = 0.0;
  bool SendingData = false;
  final _gender = ["Male", "Female", "Other"];
  var genderValue;
  var name;
  bool checked = false;
  bool ProfilePicUser = true;
  String fromHomeImgUrl = "";

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
        tempImageFile = File(croppedFile.path);
      });
    }
  }

  @override
  void initState() {
    _focusNode.addListener(_focusListener);
    tempImageFile = null;
    assignLatLong();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    UsersProviderClass userPro =
        Provider.of<UsersProviderClass>(context, listen: false);

    if (widget.isFromHome) {
      log("initializing public scren");

      _nameController.text = userPro.LoggedUser?.publicName ?? "No Name";

      genderValue = userPro.LoggedUser?.publicGender;
      checked = true;
    }
    log("user profile ${userPro.LoggedUser?.publicProfilePicUrl}");
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.removeListener(_focusListener);
    super.dispose();
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
      if (mounted) {
        await Provider.of<UsersProviderClass>(context, listen: false)
            .addLocation(position.latitude, position.longitude);
      }

      log("The location service is already on. from private profile screen");
    }
  }

  @override
  Widget build(BuildContext context) {
    UsersProviderClass userPro =
        Provider.of<UsersProviderClass>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: SvgPicture.asset("assets/CaretLeft.svg"),
            ),
          ),
          centerTitle: true,
          title: !widget.isFromHome
              ? Container(
                  width: 93,
                  height: 5,
                  child: Stack(
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
                    ],
                  ),
                )
              : null),
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
                          text: 'Public Profile',
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
                                            XFile? i = await picker.pickImage(
                                                source: ImageSource.camera);
                                            if (i != null) {
                                              cropAndAssign(i);
                                            }

                                            Navigator.pop(context);
                                          },
                                          leading: Icon(Icons.camera_alt),
                                          title: Text("Camera"),
                                        ),
                                        ListTile(
                                          onTap: () async {
                                            var i = await picker.pickImage(
                                                source: ImageSource.gallery);
                                            if (i != null) {
                                              cropAndAssign(i);
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(children: [
                            Container(
                                // margin: EdgeInsets.only(top: 20, bottom: 20),
                                // height: height * .2,
                                width: 89,
                                height: 89,
                                child: tempImageFile != null
                                    ? CircleAvatar(
                                        backgroundImage:
                                            AssetImage("assets/profile.png"),
                                        foregroundImage:
                                            FileImage(tempImageFile!),
                                        // onForegroundImageError: (){}AssetImage("assets/profile.png"),
                                        radius: 60,
                                        backgroundColor: Colors.grey[300],
                                      )
                                    : widget.isFromHome &&
                                            userPro.LoggedUser
                                                    ?.publicProfilePicUrl !=
                                                null
                                        ? CommanWidgets().cacheProfileDisplay(
                                            userPro.LoggedUser!
                                                .publicProfilePicUrl!)
                                        : CircleAvatar(
                                            backgroundImage: AssetImage(
                                                "assets/profile.png"),
                                            radius: 60,
                                            backgroundColor: Colors.grey[300],
                                          )
                                // : CircleAvatar(
                                //     radius: 60,
                                //     backgroundColor: Colors.grey[300],
                                //     child: (image == null &&
                                //             G.loggedinUser != null)
                                //         ? (G.loggedinUser
                                //                     .publicProfilePicUrl !=
                                //                 null)
                                //             ? null
                                //             : Container(
                                //                 // height: 30,
                                //                 child: Image.asset(
                                //                   'assets/profile.png',
                                //                 ),
                                //               )
                                //         : null,
                                //     backgroundImage: getImage()),
                                ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                  padding: EdgeInsets.all(2.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color:
                                        RuntimeStorage.instance.PrimaryOrange,
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child:
                                      SvgPicture.asset("assets/editPic.svg")),
                            )
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Stack(children: [
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      'Public Name',
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
                      controller: _nameController,
                      // onSubmitted: (value) {
                      //   log("onsubmit $value");
                      //   name = value;
                      //
                      //   // FocusScope.of(context).requestFocus(_focusNode);
                      // },
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 14,
                        fontFamily: 'Helvetica',
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: (value) {
                        log("test $value");
                        name = value;
                      },
                      // focusNode: _focusNode,
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
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
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
                          if (tempImageFile == null &&
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
                                "Please enter Public Name",
                                style: TextStyle(
                                  color: Colors.white, // Set the text color
                                ),
                              ),
                            ));
                            return;
                          }
                          //validate dob
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
                          if (tempImageFile != null) {
                            log("inside iamge not null");
                            var stream = http.ByteStream.fromBytes(
                                tempImageFile!.readAsBytesSync());

                            var length = await tempImageFile!.length();
                            var uri = Uri.parse(G.HOST + "api/v1/images");
                            var request =
                                new http.MultipartRequest("POST", uri);
                            var multipartFile = new http.MultipartFile(
                                'myFile', stream, length,
                                filename: path.basename(tempImageFile!.path));
                            request.files.add(multipartFile);
                            var response = await request
                                .send()
                                .timeout(Duration(seconds: 60));
                            log("the response ${response}");
                            response.stream
                                .transform(utf8.decoder)
                                .listen((value) async {
                              // await G().saveImageToAppDirectory(tempImageFile!,
                              //     'public', json.decode(value)[0]["mediaName"]);
                              G.loggedinUser = UserDetail(
                                  noCodeNumber: G.noCodeNumber.toString(),
                                  gender: G.loggedinUser.gender,
                                  publicGender: genderValue,
                                  privateProfilePicUrl:
                                      G.loggedinUser.privateProfilePicUrl,
                                  publicProfilePicUrl: json.decode(value)[0]
                                      ["mediaName"],
                                  publicName: _nameController.text,
                                  sId: G.loggedinUser.sId ?? "",
                                  friendList: [],
                                  privateName: G.loggedinUser.privateName,
                                  phoneNumber: G.userPhoneNumber,
                                  role: G.loggedinUser.role,
                                  dateofbirth: G.loggedinUser.dateofbirth,
                                  lat: lat,
                                  lon: long,
                                  story: G.loggedinUser.story);
                              var res =
                                  await userPro.addUser(G.loggedinUser, false);
                              if (res == 200) {
                                log("the user added successfully ");
                                if (widget.isFromHome) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => HomeScreen()));
                                }
                              } else {
                                CommanWidgets().showSnackBar(
                                    context,
                                    "There was an error please try  again later",
                                    Colors.red);
                                return;
                              }
                            });
                          } else if (tempImageFile == null &&
                              widget.isFromHome == true) {
                            G.loggedinUser = UserDetail(
                                noCodeNumber: G.noCodeNumber.toString(),
                                gender: G.loggedinUser.gender,
                                publicGender: genderValue,
                                privateProfilePicUrl:
                                    G.loggedinUser.privateProfilePicUrl,
                                publicProfilePicUrl:
                                    G.loggedinUser.privateProfilePicUrl,
                                publicName: _nameController.text,
                                sId: G.loggedinUser.sId ?? "",
                                friendList: [],
                                privateName: G.loggedinUser.privateName,
                                phoneNumber: G.userPhoneNumber,
                                role: G.loggedinUser.role,
                                dateofbirth: G.loggedinUser.dateofbirth,
                                lat: lat,
                                lon: long,
                                story: G.loggedinUser.story);
                            var res =
                                await userPro.addUser(G.loggedinUser, false);
                            log("the response status code for addd user with o image change ${res}");
                          }

                          setState(() {
                            SendingData = false;
                          });
                          if (widget.isFromHome) {
                            Navigator.pop(context);
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                          }

                          // );
                        },
                        child: Row(
                          children: [
                            Expanded(
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.isFromHome ? 'Update' : 'Submit',
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
}


// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'package:koram_app/Helper/color.dart';
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:koram_app/Helper/Helper.dart';
// import 'package:koram_app/Models/NewUserModel.dart';
// import 'package:koram_app/Models/User.dart';
// import 'package:koram_app/Screens/HomeScreen.dart';
// import 'package:koram_app/Screens/NewProfileScreen.dart';
// import 'package:koram_app/Screens/SplashScreen.dart';
// import 'package:provider/provider.dart';
// import 'dart:io' as Io;
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;

// import '../Helper/CommonWidgets.dart';
// import '../Helper/LocationServices.dart';
// import '../Helper/RuntimeStorage.dart';

// class PublicProfileScreen extends StatefulWidget {
//   var isFromHome = false;
//   UserDetail? userData;
//   PublicProfileScreen(
//       {Key? key, required this.isFromHome, required this.userData})
//       : super(key: key);

//   @override
//   _PublicProfileScreenState createState() => _PublicProfileScreenState();
// }

// class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
//   @override
//   (int, int)? get data => (2, 3);

//   @override
//   String get name => '2x3 (customized)';
// }

// class _PublicProfileScreenState extends State<PublicProfileScreen> {
//   var _focusNode = new FocusNode();
//   ImagePicker picker = ImagePicker();

//   List<UserDetail> userfETCHED = [];
//   TextEditingController _nameController = TextEditingController();
//   File? tempImageFile;
//   var lat = 0.0;
//   var long = 0.0;
//   bool SendingData = false;
//   final _gender = ["Male", "Female", "Other"];
//   var genderValue;
//   var name;
//   bool checked = false;
//   bool ProfilePicUser = true;
//   String fromHomeImgUrl = "";

//   _focusListener() {
//     setState(() {});
//   }
//   Future<void> cropAndAssign(XFile pickedFile) async {
//     CroppedFile? croppedFile = await ImageCropper().cropImage(
//       sourcePath: pickedFile.path,
//       compressFormat: ImageCompressFormat.jpg,
//       compressQuality: 10,
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Cropper',
//           toolbarColor: Colors.deepOrange,
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.square,
//           lockAspectRatio: false,
//           aspectRatioPresets: [
//             CropAspectRatioPreset.original,
//             CropAspectRatioPreset.square,
//             CropAspectRatioPreset.ratio4x3,
//             CropAspectRatioPresetCustom(),
//           ],
//         ),
//         IOSUiSettings(
//           title: 'Cropper',
//           aspectRatioPresets: [
//             CropAspectRatioPreset.original,
//             CropAspectRatioPreset.square,
//             CropAspectRatioPreset.ratio4x3,
//             CropAspectRatioPresetCustom(),
//           ],
//         ),
//         WebUiSettings(
//           context: context,
//           presentStyle: WebPresentStyle.dialog,
//           size: const CropperSize(
//             width: 520,
//             height: 520,
//           ),
//         ),
//       ],
//     );

//     if (croppedFile != null) {
//       setState(() {
//         tempImageFile = File(croppedFile.path);
//       });
//     }
//   }

//   @override
//   void initState() {
//     _focusNode.addListener(_focusListener);
//     tempImageFile = null;
//     assignLatLong();
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() {
//     final userPro = Provider.of<UsersProviderClass>(context, listen: false);

//     if (widget.isFromHome) {
//       log("initializing public screen");
//       _nameController.text = userPro.LoggedUser?.publicName ?? "No Name";
//       genderValue = userPro.LoggedUser?.publicGender;
//       checked = true;
//     }
//     log("user profile ${userPro.LoggedUser?.publicProfilePicUrl}");
//     super.didChangeDependencies();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _focusNode.removeListener(_focusListener);
//     super.dispose();
//   }

//   Future<void> assignLatLong() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // Request user to enable location services
//       serviceEnabled = await Geolocator.openLocationSettings();
//       if (!serviceEnabled) {
//         log("Location service is not enabled");
//       } else {
//         Position position = await LocationService().getCurrentLocation();
//         lat = position.latitude;
//         long = position.longitude;
//         await Provider.of<UsersProviderClass>(context, listen: false)
//             .addLocation(position.latitude, position.longitude);
//         log("Location service turned on");
//       }
//     } else {
//       Position position = await LocationService().getCurrentLocation();
//       lat = position.latitude;
//       long = position.longitude;
//       if (mounted) {
//         await Provider.of<UsersProviderClass>(context, listen: false)
//             .addLocation(position.latitude, position.longitude);
//       }
//       log("Location service is already on");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userPro = Provider.of<UsersProviderClass>(context, listen: true);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         leading: GestureDetector(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(11),
//             child: SvgPicture.asset("assets/CaretLeft.svg"),
//           ),
//         ),
//         centerTitle: true,
//         title: !widget.isFromHome
//             ? Container(
//                 width: 93,
//                 height: 5,
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       left: 0,
//                       top: 0,
//                       child: Container(
//                         width: 44,
//                         height: 5,
//                         decoration: ShapeDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment(1.00, 0.08),
//                             end: Alignment(-1, -0.08),
//                             colors: [backendColor, Color(0xFFFF8D41)],
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(34),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       left: 49,
//                       top: 0,
//                       child: Container(
//                         width: 44,
//                         height: 5,
//                         decoration: ShapeDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment(1.00, 0.08),
//                             end: Alignment(-1, -0.08),
//                             colors: [backendColor, Color(0xFFFF8D41)],
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(34),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             : null,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header and description
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(28, 15, 0, 15),
//                 child: SizedBox(
//                   width: 258,
//                   child: Text.rich(
//                     TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Create ',
//                           style: TextStyle(
//                             color: Color(0xFF303030),
//                             fontSize: 24,
//                             fontFamily: 'Helvetica',
//                             fontWeight: FontWeight.w700,
//                             height: 0,
//                           ),
//                         ),
//                         TextSpan(
//                           text: 'Public Profile',
//                           style: TextStyle(
//                             color: backendColor,
//                             fontSize: 24,
//                             fontFamily: 'Helvetica',
//                             fontWeight: FontWeight.w700,
//                             height: 0,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(28, 0, 28, 23),
//                 child: SizedBox(
//                   width: 334,
//                   child: Text(
//                     'Lorem Ipsum is simply dummy text of the printing and typesetting industry',
//                     style: TextStyle(
//                       color: Color(0xFF707070),
//                       fontSize: 14,
//                       fontFamily: 'Helvetica',
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//               ),
//               // Profile picture section with update trigger
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () async {
//                         // Opens a bottom sheet for image source selection
//                         showModalBottomSheet(
//                           context: context,
//                           builder: (ctx) {
//                             return StatefulBuilder(builder: (ctx, setSate) {
//                               return Container(
//                                 height: 200,
//                                 child: Column(
//                                   children: [
//                                     ListTile(
//                                       onTap: () async {
//                                         XFile? i = await picker.pickImage(
//                                             source: ImageSource.camera);
//                                         if (i != null) {
//                                           await cropAndAssign(i);
//                                         }
//                                         Navigator.pop(context);
//                                       },
//                                       leading: Icon(Icons.camera_alt),
//                                       title: Text("Camera"),
//                                     ),
//                                     ListTile(
//                                       onTap: () async {
//                                         var i = await picker.pickImage(
//                                             source: ImageSource.gallery);
//                                         if (i != null) {
//                                           await cropAndAssign(i);
//                                         }
//                                         Navigator.pop(context);
//                                       },
//                                       leading: Icon(
//                                         Icons.image_rounded,
//                                         color: Colors.orange,
//                                       ),
//                                       title: Text("Gallery"),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             });
//                           },
//                         );
//                       },
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Stack(
//                             children: [
//                               Container(
//                                 width: 89,
//                                 height: 89,
//                                 child: tempImageFile != null
//                                     ? CircleAvatar(
//                                         backgroundImage:
//                                             AssetImage("assets/profile.png"),
//                                         foregroundImage: FileImage(tempImageFile!),
//                                         radius: 60,
//                                         backgroundColor: Colors.grey[300],
//                                       )
//                                     : widget.isFromHome &&
//                                             userPro.LoggedUser?.publicProfilePicUrl !=
//                                                 null
//                                         ? CommanWidgets().cacheProfileDisplay(
//                                             userPro.LoggedUser!.publicProfilePicUrl!)
//                                         : CircleAvatar(
//                                             backgroundImage: AssetImage("assets/profile.png"),
//                                             radius: 60,
//                                             backgroundColor: Colors.grey[300],
//                                           ),
//                               ),
//                               Positioned(
//                                 right: 8,
//                                 top: 8,
//                                 child: Container(
//                                   padding: EdgeInsets.all(2.0),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10.0),
//                                     color: RuntimeStorage.instance.PrimaryOrange,
//                                   ),
//                                   constraints: BoxConstraints(
//                                     minWidth: 16,
//                                     minHeight: 16,
//                                   ),
//                                   child: SvgPicture.asset("assets/editPic.svg"),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Public name text field
//               Stack(
//                 children: [
//                   ListTile(
//                     title: Padding(
//                       padding: const EdgeInsets.only(left: 25),
//                       child: Text(
//                         'Public Name',
//                         style: TextStyle(
//                           color: Color(0xFF707070),
//                           fontSize: 14,
//                           fontFamily: 'Helvetica',
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ),
//                     subtitle: Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 7, 20, 16),
//                       child: TextField(
//                         controller: _nameController,
//                         style: TextStyle(
//                           color: Color(0xFF303030),
//                           fontSize: 14,
//                           fontFamily: 'Helvetica',
//                           fontWeight: FontWeight.w700,
//                         ),
//                         onChanged: (value) {
//                           log("Name change: $value");
//                           name = value;
//                         },
//                         decoration: InputDecoration(
//                           border: _focusNode.hasFocus
//                               ? OutlineInputBorder(
//                                   borderSide: BorderSide(color: Colors.orange),
//                                   borderRadius: BorderRadius.circular(10))
//                               : OutlineInputBorder(
//                                   borderSide: BorderSide(
//                                       color: Colors.black.withOpacity(0.08)),
//                                   borderRadius: BorderRadius.circular(10)),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               // Gender selection buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(left: 25, bottom: 12),
//                         child: Text(
//                           'Gender',
//                           style: TextStyle(
//                             color: Color(0xFF707070),
//                             fontSize: 14,
//                             fontFamily: 'Helvetica',
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(13, 0, 20, 20),
//                         child: Row(
//                           children: [
//                             for (var i in _gender)
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 7),
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       genderValue = i;
//                                     });
//                                   },
//                                   child: Container(
//                                     width: 90,
//                                     height: 60,
//                                     decoration: ShapeDecoration(
//                                       color: genderValue == i
//                                           ? Color(0xFFFFEADC)
//                                           : Color(0xFFF5F5F5),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(16),
//                                       ),
//                                     ),
//                                     child: Center(
//                                       child: Text(
//                                         i,
//                                         style: TextStyle(
//                                           color: genderValue == i
//                                               ? backendColor
//                                               : Colors.black,
//                                           fontSize: 14,
//                                           fontFamily: 'Helvetica',
//                                           fontWeight: FontWeight.w400,
//                                           height: 1.71,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//               // Terms & Conditions checkbox
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 24.0),
//                     child: Row(
//                       children: [
//                         Checkbox(
//                           value: checked,
//                           onChanged: (value) {
//                             setState(() {
//                               checked = value ?? false;
//                             });
//                           },
//                           checkColor: Colors.white,
//                         ),
//                         Text(
//                           'I accept the ',
//                           style: TextStyle(
//                             color: Color(0xFF303030),
//                             fontSize: 14,
//                             fontFamily: 'Helvetica',
//                             fontWeight: FontWeight.w400,
//                             height: 1.43,
//                           ),
//                         ),
//                         Text(
//                           'Terms & Conditions',
//                           style: TextStyle(
//                             color: Color(0xFF3064FF),
//                             fontSize: 14,
//                             fontFamily: 'Helvetica',
//                             fontWeight: FontWeight.w400,
//                             height: 1.43,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               // Submission button and loading indicator
//               if (SendingData) Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 41, 20, 31),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Container(
//                               height: 54,
//                               decoration: ShapeDecoration(
//                                 color: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child: Center(
//                                 child: CircularProgressIndicator(
//                                   color: backendColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ) else Padding(
//                       padding: const EdgeInsets.fromLTRB(20, 41, 20, 31),
//                       child: GestureDetector(
//                         onTap: () async {
//                           // Validate inputs
//                           if (tempImageFile == null && widget.isFromHome == false) {
//                             log("No image selected");
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 backgroundColor: Colors.red,
//                                 content: Text(
//                                   "Please add a Profile Pic",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             );
//                             return;
//                           }

//                           if (_nameController.text.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 backgroundColor: Colors.red,
//                                 content: Text(
//                                   "Please enter Public Name",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             );
//                             return;
//                           }

//                           if (genderValue == null || genderValue!.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 backgroundColor: Colors.red,
//                                 content: Text(
//                                   "Please select a Gender",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             );
//                             return;
//                           }

//                           if (!checked) {
//                             CommanWidgets().showSnackBar(
//                               context,
//                               "Please check the box to agree to terms & condition.",
//                               Colors.red,
//                             );
//                             return;
//                           }

//                           try {
//                             setState(() {
//                               SendingData = true;
//                             });

//                             // If there is a new image to upload
//                             if (tempImageFile != null) {
//                               log("Uploading new image");
//                               var stream = http.ByteStream((await tempImageFile!.readAsBytes()) as Stream<List<int>>);
//                               var length = await tempImageFile!.length();
//                               var uri = Uri.parse(G.HOST + "api/v1/images");
//                               var request = http.MultipartRequest("POST", uri);
//                               var multipartFile = http.MultipartFile('myFile', stream, length,
//                                   filename: path.basename(tempImageFile!.path));
//                               request.files.add(multipartFile);

//                               // Upload image and await full response
//                               var response = await request.send().timeout(Duration(seconds: 60));
//                               if (response.statusCode != 200) {
//                                 throw Exception("Image upload failed with status code ${response.statusCode}");
//                               }
//                               final responseString = await response.stream.bytesToString();
//                               final decodedResponse = json.decode(responseString);
                              
//                               // Update logged user with new image URL
//                               G.loggedinUser = UserDetail(
//                                 noCodeNumber: G.noCodeNumber.toString(),
//                                 gender: G.loggedinUser.gender,
//                                 publicGender: genderValue,
//                                 privateProfilePicUrl: G.loggedinUser.privateProfilePicUrl,
//                                 publicProfilePicUrl: decodedResponse[0]["mediaName"],
//                                 publicName: _nameController.text,
//                                 sId: G.loggedinUser.sId ?? "",
//                                 friendList: [],
//                                 privateName: G.loggedinUser.privateName,
//                                 phoneNumber: G.userPhoneNumber,
//                                 role: G.loggedinUser.role,
//                                 dateofbirth: G.loggedinUser.dateofbirth,
//                                 lat: lat,
//                                 lon: long,
//                                 story: G.loggedinUser.story,
//                               );

//                               var res = await userPro.addUser(G.loggedinUser, false);
//                               if (res != 200) {
//                                 CommanWidgets().showSnackBar(
//                                   context,
//                                   "There was an error, please try again later",
//                                   Colors.red,
//                                 );
//                                 return;
//                               }
//                             } 
//                             // For cases when updating without an image change
//                             else if (tempImageFile == null && widget.isFromHome == true) {
//                               G.loggedinUser = UserDetail(
//                                 noCodeNumber: G.noCodeNumber.toString(),
//                                 gender: G.loggedinUser.gender,
//                                 publicGender: genderValue,
//                                 privateProfilePicUrl: G.loggedinUser.privateProfilePicUrl,
//                                 publicProfilePicUrl: G.loggedinUser.privateProfilePicUrl,
//                                 publicName: _nameController.text,
//                                 sId: G.loggedinUser.sId ?? "",
//                                 friendList: [],
//                                 privateName: G.loggedinUser.privateName,
//                                 phoneNumber: G.userPhoneNumber,
//                                 role: G.loggedinUser.role,
//                                 dateofbirth: G.loggedinUser.dateofbirth,
//                                 lat: lat,
//                                 lon: long,
//                                 story: G.loggedinUser.story,
//                               );
//                               var res = await userPro.addUser(G.loggedinUser, false);
//                               log("User updated without new image. Status code: $res");
//                             }

//                             // Navigate to next screen based on source
//                             if (widget.isFromHome) {
//                               Navigator.pop(context);
//                             } else {
//                               Navigator.of(context).push(MaterialPageRoute(
//                                   builder: (context) => HomeScreen()));
//                             }
//                           } catch (e) {
//                             log("Error updating profile: $e");
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 backgroundColor: Colors.red,
//                                 content: Text("Error updating profile, please try again"),
//                               ),
//                             );
//                           } finally {
//                             setState(() {
//                               SendingData = false;
//                             });
//                           }
//                         },
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Container(
//                                 height: 54,
//                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
//                                 decoration: ShapeDecoration(
//                                   color: backendColor,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     widget.isFromHome ? 'Update' : 'Submit',
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontFamily: 'Helvetica',
//                                       fontWeight: FontWeight.w700,
//                                       height: 0,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
