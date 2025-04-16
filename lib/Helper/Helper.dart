import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koram_app/Helper/color.dart';

import 'package:koram_app/Models/User.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../Models/NewUserModel.dart';

class G {
  static const IP = "24.199.85.25";
  //static const IP = "192.168.1.10";
  
  // 192.168.29.215
  // static const HOST = "https://api.koram.in/";
  static const HOST = "http://${IP}:3000/";
  // static const HOST = "http://192.168.29.218:3000/";

  static var logedIn = false;
  static var fireBaseToken;
  static var userPhoneNumber;
  static var isNewUser = true;
  static var noCodeNumber;
  static UserDetail loggedinUser = UserDetail();
  static File? publicImageFile;
  static File? privateImageFile;
  static String? publicImageName;
  static String? privateImageName;
  static List<UserDetail>? FriendsList;
  static bool isInternet = false;
  static bool isOnChatroom = false;

  Future<dynamic> getOtp(String phoneNumber) async {
    log("in otp " + phoneNumber);
    final url = HOST + "api/v1/otp";

    try {
      var response = await http.post(Uri.parse(url),
          body: {"phone_number": phoneNumber.toString()}).timeout(
        Duration(seconds: 10), // Adjust the timeout duration as needed
      );

      log("Otp responseee${json.decode(response.statusCode.toString())}");

      return response.statusCode;
    } on TimeoutException catch (_) {
      // Handle timeout exception here
      log("TimeoutException: Server request timed out");
      return "timeout"; // Replace with your specific error code
    } catch (error) {
      // Handle other exceptions here
      log("Error in otp: $error");
      return 500; // Replace with your generic error code
    }
  }

  Future<bool> isInternetAvailable() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    log("conect ${connectivityResult}");
    if (connectivityResult == ConnectivityResult.none) {
      isInternet = false;
      return false; // No internet connection
    } else {
      isInternet = true;
      return true; // Internet connection is available
    }
  }

  static Future<dynamic> verifyOtp(String phone, String otp) async {
    final url = HOST + "api/v1/otp/verify";
    var verified = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log("otp req body details ${phone} otpp $otp  ${prefs.getString("FirebaseToken")}");

    http.Response response = await http.post(Uri.parse(url), body: {
      "phone_number": phone,
      "otp": otp,
      "firebaseToken": prefs.getString("FirebaseToken")
    });

    var responseData = jsonDecode(response.body);
    if (responseData["status"] == "success") {
      log("otp verify response data  ${responseData}");
      if (responseData["userDetail"] != null) {
        log("inside userDEtail not null");
        prefs.setString(
            "LoggedInUserData", json.encode(responseData["userDetail"]));
      }

      await prefs.setString('userId', G.userPhoneNumber);
      isNewUser = responseData['isNewUser'];
      if (!isNewUser) {
        await prefs.setBool('logedIn', true);

        if (responseData['userDetail'] != null &&
            responseData['userDetail']['public_profile_pic_url'] != null &&
            responseData['userDetail']['private_profile_pic_url'] != null) {
          await G().saveImageOnVerification(
              responseData['userDetail']['public_profile_pic_url'].toString(),
              "public");
          await G().saveImageOnVerification(
              responseData['userDetail']['private_profile_pic_url'].toString(),
              "private");
        } else {
          log("userr not found or no pic ");
        }
      }
      verified = true;
    }

    log("otp verification $verified");
    return verified;
  }

  saveUserDetailOffline(UserDetail u) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("LoggedInUserData", u.toJson().toString());
  }

  int validateAge(DateTime dob) {
    final today = DateTime.now();
    final age = today.year - dob.year;

    // Check if birthday has occurred this year
    final isBirthdayPassed = (today.month > dob.month) ||
        (today.month == dob.month && today.day >= dob.day);
    final adjustedAge = isBirthdayPassed ? age : age - 1;

    if (adjustedAge < 18) {
      return age;
    }
    return age; // Returns null if validation passes
  }
  // Future<void> saveImageToAppDirectory(
  //     File imageFile, String nameOfFile, String imageUrl) async {
  //   // Get the directory for the app's documents directory.
  //
  //   log("image to directory called for $nameOfFile  $imageUrl");
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   final Directory appDirectory = await getApplicationDocumentsDirectory();
  //   final String imagePath =
  //       '${appDirectory.path}/${nameOfFile}.${imageFile.path.split('.').last}';
  //
  //   final File newImage = await imageFile.copy(imagePath);
  //   if (nameOfFile == "private") {
  //     privateImageFile = newImage;
  //     privateImageName = imageUrl;
  //     prefs.setString('privateImageName', imageUrl);
  //     prefs.setString('privateImagePath', newImage.path);
  //   } else if (nameOfFile == "public") {
  //     publicImageFile = newImage;
  //     publicImageName = imageUrl;
  //     prefs.setString('publicImageName', imageUrl);
  //     prefs.setString('publicImagePath', newImage.path);
  //   }
  //   prefs.setString("$nameOfFile", imagePath);
  //   prefs.setString("${nameOfFile}Url", imageUrl);
  //   log("Saved Successfully $nameOfFile");
  // }

  Future<void> saveImageOnVerification(String imageName, String type) async {
    print("Saving image $imageName");
    try {
      String url = HOST + "api/v1/images/" + imageName;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.get(Uri.parse(url));
      final Uint8List imageData = response.bodyBytes;

      String extension = _getImageExtension(response.headers);
      if (extension.isEmpty) {
        extension = _getImageExtensionFromData(imageData);
      }

      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/$type$extension');
      await file.writeAsBytes(imageData);
      if (type == "private") {
        privateImageFile = file;
        privateImageName = imageName;
        await prefs.setString('privateImageName', imageName);
        await prefs.setString('privateImagePath', file.path);
      } else if (type == "public") {
        publicImageFile = file;
        publicImageName = imageName;
        await prefs.setString('publicImageName', imageName);
        await prefs.setString('publicImagePath', file.path);
      }
      log("saved details  names ${privateImageName}  ${publicImageName}  Paths  ${privateImageFile?.path}  ${publicImageFile?.path}");
      print('Image saved successfully');
    } catch (e) {
      print("Error in saving image: $e");
    }
  }

  String _getImageExtension(Map<String, String> headers) {
    // Check the content-type header to determine the image extension
    String contentType = headers['content-type'] ?? '';
    if (contentType.contains('image/jpeg')) {
      return '.jpg';
    } else if (contentType.contains('image/png')) {
      return '.png';
    } else if (contentType.contains('image/gif')) {
      return '.gif';
    }
    return ''; // Unknown or unsupported image type
  }

  String _getImageExtensionFromData(Uint8List imageData) {
    // Analyze the image data to determine the image extension
    if (imageData.lengthInBytes >= 2) {
      if (imageData[0] == 0xFF && imageData[1] == 0xD8) {
        return '.jpg';
      } else if (imageData[0] == 0x89 && imageData[1] == 0x50) {
        return '.png';
      } else if (imageData[0] == 0x47 && imageData[1] == 0x49) {
        return '.gif';
      }
    }
    return ''; // Unknown or unsupported image type
  }

  // File ReturnImageFile(String type){
  //
  //      File image;
  //    if (type=="private") {
  //      log("iamge private");
  //
  //     return image =  privateImageFile!;
  //
  //    }else
  //    {
  //      return image =  publicImageFile!;
  //    }
  //  }

  Future<File?> getImageFile(String type) async {
    log("get image file called ");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (privateImageFile == null && privateImageName == null) {
      var name = prefs.getString("privateImageName");
      var path = prefs.getString("privateImagePath");
      log("image name $name and path $path");
      return File(path!);
    }
    if (privateImageFile != null) {
      return privateImageFile;
    } else if (privateImageName != null) {
      log("Inside get image private Image name not null $privateImageName");
      final response = await http
          .get(Uri.parse(HOST + "api/v1/images/" + privateImageName!));

      final Uint8List imageData = response.bodyBytes;

      String extension = _getImageExtension(response.headers);
      if (extension.isEmpty) {
        extension = _getImageExtensionFromData(imageData);
      }

      final documentDirectory = await getApplicationDocumentsDirectory();
      log("directory pathh ${documentDirectory.path}/$type$extension}");
      final file = File('${documentDirectory.path}/$type$extension');
      await file.writeAsBytes(imageData);
      prefs.setString('privateImageName', privateImageName!);
      prefs.setString('privateImagePath', file.path);
      privateImageFile = file;
      return file;
    } else {
      log("both null");
      return null;
    }

    // String? filePath = prefs.getString(type);
    //
    // if (filePath != null && filePath.isNotEmpty) {
    //   return File(filePath);
    // } else {
    //   return null;
    // }
  }
  // static Future<List<UserDetail>> getContactUsers(List<String> phonenumbers) async {
  //   final url = HOST + "api/v1/geContactUsers";
  //
  //   var response =
  //   await http.post(Uri.parse(url), body: {"phoneNumbers": phonenumbers});
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> responseData = json.decode(response.body);
  //     log("contact list ${json.decode(response.body)}");
  //     List<UserDetail> users = responseData.map((json) => UserDetail.fromJson(json)).toList();
  //     return users;
  //   } else {
  //     log("error while fetching by contact users ");
  //     return [];
  //   }
  // }

  static Future<String> getTokenBynumber(String phone) async {
    final url = HOST + "api/v1/getTokenByNum";
    var receivedToken;
    var response =
        await http.post(Uri.parse(url), body: {"phone_number": phone});

    if (response.statusCode == 200) {
      log("inside success of firebase token ");
      receivedToken = jsonDecode(response.body)["firebaseToken"];
      log("received token $receivedToken");
      return receivedToken;
    } else {
      return "error";
    }
  }

  // Future<bool> isInternetAvailable() async {
  //   try {
  //     var url = HOST + "api/v1/users";
  //     final result = await http.post(Uri.parse(url));
  //     return true;
  //   } catch (_) {
  //     log("not connected to internet");
  //     return false;
  //   }
  // }

  addFriendByPhoneNumber(String phoneNumber, UserDetail friendDetail) async {
    if (phoneNumber == "") {
      return;
    }
    log("inside add friend ");
    http.Response response = await http.post(
        Uri.parse(HOST + "api/v1/addFriendByPhoneNumber"),
        body: {"userNumber": G.userPhoneNumber, "friendNumber": phoneNumber});
    if (response.statusCode == 200) {
      log("inside success of friend ");
      FriendsList?.add(friendDetail);
    } else {
      log("add friend status code not 200");
    }
  }

  Future<List<UserDetail>> getAllUser() async {
    final url = G.HOST + "api/v1/users";
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final List<UserDetail> userList =
          jsonList.map((json) => UserDetail.fromJson(json)).toList();
      return userList;
    } else {
      // Handle error
      return [];
      // throw Exception('Failed to load users');
    }
  }

  Future<List<UserDetail>> getUserByPhonenumber(
      List<String> phoneNumbers) async {
    final url = G.HOST + "api/v1/getUsersByNumber";
    var body = json.encode({"phoneNumbers": phoneNumbers});
    try {
      http.Response response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {
          "Content-Type": "application/json",
        },
      );
      log("the reponse ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<UserDetail> userList =
            jsonList.map((json) => UserDetail.fromJson(json)).toList();
        log("the received list ${userList.length}");
        return userList;
      } else {
        // Handle error
        return [];
        // throw Exception('Failed to load users');
      }
    } catch (e) {
      log("error in getUSer ${e}");
      return [];
    }
  }

  Future<List<UserDetail>> getNearBy(
      double lat, double lon, String maxDistance, String Gender) async {
    log("getNear By user called ${lat} $lon $maxDistance $Gender ${G.userPhoneNumber}");
    final url = G.HOST + "api/v1/nearBy";

    http.Response response = await http.post(Uri.parse(url), body: {
      "lat": lat.toString(),
      "lon": lon.toString(),
      "maxDistance": maxDistance.toString(),
      "gender": Gender,
      "phoneNumber": G.userPhoneNumber
    });
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final List<UserDetail> userList =
          jsonList.map((json) => UserDetail.fromJson(json)).toList();
      return userList;
    } else {
      // Handle error
      return [];
      // throw Exception('Failed to load users');
    }
  }

  Future<String> downloadImage(String imageUrl, String imageName) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/$imageName');
      file.writeAsBytesSync(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Failed to download image');
    }
  }

  Future<File?> cropImage(XFile pickedFile, BuildContext context) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 30,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: backendColor,
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
      return File(croppedFile.path);
    }
    return null;
  }
}

class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
  @override
  (int, int)? get data => (2, 3);

  @override
  String get name => '2x3 (customized)';
}
