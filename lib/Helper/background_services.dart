import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:koram_app/Helper/color.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BackgroundService {
  static const String isolateName = "color_fetch_isolate";
  static ReceivePort receivePort = ReceivePort();

  static Future<void> initialize() async {
    IsolateNameServer.registerPortWithName(receivePort.sendPort, isolateName);
    receivePort.listen((message) {
      print("Received message: \$message");
    });

    await fetchColorAndSave();
    Timer.periodic(Duration(seconds: 1), (Timer t) async {
      await fetchColorAndSave();
      await getStoredColor();
    });

    await getStoredColor();
  }

  static Future<void> fetchColorAndSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int lastUpdated = prefs.getInt("lastUpdateTime") ?? 0;
      int currentTime = DateTime.now().millisecondsSinceEpoch;

      // if (currentTime - lastUpdated < 24 * 60 * 60 * 1000) {
      //   print("Skipping API call. Last update was less than 24 hours ago.");
      //   return;
      // }

      if (currentTime - lastUpdated < 60 * 1000) {
        print("Skipping API call. Last update was less than 1 minute ago.");
        return;
      }

      final response =
          await http.get(Uri.parse('http://24.199.85.25:3300/get-color'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String colorHex = data["color"];

        Database db = await _getDatabase();
        await db.insert(
          'colors',
          {'color': colorHex, 'timestamp': DateTime.now().toIso8601String()},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await prefs.setInt("lastUpdateTime", currentTime);
        print("Saved color: \$colorHex");
      } else {
        print("Failed to fetch color. Status Code: \${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching color: \$e");
    }
  }

  static Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'colors.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE colors (id INTEGER PRIMARY KEY, color TEXT, timestamp TEXT)",
        );
      },
      version: 1,
    );
  }

  static Future<String?> getLatestColor() async {
    try {
      Database db = await _getDatabase();
      List<Map<String, dynamic>> result = await db.query(
        'colors',
        orderBy: 'timestamp DESC',
        limit: 1,
      );
      if (result.isNotEmpty) {
        return result.first['color'];
      }
    } catch (e) {
      print("Error retrieving color: \$e");
    }
    return null;
  }

  static Future<Color> getStoredColor() async {
    String? colorHex = await getLatestColor();
    if (colorHex != null) {
      backendColor = Color(int.parse(colorHex.replaceFirst('#', '0xff')));
      return backendColor;
    }
    return backendColor; // Default color if no color is found
  }
}



class Audio {
  AudioPlayer? _audioPlayer;

  Audio() {
    _audioPlayer = AudioPlayer();
  }

  void playRingingSound() async {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();
    }

    // await _audioPlayer!.setReleaseMode(ReleaseMode.loop);
    // await _audioPlayer!.play(AssetSource('audio/ringing.wav'));
  }

  void stopAudio() async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
      await _audioPlayer!.release();
      await _audioPlayer!.dispose();
      _audioPlayer = null;
    }
  }
}
