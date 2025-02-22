import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:koram_app/Models/Message.dart';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../Models/NewUserModel.dart';
import 'Helper.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static var _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "Koram.db");
    return await openDatabase(path, version: 3, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE message ("
      "messageId TEXT,"
          "sentBy TEXT,"
          "sentTo TEXT,"
          "message Text,"
          "time TEXT,"
          "isDelivered TEXT,"
          "isSeen TEXT,"
          "fileName TEXT,"
      "groupId TEXT,"
      "type TEXT,"
      "groupName TEXT,"
          "messageStatus TEXT"
          ")");
      await db.execute('''
    CREATE TABLE userDetails (
      lat REAL,
      lon REAL,
      role TEXT,
      friendList TEXT,
      sId TEXT PRIMARY KEY,
      phoneNumber TEXT,
      iV INTEGER,
      publicName TEXT,
      createdAt TEXT,
      dateofbirth TEXT,
      gender TEXT,
      privateName TEXT,
      noCodeNumber REAL,
      privateProfilePicUrl TEXT,
      publicGender TEXT,
      publicProfilePicUrl TEXT,
      updatedAt TEXT,
      story TEXT,
      firebaseToken TEXT,
      recieveTime TEXT,
      latestMessage TEXT,
      seenStory TEXT,
      newMessage INTEGER,
      localImage TEXT
    )
  ''');
      await db.execute('CREATE UNIQUE INDEX idx_userDetails_phoneNumber ON userDetails (phoneNumber)');
    });
  }


  newPrivateMessage(PrivateMessage newPrivateMessage) async {
    final db = await database;
    //get the biggest id in the table
    // var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM message");
    // int id = table.first["id"] as int;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into message (messageId,sentBy,sentTo,message,time,isDelivered,isSeen,fileName,groupId,type,groupName,messageStatus)"
        " VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
        [newPrivateMessage.messageId,
          newPrivateMessage.sentBy,
          newPrivateMessage.sentTo,
          newPrivateMessage.message,
          newPrivateMessage.time.toString(),
          newPrivateMessage.isDelivered,
          newPrivateMessage.isSeen,
          newPrivateMessage.fileName,
          newPrivateMessage.groupId,
          newPrivateMessage.type,
          newPrivateMessage.groupName
        ]);
    log("add the messsage to database ");
    return raw;
  }
  updateMessageStatus(String messageId, String newStatus) async {
    log("update message status called ");
    final db = await database;

    var result = await db.rawUpdate(
      "UPDATE message SET "
          "messageStatus = ? "
          "WHERE messageId = ?",
      [
        newStatus,
        messageId
      ],
    );
    return result;
  }

  updateListMessageStatus(List<String> messageIds, String newStatus) async {
    log("update List message status called ");
    try{
      final db = await database;
      messageIds.forEach((yo)async
      {
        await db.rawUpdate(
          "UPDATE message SET "
              "messageStatus = ? "
              "WHERE messageId = ?",
          [
            newStatus,
            yo
          ],
        );
      });

      return true;
    }catch(e)
    {
      log("got an error while updating list of iunsent message");
      return false;
    }

  }


  Future<bool> updateListMessageIsSeen(String phoneNumber) async {
    final db = await database;
   log("the update fucntion called ${phoneNumber}");
    // Update the isSeen value for messages sent by the given phone number
    int rowsAffected = await db.update(
      'message',
      {'isSeen': 'true'}, // Update 'isSeen' to true (assuming it's a string; use 1 if it's an integer)
      where: 'sentBy = ?',
      whereArgs: [phoneNumber],
    );
    log("Number of rows updated: $rowsAffected");
    return true;
  }

  getPrivateMessage(int id) async {
    final db = await database;
    var res =
        await db.query("message", where: "messageId = ?", whereArgs: [id]);
    return res.isNotEmpty ? PrivateMessage.fromMap(res.first) : null;
  }
  Future<List<PrivateMessage>>getPrivateMessageByPhone(String phoneNumber) async {
    final db = await database;
    var res = await db.query(
      'message',
      where: 'sentTo = ? OR sentBy = ?',
      whereArgs: [phoneNumber, phoneNumber],
    );
    List<PrivateMessage> list = res.isNotEmpty
        ? res.map((c) => PrivateMessage.fromMap(c)).toList()
        : [];
    return list;
  }
  Future<List<PrivateMessage>>UpdatePrivateMessageByPhone(String phoneNumber) async {
    final db = await database;
    var res = await db.query(
      'message',
      where: 'sentBy = ?',
      whereArgs: [phoneNumber],
    );
    List<PrivateMessage> list = res.isNotEmpty
        ? res.map((c) => PrivateMessage.fromMap(c)).toList()
        : [];
    return list;
  }
  Future<List<PrivateMessage>>getUnsentPrivateMessage() async {
    final db = await database;
    var res = await db.query(
      'message',
      where: 'messageStatus = ? OR sentBy = ?',
      whereArgs: ["notSent",G()],
    );
    List<PrivateMessage> list = res.isNotEmpty
        ? res.map((c) => PrivateMessage.fromMap(c)).toList()
        : [];
    return list;
  }
  Future<List<PrivateMessage>> getBlockedPrivateMessages() async {
    final db = await database;

    print("works");
    // var res = await db.rawQuery("SELECT * FROM PrivateMessage WHERE blocked=1");
    var res =
        await db.query("PrivateMessage", where: "blocked = ? ", whereArgs: [1]);

    List<PrivateMessage> list = res.isNotEmpty
        ? res.map((c) => PrivateMessage.fromMap(c)).toList()
        : [];
    return list;
  }

  Future<List<PrivateMessage>> getAllPrivateMessages() async {
    final db = await database;
    var res = await db.query("message");
    List<PrivateMessage> list = res.isNotEmpty
        ? res.map((c) => PrivateMessage.fromMap(c)).toList()
        : [];
    return list;
  }

  deletePrivateMessage(int id) async {
    final db = await database;
    return db.delete("PrivateMessage", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from PrivateMessage");
  }

  Future<void> insertUserDetail(UserDetail userDetail) async {

    final db = await database;
    log("USERdetail adding to Db ${jsonEncode(userDetail)} ");

    await db.insert(
      'userDetails',
      userDetail.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUserDetail(UserDetail userDetail) async {
    final db = await database;
    await db.update(
      'userDetails',
      userDetail.toDbMap(),
      where: 'sId = ?',
      whereArgs: [userDetail.sId],
    );
  }

  Future<void> deleteUserDetail(String sId) async {
    final db = await database;
    await db.delete(
      'userDetails',
      where: 'sId = ?',
      whereArgs: [sId],
    );
  }
  Future<UserDetail?> getUserDetail(String sId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'userDetails',
      where: 'sId = ?',
      whereArgs: [sId],
    );

    if (maps.isNotEmpty) {
      return UserDetail.fromDbMap(maps.first);
    }
    return null; // Return null if no user is found with the given sId
  }
  Future<List<UserDetail>> getAllUserDetails() async {
    log("executing get all users ");
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('userDetails');


    return List.generate(maps.length, (i) {
      log("mapped users from gert db ${maps[i]}");
      return UserDetail.fromDbMap(maps[i]);
    });
  }

  Future<void> insertUserDetailList(List<UserDetail> userDetails) async {
    log("adding to db user list ");
    final db = await database;
    Batch batch = db.batch();

    for (var userDetail in userDetails) {
      log("adding used detail to Db ${jsonEncode(userDetail.toJson())}");
      var existingUser = await db.query(
        'userDetails',
        where: 'phoneNumber = ?',
        whereArgs: [userDetail.phoneNumber],
      );

      if (existingUser.isNotEmpty) {
        // Update existing record

        batch.update(
          'userDetails',
          userDetail.toDbMap(),
          where: 'phoneNumber = ?',
          whereArgs: [userDetail.phoneNumber],
        );
      } else {
        // Insert new record
        batch.insert(
          'userDetails',
          userDetail.toDbMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
  }
  Future<bool> isImageChanged(String publicProfilePicUrl, String phoneNumber) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'userDetails',
      where: 'publicProfilePicUrl = ? AND phoneNumber = ?',
      whereArgs: [publicProfilePicUrl, phoneNumber],
    );
    if (results.isNotEmpty) {
      final userDetails = results.first;
      final localImage = userDetails['localImage'] as String?;
      if (localImage == null || localImage.isEmpty) {
        return true;
      }
    }
    return results.isNotEmpty;
  }
  // Insert values into the chat_list table
  // Future<void> insertChatListItem(String chatName, String lastMessage, String lastMessageTime) async {
  //   final db = await database;
  //   await db.insert(
  //     'chat_list',
  //     {
  //       'chatName': chatName,
  //       'lastMessage': lastMessage,
  //       'lastMessageTime': lastMessageTime,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }
}
