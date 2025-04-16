import 'dart:ui';

import 'package:koram_app/Models/ChatRoom.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Helper/color.dart';
class RuntimeStorage {
  static final RuntimeStorage instance = RuntimeStorage._internal();

  factory RuntimeStorage() {
    return instance;
  }
  RuntimeStorage._internal();
  bool isLoggedin = false;
  bool isWeb = false;
  String chatIndex = "0";
  Color PrimaryOrange = backendColor;
  Map<String, dynamic>? pendingNavigation;

  var loggedinUSer;
  ChatRoom? selectedRoom;
}
