import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:koram_app/Helper/color.dart';
import '../Helper/Helper.dart';
import 'DatingBirthDay.dart';

class DatingPhotos extends StatefulWidget {
  const DatingPhotos({key});

  @override
  State<DatingPhotos> createState() => _DatingPhotosState();
}

class _DatingPhotosState extends State<DatingPhotos> {
  File? _selectedImage1;
  File? _selectedImage2;
  bool isCallingApi = false;
  Future<void> getFirstImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage1 = File(pickedImage.path);
      });
      checkIsUpload();
    }
  }

  checkIsUpload() {
    log("inside check is upload");
    if (_selectedImage2 != null && _selectedImage1 != null) {
      log("inside true");
      setState(() {
        isPicUploaded = true;
      });
    } else {
      log("from false ");
      setState(() {
        isPicUploaded = false;
      });
    }
  }

  Future<void> getSecondImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage2 = File(pickedImage.path);
      });

      checkIsUpload();
    }
  }

  bool isPicUploaded = false;
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
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                        ),
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
                          child: SizedBox(
                            width: 258,
                            child: Text(
                              'Add you first 2 photos',
                              style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 24,
                                fontFamily: 'Helvetica',
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                          )),
                    ],
                  ),
                  Text(
                    'You do you! Whether its with your buddies, eating your fav meal, or in a place you love 😍🥰',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 14,
                      fontFamily: 'Helvetica',
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  SizedBox(
                    height: 46,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          getFirstImage();
                        },
                        child: Container(
                          width: 155,
                          height: 165,
                          decoration: ShapeDecoration(
                            color: Color(0xFFF6F6F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _selectedImage1 != null
                                ? Image.file(
                                    _selectedImage1!,
                                    fit: BoxFit.cover,
                                    width: 155,
                                    height: 165,
                                  )
                                : Center(
                                    child: SvgPicture.asset("assets/plus.svg"),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          getSecondImage();
                        },
                        child: Container(
                          width: 155,
                          height: 165,
                          decoration: ShapeDecoration(
                            color: Color(0xFFF6F6F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _selectedImage2 != null
                                ? Image.file(
                                    _selectedImage2!,
                                    fit: BoxFit.cover,
                                    width: 155,
                                    height: 165,
                                  )
                                : Center(
                                    child: SvgPicture.asset("assets/plus.svg"),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
          child: isCallingApi
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                )
              : GestureDetector(
                  onTap: () async {
                    checkIsUpload();
                    if (isPicUploaded) {
                      setState(() {
                        isCallingApi = true;
                      });
                      String uploadUrl = G.HOST + "api/v1/saveDatingImg";
                      var request =
                          http.MultipartRequest('POST', Uri.parse(uploadUrl));
                      request.files.add(await http.MultipartFile.fromPath(
                          'files', _selectedImage1!.path));
                      request.files.add(await http.MultipartFile.fromPath(
                          'files', _selectedImage2!.path));
                      request.fields['userPhoneNumber'] =
                          '${G.userPhoneNumber}';
                      var response = await request.send();

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        // response.stream.transform(utf8.decoder).listen((value) {
                        //   log("response of uploaded file ");
                        //   print(json.decode(value));
                        //   Map<String, dynamic> jsonData =
                        //       jsonDecode(value.toString());
                        //
                        //   // Access the values
                        //   String message = jsonData['message'];
                        //   List<String> savedFiles =
                        //       List<String>.from(jsonData['savedFile']);
                        //   print('Files uploaded successfully');
                        //   savedFiles.forEach((filename) {
                        //     log("filename after upload dating  $filename");
                        //   });
                        // });
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return DatingBirthDay();
                        }));
                        setState(() {
                          isCallingApi = false;
                        });
                      } else {
                        setState(() {
                          isCallingApi = false;
                        });
                        print(
                            'Failed to upload files. Status code: ${response.statusCode}');
                      }
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            title: Text('Alert'),
                            content: Text('Please upload the images'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  // Close the dialog
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Opacity(
                    // opacity: isPicUploaded ? 1 : 0.50,
                    opacity: 1,
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
                    ),
                  )),
        ),
      ),
    );
  }
}
