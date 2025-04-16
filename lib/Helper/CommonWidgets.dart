import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koram_app/Helper/color.dart';

import 'Helper.dart';

class CommanWidgets {
  showSnackBar(BuildContext context, String message, Color color) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      content: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white, // Set the text color
          ),
        ),
      ),
      duration: Duration(seconds: 4),
    ));
  }

  cacheProfileDisplay(String imageUrl) {
    return ClipOval(
      child: CachedNetworkImage(
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: CircularProgressIndicator(
            value: progress.progress,
            color: Colors.transparent,
          ),
        ),
        imageUrl: G.HOST + "api/v1/images/" + imageUrl,
      ),
    );
  }

  LoggedUserProfileDisplay(String imageUrl) {
    return ClipOval(
      child: CachedNetworkImage(
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, progress) => Center(
          child: CircularProgressIndicator(
            value: progress.progress,
            color: Colors.transparent,
          ),
        ),
        imageUrl: G.HOST + "api/v1/images/" + imageUrl,
      ),
    );
  }

  Future<File?> cropAndAssign(XFile pickedFile, BuildContext context) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 10,
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
