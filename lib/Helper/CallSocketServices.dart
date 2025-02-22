import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';

import 'Helper.dart';

class CallSocketService extends ChangeNotifier {
  late IOWebSocketChannel callChannel;
  bool incoming = false;
  bool showCutCall = false;
  String callStatusText = "";
  var temp;
  var offerData;

  bool isConnected = false;
  bool isOnCall = false;
  Future<bool> init() async {
    try{
      if (!isConnected) {

        callChannel = await IOWebSocketChannel.connect("ws://${G.IP}:9090");
        print("init connected to CAll socket");
        callChannel?.sink.add(
            jsonEncode({"type": "register", "phonenumber": G.userPhoneNumber}));
        isConnected = true;
        callChannel.stream.listen(
              (message) {
            print("response of audiocallling stream ${jsonDecode(message)} ");
            temp = jsonDecode(message);

            if(temp["type"]=="offer")
            {
              offerData=temp["offer"];
              log("assigned offer to the offerdata varaible");
            }
            notifyListeners(); // Notify listeners whenever a message is received

            // switch (temp["type"]) {
            //   // case "offer":
            //   //   {
            //   //     log(" REceiving OFFFFFFFFFFFERRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
            //   //
            //   //   }
            //   //   break;
            //   // case "answer":
            //   //  {}
            //   //
            //   //   break;
            //   case "callRequestResponse":
            //     {
            //       log("request response from audio calling page provider ");
            //       if (temp["status"] == "Accepted") {
            //         isOnCall = true;
            //         log("inside call request accepted from socket ");
            //       } else if (temp["status"] == "Rejected") {
            //         isOnCall = false;
            //         log("inaside call request rejected from socket ");
            //       }
            //       break;
            //     }
            //   case "leave":
            //     {
            //       log("inside case leave from CAllsocket Provider");
            //
            //       isOnCall = false;
            //
            //       break;
            //     }
            //   // case "CallRequest":
            //   // {
            //   //   log("inside call requestr ");
            //   //   log("TEmp $temp");
            //   // }
            // }
          },
          onDone: () {
            // Handle the stream being closed
            isConnected = false;

          },
          onError: (error) {
            // Handle any errors that occur
            isConnected = false;
            reconnect();

          },
        );
      }




      return isConnected;
    }catch
    (e)
    {
        log("Error in init of call channel ${e}");
      return isConnected;
    }

  }
  void reconnect() {
    // Implement your reconnection logic here
    // For example, you can retry connecting after a delay
    Future.delayed(Duration(seconds: 5), () {
      if (!isConnected) {
        init();
      }});}

  CallRequest(String receiverNo, String ReceiverURl,String callType ) async {
    try {
      var responseOfGettoken = await G.getTokenBynumber(receiverNo);
      if (responseOfGettoken == "error") {
        log("error from token ");
      } else {
        callChannel?.sink.add(jsonEncode({
          "type": "initiateCall",
          "receiverNo": receiverNo,
          "callerName":G.loggedinUser.publicName,
          "callerNo": G.userPhoneNumber,
          "callType": callType,
          "receiver_profile_pic_url": G.HOST + "api/v1/images/" + ReceiverURl,
          "receipientFireToken": responseOfGettoken
        }));
      }
      isOnCall = true;
    } catch (e) {
      log("Error while calling request $e");
    }
  }

  Future<void> sendCallResponse(String Callingto, String Response) async {
    if (Response == "Accepted") {
      isOnCall = true;

    } else {
      isOnCall = false;
    }
    callChannel?.sink.add(jsonEncode({
      "type": "SendRequestResponse",
      "callStatus": Response,
      "receiverNo": Callingto,
      "caller_No": G.userPhoneNumber,
      "callType": "Audio",
    }));
  }

  void sendAnswer(String CallerNo, var session) async {
    log("sending answer");
    isOnCall = true;
    log("inside send answer of provider ${CallerNo} SESSION FROM HERE ${session}");
    callChannel.sink.add(
        jsonEncode({"type": "answer", "name": CallerNo, "answer": session}));
  }
void sendLeave(String USerNumber,String OtherUsernumber)async{
  callChannel?.sink.add(
    jsonEncode(
      {
        "type": "leave",
        "phoneNumber": USerNumber,
        "otherUser":OtherUsernumber
      },
    ),
  );
}
 void rebuild()
 {
   log("notifying listeners");
   notifyListeners();
 }
   sendCandidates(String otherCaller,RTCIceCandidate e) async {
    log("inside the send candidate other caller is $otherCaller");
    isOnCall=true;
    // log("list of candidates ${e.length}");
    // List<Map<String, dynamic>> candidateList = e.map((candidate) {
    //   return {
    //     'candidate': candidate.candidate,
    //     'sdpMid': candidate.sdpMid,
    //     'sdpMLineIndex': candidate.sdpMLineIndex,
    //   };
    // }).toList();
    callChannel.sink.add(jsonEncode({
      "type": "candidate",
      "otherCaller": otherCaller,
      "sender":G.userPhoneNumber,
      "candidate":{
        'candidate': e.candidate,
        'sdpMid': e.sdpMid,
        'sdpMLineIndex': e.sdpMLineIndex,
      }
      // "candidate": {
      //   'candidate': e.candidate.toString(),
      //   'sdpMid': e.sdpMid.toString(),
      //   'sdpMLineIndex': e.sdpMLineIndex,
      // }
    }));
  }

  void sendOffer(
      String otherCaller, var sessionSdp, String Url, String Token,String callerName,String receiverName) async {

    isOnCall=true;

    log("sending offer from provider");

    callChannel.sink.add(jsonEncode({

      "type": "offer",
      "receiverPhoneNumber": otherCaller,
      "callerPhoneNumber": G.userPhoneNumber,
      "callerName":callerName,
      "receiverName":receiverName,
      "offer":sessionSdp,
      "callType": "Audio",
      "caller_profile_pic_url": G.HOST + "api/v1/images/" + Url,
      "receipientFireToken": Token
    }));
  }
void sendVideoRequest(String otherUser){
  callChannel.sink.add(jsonEncode({

    "type": "requestToVideo",
    "otherUser": otherUser,
    "requestUser": G.userPhoneNumber,

  }));
}
  void sendVideoRequestResponse(String isAccepted,String requestedUser){
    callChannel.sink.add(jsonEncode({

      "type": "videoRequestResponse",
      "isAccepted": isAccepted,
      "respondingUser": G.userPhoneNumber,
      "requestedUser":requestedUser
    }));
  }
  void dispose() {
    isOnCall=false;
    callChannel?.sink.close();
    super.dispose();
  }
}
