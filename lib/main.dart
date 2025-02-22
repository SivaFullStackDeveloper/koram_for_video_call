// import 'dart:convert';
// import 'dart:html';

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:koram_app/Helper/DBHelper.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Helper/NotificationServices.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:koram_app/Models/ChatRoom.dart';
import 'package:koram_app/Models/Message.dart';
import 'package:koram_app/Models/User.dart';
import 'package:koram_app/Screens/AudioCalling.dart';
import 'package:koram_app/Screens/ChattingScreen.dart';
import 'package:koram_app/Screens/HomeScreen.dart';
import 'package:koram_app/Screens/SplashScreen.dart';
import 'package:koram_app/Screens/VideoCallingScreen.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart' as flc;
import 'package:flutter_localization/flutter_localization.dart';

import 'Helper/CallSocketServices.dart';
import 'Helper/ChatSocketServices.dart';
import 'Helper/ConnectivityProviderService.dart';
import 'Helper/PageProviderService.dart';
import 'Helper/namedRouteArgClass.dart';
import 'Models/Notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Models/NotificationModel.dart';
import 'firebase_options.dart';


final GlobalKey<NavigatorState> MainNavigatorKey = GlobalKey<NavigatorState>();
String originalDataString = "";
String modifiedString = "";
bool isBackgroundCall=false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: "call_channel",
        channelName: "Call Channel",
        channelDescription: "Channel for call",
        defaultColor: Colors.redAccent,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        playSound: true,
        enableVibration: true,
        channelShowBadge: true,
        locked: true,
        defaultRingtoneType: DefaultRingtoneType.Ringtone),
    NotificationChannel(
        channelKey: "message_channel",
        channelName: "Message Channel",
        channelDescription: "Channel for Message",
        defaultColor: RuntimeStorage().PrimaryOrange,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        locked: true,
        defaultRingtoneType: DefaultRingtoneType.Notification)
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );
  log("initialized firebase");
  FirebaseMessaging.instance.getToken().then((value) {
    G.fireBaseToken = value;
    log("fireBase Token $value");
    prefs.setString("FirebaseToken", value.toString());
  });
  // FirebaseMessaging.onMessage.listen((RemoteMessage event) async{
  //   log("REceived firebase message ");
  //   log( "Onmessageeee dataaaa ${event.data}");
  //   // {receiverNumber: +918425856783, caller: +919876543211, name: theRedmi, type: CallRequest, callType: Audio}
  //        if(event.data["type"]=="CallRequest")
  //        {
  //          log("call request receivedd");
  //          AwesomeNotifications().createNotification(
  //              content: NotificationContent(
  //                  id: 123,
  //                  channelKey: "call_channel",
  //                  color: Colors.white,
  //                  title: event.data["name"],
  //                  body: "Calling...",
  //                  category: NotificationCategory.Call,
  //                  wakeUpScreen: true,
  //                  fullScreenIntent: true,
  //                  autoDismissible: false,
  //                  backgroundColor: RuntimeStorage.instance.PrimaryOrange),
  //              actionButtons: [
  //                NotificationActionButton(
  //                    key: "accept_call",
  //                    label: "Accept Call",
  //                    color: Colors.green,
  //                    autoDismissible: true),
  //                NotificationActionButton(
  //                    key: "reject_call",
  //                    label: "Reject Call",
  //                    color: Colors.red,
  //                    autoDismissible: true)
  //              ]);
  //          AwesomeNotifications().setListeners(onActionReceivedMethod: (w) async {
  //            if (w.buttonKeyPressed == "accept_call") {
  //              print("call accepted");
  //              log("making call request");
  //
  //              // _channel.sink.add(jsonEncode({
  //              //   "type": "callRequestResponse",
  //              //   "callStatus": "Accepted",
  //              //   "name": message.data["name"],
  //              //   "caller_Name": G.userId,
  //              //   "callType": "Audio",
  //              // }));
  //              // Extracting required data from the notification payload
  //              //     {receiverNumber: +918425856783, caller: +919876543211, name: theRedmi, type: CallRequest, callType: Audio}
  //              String callerName = event.data["name"] ?? "Unknown Caller";
  //              String callerNumber = event.data["caller"] ?? "";
  //              bool isVideo=false;
  //                        if(event.data["callType"]=="Audio")
  //                        {
  //                          isVideo=false;
  //                        }else if(event.data["callType"]=="Video")
  //                        {
  //                          isVideo=true;
  //                        }
  //              // Navigate to AudioCallingScreen
  //              MainNavigatorKey.currentState?.pushNamed(
  //                '/audioCallScreen',
  //                arguments: {
  //                  'callerName': callerName,
  //                  'callerNumber': callerNumber,
  //                  'isIncoming': true,
  //                  'isVideoCall': isVideo,
  //                },
  //              );
  //
  //
  //
  //            } else if (w.buttonKeyPressed == "reject_call") {
  //              // _channel.sink.add(jsonEncode({
  //              //   "type": "callRequestResponse",
  //              //   "callStatus": "Rejected",
  //              //   "name": message.data["name"],
  //              //   "caller_Name": G.userId,
  //              //   "callType": "Audio",
  //              // }));
  //              print("call rejected");
  //              AwesomeNotifications().cancel(123);
  //            } else {
  //              print("clicked on notification");
  //            }
  //          });
  //        }
  //   // AwesomeNotifications().createNotification(
  //   //   content: NotificationContent(
  //   //     id: 10,
  //   //     channelKey: 'message_channel',
  //   //     title: "yo",
  //   //     body: "yoyoy",
  //   //     displayOnBackground: true,
  //   //     displayOnForeground: true,
  //   //     wakeUpScreen: true,
  //   //     backgroundColor: Colors.white,
  //   //     notificationLayout: NotificationLayout.Default,
  //   //   ),
  //   // );
  // });

  // FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? value)async
  // {
  //   print("onInitiall: $value");
  //
  // });

  FirebaseMessaging.onBackgroundMessage(fireBaseMessagingBackgroundHandler);
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (receivedAction) async {
      // Handle notification actions globally
      if (receivedAction.buttonKeyPressed == "accept_call") {
        String? callerName = receivedAction.payload?['name'];
        String? callerNumber = receivedAction.payload?['caller'];
        bool isVideoCall = receivedAction.payload?['callType'] == "Video";

        // Navigate to the call screen
        RuntimeStorage.instance.pendingNavigation = {
          'route': '/audioCallScreen',
          'arguments': {
            'callerName': callerName ?? "Unknown Caller",
            'callerNumber': callerNumber ?? "",
            'isIncoming': true,
            'isVideoCall': isVideoCall,
          },
        };

        MainNavigatorKey.currentState?.pushNamed(
          '/audioCallScreen',
          arguments: RuntimeStorage.instance.pendingNavigation?['arguments'],
        );
      } else if (receivedAction.buttonKeyPressed == "reject_call") {
        AwesomeNotifications().cancel(123);
      }
    },
  );
  await NotificationService().init();
  await DBProvider.db.initDB();

  runApp(MyApp());
}


Future<void> fireBaseMessagingBackgroundHandler(RemoteMessage event) async {
  switch (event.data["type"]) {
    case "CallRequest":
      {
        isBackgroundCall=true;

          log("is active was false sp showing notificatyion");
          log("the call request case received ");
          AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: 123,
                  channelKey: "call_channel",
                  color: Colors.white,
                  title: event.data["name"],
                  body: "Calling...",
                  category: NotificationCategory.Call,
                  wakeUpScreen: true,
                  fullScreenIntent: true,
                  autoDismissible: false,
                  payload: event.data.map((key, value) => MapEntry(key, value?.toString())),
                  backgroundColor: RuntimeStorage.instance.PrimaryOrange),
              actionButtons: [
                NotificationActionButton(
                    key: "accept_call",
                    label: "Accept Call",
                    color: Colors.green,
                    autoDismissible: true,
                  enabled: true
                ),

                NotificationActionButton(
                    key: "reject_call",
                    label: "Reject Call",
                    color: Colors.red,
                    autoDismissible: true)
              ]);
          // AwesomeNotifications().setListeners(
          //     onActionReceivedMethod: (w) async {
          //       if (w.buttonKeyPressed == "accept_call") {
          //         print("call accepted");
          //         log("making call request");
          //
          //         // _channel.sink.add(jsonEncode({
          //         //   "type": "callRequestResponse",
          //         //   "callStatus": "Accepted",
          //         //   "name": message.data["name"],
          //         //   "caller_Name": G.userId,
          //         //   "callType": "Audio",
          //         // }));
          //         // Extracting required data from the notification payload
          //         //     {receiverNumber: +918425856783, caller: +919876543211, name: theRedmi, type: CallRequest, callType: Audio}
          //         String callerName = event.data["name"] ?? "Unknown Caller";
          //         String callerNumber = event.data["caller"] ?? "";
          //         bool isVideo = false;
          //         if (event.data["callType"] == "Audio") {
          //           isVideo = false;
          //         } else if (event.data["callType"] == "Video") {
          //           isVideo = true;
          //         }
          //         // Navigate to AudioCallingScreen
          //         RuntimeStorage.instance.pendingNavigation = {
          //           'route': '/audioCallScreen',
          //           'arguments': {
          //             'callerName': event.data["name"] ?? "Unknown Caller",
          //             'callerNumber': event.data["caller"] ?? "",
          //             'isIncoming': true,
          //             'isVideoCall': event.data["callType"] == "Video",
          //           },
          //         };
          //         MainNavigatorKey.currentState?.pushNamed(
          //           '/audioCallScreen',
          //           arguments: {
          //             'callerName': callerName,
          //             'callerNumber': callerNumber,
          //             'isIncoming': true,
          //             'isVideoCall': isVideo,
          //           },
          //         );
          //
          //       } else if (w.buttonKeyPressed == "reject_call") {
          //         // _channel.sink.add(jsonEncode({
          //         //   "type": "callRequestResponse",
          //         //   "callStatus": "Rejected",
          //         //   "name": message.data["name"],
          //         //   "caller_Name": G.userId,
          //         //   "callType": "Audio",
          //         // }));
          //         print("call rejected");
          //         AwesomeNotifications().cancel(123);
          //       } else {
          //         print("clicked on notification");
          //       }
          //     });


      }
      break;

    case "Message":
      {
        log("Message case received");
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10,

            channelKey: 'message_channel',
            title: '${event.data["senderName"]}',
            body: '${event.data["message"]}',
            displayOnBackground: true,
            displayOnForeground: true,
            backgroundColor: Colors.white,
            notificationLayout: NotificationLayout.Default,
          ),
        );
      }
      break;

  }
}




class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>  with WidgetsBindingObserver {
  var nestedJsonString;
  AppLifecycleState? _isAppActive ;

  _showLocalNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) async {
      log("the app status of active is  ${_isAppActive}");
      log("from showlocal notification from on message listener ");
      // {receiverNumber: +918425856783, caller: +919876543211, name: theRedmi, type: CallRequest, callType: Audio}
      switch (event.data["type"]) {
        case "CallRequest":
          {
            if(_isAppActive ==AppLifecycleState.resumed || _isAppActive==null || _isAppActive==AppLifecycleState.inactive)
            {
              log("is active was true so notification wont be shown");
              return;
            }else
            {
              log("is active was false sp showing notificatyion");
              log("the call request case received ");
              AwesomeNotifications().createNotification(
                  content: NotificationContent(
                      id: 123,
                      channelKey: "call_channel",
                      color: Colors.white,
                      title: event.data["name"],
                      body: "Calling...",
                      category: NotificationCategory.Call,
                      wakeUpScreen: true,
                      fullScreenIntent: true,
                      autoDismissible: false,
                      backgroundColor: RuntimeStorage.instance.PrimaryOrange),
                  actionButtons: [
                    NotificationActionButton(
                        key: "accept_call",
                        label: "Accept Call",
                        color: Colors.green,
                        autoDismissible: true),
                    NotificationActionButton(
                        key: "reject_call",
                        label: "Reject Call",
                        color: Colors.red,
                        autoDismissible: true,
                    actionType: ActionType.DismissAction,

                    )

                  ]);
              AwesomeNotifications().setListeners(
                  onActionReceivedMethod: (w) async {
                    if (w.buttonKeyPressed == "accept_call") {
                      print("call accepted");
                      log("making call request");

                      // _channel.sink.add(jsonEncode({
                      //   "type": "callRequestResponse",
                      //   "callStatus": "Accepted",
                      //   "name": message.data["name"],
                      //   "caller_Name": G.userId,
                      //   "callType": "Audio",
                      // }));
                      // Extracting required data from the notification payload
                      //     {receiverNumber: +918425856783, caller: +919876543211, name: theRedmi, type: CallRequest, callType: Audio}
                      String callerName = event.data["name"] ?? "Unknown Caller";
                      String callerNumber = event.data["caller"] ?? "";
                      bool isVideo = false;
                      if (event.data["callType"] == "Audio") {
                        isVideo = false;
                      } else if (event.data["callType"] == "Video") {
                        isVideo = true;
                      }
                      // Navigate to AudioCallingScreen
                      MainNavigatorKey.currentState?.pushNamed(
                        '/audioCallScreen',
                        arguments: {
                          'callerName': callerName,
                          'callerNumber': callerNumber,
                          'isIncoming': true,
                          'isVideoCall': isVideo,
                        },
                      );
                    } else if (w.buttonKeyPressed == "reject_call") {
                      // _channel.sink.add(jsonEncode({
                      //   "type": "callRequestResponse",
                      //   "callStatus": "Rejected",
                      //   "name": message.data["name"],
                      //   "caller_Name": G.userId,
                      //   "callType": "Audio",
                      // }));
                      print("call rejected");
                      AwesomeNotifications().cancel(123);
                    } else {
                      print("clicked on notification");
                    }
                  });
            }

          }
          break;

        case "Message":
          {
            log("Message case received");
          }
          break;

      }
    });
  }
 @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    log("did change app life cycle called");

    setState(() {
      _isAppActive = state;
    });
    log("App lifecycle state changed: $state, App Active: $_isAppActive");
  }
  @override
  void dispose() {
    // Remove the observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _showLocalNotification();

    WidgetsBinding.instance.addObserver(this);
    load();
    // AwesomeNotifications().setListeners(
    //     onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    //     onNotificationCreatedMethod:
    //         NotificationController.onNotificationCreatedMethod,
    //     onNotificationDisplayedMethod:
    //         NotificationController.onNotificationDisplayedMethod,
    //     onDismissActionReceivedMethod:
    //         NotificationController.onDismissActionReceivedMethod);
  }

  MaterialColor orangePrimary = MaterialColor(0xFFFF6701, {
    50: Color(0xFFFFE6D9),
    100: Color(0xFFFFC4A6),
    200: Color(0xFFFFA274),
    300: Color(0xFFFF803F),
    400: Color(0xFFFF6B1F),
    500: Color(0xFFFF6701), // Primary color
    600: Color(0xFFFF6701),
    700: Color(0xFFFF6701),
    800: Color(0xFFFF6701),
    900: Color(0xFFFF6701),
  });

  MaterialColor Higlight = MaterialColor(0xFFF5F5F5, {
    50: Color(0xFFF5F5F5),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFF5F5F5),
    300: Color(0xFFF5F5F5),
    400: Color(0xFFF5F5F5),
    500: Color(0xFFF5F5F5),
    600: Color(0xFFF5F5F5),
    700: Color(0xFFF5F5F5),
    800: Color(0xFFF5F5F5),
    900: Color(0xFFF5F5F5),
  });
  load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      G.userPhoneNumber = prefs.getString("userId") ?? "";
      G.logedIn = prefs.getBool('logedIn') ?? false;
    });
    log("Shared preference user phone" + G.userPhoneNumber);
    log("Shared pref loged in" + G.logedIn.toString());
  }

  @override
  Widget build(BuildContext context) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) async {
      log("on message opened: $event");
      log("ON MESssage Opennen called");

    });

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.white, // Note RED here
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => connectivityProvider()),
        ChangeNotifierProvider(create: (_) => ChatSocket()),
        ChangeNotifierProvider(create: (_) => CallSocketService()),
        ChangeNotifierProvider(create: (_) => UsersProviderClass()),
        ChangeNotifierProvider(create: (_) => Messages()),
        ChangeNotifierProvider(create: (_) => ChatRoomsProvider()),
        ChangeNotifierProvider(create: (_) => Notifications()),
        ChangeNotifierProvider(create: (_) => pageProviderService())
      ],
      child: MaterialApp(
          routes: {
            '/audioCallScreen': (context) {
              final args = ModalRoute.of(context)?.settings.arguments as Map?;
              return AudioCallingScreen(
                callTo: args?['callerNumber'] ?? '',
                caller: args?['callerName'] ?? '',
                isIncoming: args?['isIncoming'] ?? true,
                isfromNotification: true,
                isVideoCall: args?['isVideoCall'] ?? false,
              );
            },
            '/homeScreen': (context) => HomeScreen(),
            '/chattingScreen': (context) => ChattingScreen()
          },
          navigatorKey: MainNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Koram',
          supportedLocales:
              flc.CountryLocalizations.supportedLocales.map((e) => Locale(e)),
          localizationsDelegates: [
            // Package's localization delegate.
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            flc.CountryLocalizations.delegate
          ],

          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/audioCallScreen':
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => AudioCallingScreen(
                    callTo: args['callTo'],
                    caller: args['caller'],
                    isIncoming: args['isIncoming'],
                    isfromNotification: true,
                    isVideoCall: args['isVideoCall'],
                  ),
                );
              default:
                return MaterialPageRoute(builder: (context) => HomeScreen());
            }
              return MaterialPageRoute(
                builder: (context) => AudioCallingScreen(
                  callTo:G.userPhoneNumber,
                  caller:"+919876543211",
                  isIncoming: true,
                  isfromNotification: true,
                  isVideoCall: false,
                ),
              );


            // if (settings.name == '/chattingScreen') {
            //   final ChattingArguments args =
            //       settings.arguments as ChattingArguments;
            //   return MaterialPageRoute(
            //     builder: (context) {
            //       return ChattingScreen(otherUserNumber: args.otherUserNumber);
            //     },
            //   );
            // }
            // assert(false, 'Need to implement ${settings.name}');
            return null;
          },
          color: orangePrimary,
          themeMode: ThemeMode.light,
          theme: ThemeData(
            useMaterial3: false,
            primarySwatch: orangePrimary,
            splashColor: Color(0xFFFFEADC),
            highlightColor: Color(0xFFFFEADC),
          ),
          home:
              LoaderOverlay(child: G.logedIn ? HomeScreen(backgroundCAll: isBackgroundCall,) : SplashScreen(1))),
    );
  }
}
