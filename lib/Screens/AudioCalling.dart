import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:koram_app/Helper/background_services.dart';
import 'package:koram_app/Helper/color.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Helper/RuntimeStorage.dart';
import 'package:provider/provider.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/CallSocketServices.dart';
import '../Models/NewUserModel.dart';

class AudioCallingScreen extends StatefulWidget {
  final String caller;
  final String callTo;
  bool isIncoming;
  Function? callback;
  UserDetail? otherPersonData;
  bool isfromNotification = false;
  String? callerURl;
  bool isVideoCall = false;
  var sockettemp;

  AudioCallingScreen(
      {required this.callTo,
      required this.caller,
      required this.isIncoming,
      required this.isfromNotification,
      this.sockettemp,
      this.callback,
      required this.isVideoCall,
      this.otherPersonData,
      this.callerURl});

  @override
  _AudioCallingScreenState createState() => _AudioCallingScreenState();
}

class _AudioCallingScreenState extends State<AudioCallingScreen> {
  var calling = true;

  final _localRenderer = new RTCVideoRenderer();
  final _remoteRenderer = new RTCVideoRenderer();
  late DateTime callStartTime;
  late Timer timer;
  bool video = true;
  bool speaker = false;
  bool camerSwitchBack = false;
  late MediaStream _localStream;
  int callDurationInSeconds = 0;
  Duration callDuration = Duration();
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  bool mic = true;
  bool videoControl = false;
  bool receivingCall = false;
  UserDetail? loggedUser;
  String theCallStatus = "Idle";
  RTCPeerConnection? webrtcPeerConnection;
  late Map<String, dynamic> mediaConstraints;
  bool isOfferUser = false;
  int videorequestCount = 0;
  bool displayVideoDialog = true;
  List<RTCIceCandidate> ListOfCandidates = [];

  // AudioPlayer? audioPlayer;
  @override
  dispose() {
    Audio().stopAudio();

    try {
      log("disposse called ");
      _localRenderer.dispose();
      _remoteRenderer.dispose();
      _localStream.dispose();
      ListOfCandidates = [];
      if (webrtcPeerConnection != null) {
        webrtcPeerConnection!.dispose();
      }
    } catch (e) {
      log("error while disposing $e");
    }

    super.dispose();
  }

  // void playRingback() async {
  //     audioPlayer?.play(AssetSource("assets/RingbackTone.mp3"));
  //
  // }
  //
  // void stopRingback() {
  //   audioPlayer!.stop();
  // }

  @override
  void initState() {
    AwesomeNotifications().cancel(123);
    RuntimeStorage.instance.pendingNavigation = null;
    Future.delayed(Duration.zero).then((value) async {
      // audioPlayer = AudioPlayer();
      // playRingback();
      CallSocketService callSocketInit =
          Provider.of<CallSocketService>(context, listen: false);
      callSocketInit.init();
      await initRenderers();
      await CreateGlobalPeerConnection();
      log("is video CAll ${widget.isVideoCall}");
      videoControl = widget.isVideoCall;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      loggedUser = G.loggedinUser;

      if (!widget.isIncoming) {
        List<String> callHistory = prefs.getStringList("call_history") ?? [];
        callHistory.add(json.encode({
          "call_type": widget.isVideoCall ? "video" : "audio",
          "caller": widget.caller,
          "callTo": widget.callTo,
          "time": DateTime.now().toString(),
          "callerName": widget.otherPersonData?.publicName ?? "",
          "profilePic": widget.otherPersonData?.publicProfilePicUrl ?? ""
        }));
        log("the call history length ${callHistory.length}");
        prefs.setStringList("call_history", callHistory);
      } else {
        log("insdie the incoming block ");
        receivingCall = true;
        theCallStatus = "Incoming ${widget.isVideoCall ? "Video" : ""} call";
        try {
          List<String> callHistory = prefs.getStringList("call_history") ?? [];
          callHistory.add(json.encode({
            "call_type": widget.isVideoCall ? "video" : "audio",
            "caller": widget.caller,
            "callTo": widget.callTo,
            "time": DateTime.now().toString(),
            "callerName": widget.otherPersonData?.publicName ?? "",
            "profilePic": widget.otherPersonData?.publicProfilePicUrl ?? ""
          }));
          log("the call history length ${callHistory.length}");
          prefs.setStringList("call_history", callHistory);
        } catch (e) {
          log("erro while asving prefrence in audiocalling screen incoming ${e}");
        }
      }
      setState(() {});
    });

    super.initState();
  }

//WEB rtc code
  Future<RTCPeerConnection?> CreateGlobalPeerConnection() async {
    try {
      log("Creating Peerconnection ");
      final Map<String, dynamic> configuration = {
        'iceServers': [
          {
            'urls': [
              'turn:24.199.85.25:3478',
              'turn:koram.in:3478?transport=udp',
              'turn:koram.in:3478?transport=tcp'
            ],
            "username": "nidishTurnUser",
            'credential': 'dsafnkdlsnflksdaklfmadsklmf'
          },
        ]
      };
      final Map<String, dynamic> offerSdpConstraints = {
        "mandatory": {
          "OfferToReceiveAudio": true,
          "OfferToReceiveVideo": false,
        },
        "optional": [],
      };
      webrtcPeerConnection =
          await createPeerConnection(configuration, offerSdpConstraints);
      _localStream = (await _getUserMedia(widget.isVideoCall))!;
      _localStream.getTracks().forEach((track) {
        webrtcPeerConnection!.addTrack(track, _localStream);
      });

      // webrtcPeerConnection!.onAddStream = (stream) {
      //   _remoteRenderer.srcObject = stream;
      //   // setState(() {
      //   //
      //   // });
      // };
      _localStream.getAudioTracks()[0].enableSpeakerphone(false);
      webrtcPeerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          _remoteRenderer.srcObject = event.streams[0];
          setState(() {});
        }
      };
      return webrtcPeerConnection!;
    } catch (e) {
      log("error while creating peer $e");
      return null;
    }
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  createOffer(CallSocketService callSocket) async {
    try {
      log("creating offer from audio calling screenn");
      theCallStatus = "Calling";
      final prefs = await SharedPreferences.getInstance();

      var token = prefs.getString("FirebaseToken");

      RTCSessionDescription sessionDesc =
          await webrtcPeerConnection!.createOffer({'offerToReceiveVideo': 1});
      webrtcPeerConnection!.setLocalDescription(sessionDesc);

      var session = parse(sessionDesc.sdp!);
      callSocket.sendOffer(
          widget.callTo,
          session,
          loggedUser!.privateProfilePicUrl!,
          token!,
          widget.caller,
          widget.otherPersonData!.publicName!);

      isOfferUser = true;

      webrtcPeerConnection!.onIceCandidate = (e) {
        log("CAndidate received from offerrrr ");
        if (e.candidate != null) {
          callSocket.sendCandidates(widget.callTo, e);
          log("offer candidates $e");
        }
      };
      webrtcPeerConnection!.onIceGatheringState =
          (RTCIceGatheringState state) async {
        if (state == RTCIceGatheringState.RTCIceGatheringStateComplete) {
          log("All candidates sent: $ListOfCandidates");
        }
      };
    } catch (e) {
      log("error while creating offer ${e}");
    }
  }

  createAnswer(CallSocketService callsocket) async {
    try {
      log("createAnswer called ");
      // await _setRemoteDescription(callsocket.temp["offer"], callsocket);
      await _setRemoteDescription(callsocket.offerData, callsocket);

      theCallStatus = "Connecting";

      RTCSessionDescription description =
          await webrtcPeerConnection!.createAnswer({'offerToReceiveVideo': 1});
      webrtcPeerConnection!.setLocalDescription(description);

      var session = await parse(description.sdp!);

      callsocket.sendAnswer(widget.callTo, session);
      final prefs = await SharedPreferences.getInstance();
      List<String> callHistory = prefs.getStringList("call_history") ?? [];
      callHistory.add(json.encode({
        "call_type": widget.isVideoCall ? "video" : "audio",
        "caller": widget.callTo,
        "callTo": widget.caller,
        "time": DateTime.now().toString()
      }));
      prefs.setStringList("call_history", callHistory);

      webrtcPeerConnection!.onIceCandidate = (e) {
        print(e);
        if (e.candidate != null) {
          ListOfCandidates.add(e);
          log("sending answer candidate ");
          callsocket.sendCandidates(widget.callTo, e);
        }
      };
      // await callsocket.sendCandidates(widget.callTo, ListOfCandidates);
      callsocket.offerData = null;
    } catch (e) {
      log("ERror at creating answer $e");
    }
  }

  void _addCandidate(var can, CallSocketService socket) async {
    try {
      print("Adding candidate ${jsonEncode(can)}");
      dynamic session = can;
      theCallStatus = "Connecting";
      dynamic candidate = new RTCIceCandidate(
          session['candidate'], session['sdpMid'], session['sdpMlineIndex']);

      await webrtcPeerConnection!.addCandidate(candidate);

      // if (!isOfferUser) {
      //   // stopRingback();
      //
      //   socket.sendCandidates(widget.callTo, ListOfCandidates);
      // }

      // dynamic candidate = new RTCIceCandidate(
      //     session['candidate'], session['sdpMid'], session['sdpMLineIndex']);
    } catch (e) {
      log("error while adding candidate $e");
    }
  }

  Future<MediaStream?> _getUserMedia(bool videoEnabled) async {
    try {
      mediaConstraints = {
        'audio': true,
        'video': videoEnabled
            ? {
                'facingMode': 'user',
              }
            : false,
      };

      MediaStream stream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = stream;

      return stream;
    } catch (e) {
      log("error while getting user media $e");
      return null;
    }
  }

  _updateToVideoStream() async {
    log("updating to video stream");
    var videoStream = await _getUserMedia(true);
    var videoTrack = videoStream!.getVideoTracks().first;

    // Replace the audio-only track with the video track
    webrtcPeerConnection!.addTrack(videoTrack, _localStream);

    // Optionally, stop the audio-only track to save bandwidth
    _localStream.getTracks().forEach((track) {
      if (track.kind == 'video') {
        //track.stop();
      }
    });

    _localStream = videoStream;
    videoControl = true;
    displayVideoDialog = false;
    setState(() {});
  }

  void onVideoCallAccepted() {
    _updateToVideoStream();
  }

  sendVideoRequest(CallSocketService socket) async {
    try {
      log(" sending video request  ${widget.callTo}");
      theCallStatus = "Requesting for video call";
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });

      socket.sendVideoRequest(widget.callTo);
    } catch (e) {
      log("error while sending video request $e");
    }
  }

  _setRemoteDescription(var obj, CallSocketService socket) async {
    try {
      log("setting remote description");
      theCallStatus = "setting remote desc $isOfferUser";
      dynamic session = obj;
      String sdp = write(session, null);
      RTCSessionDescription description =
          new RTCSessionDescription(sdp, isOfferUser ? 'answer' : 'offer');

      await webrtcPeerConnection!.setRemoteDescription(description);

      // if (isOfferUser) {
      //   log("inside the setremote desc creating answer");
      //   socket.sendCandidates(widget.callTo, ListOfCandidates);
      // }
    } catch (e) {
      log("error while settingremote desc $e");
    }
  }
  // End of webrtc code

  void calculateCallDuration() {
    DateTime currentTime = DateTime.now();
    callDuration = currentTime.difference(callStartTime);
    print("Call Duration: ${callDuration.inSeconds}  after calculation");
  }

  void endCallTimer() {
    timer.cancel();
    print("Call Duration: ${callDurationInSeconds.toString()} seconds");
  }

  void startCallTimer() {
    setState(() {
      callStartTime = DateTime.now();
      timer = Timer(Duration(seconds: 1), () {
        setState(() {
          callDurationInSeconds++;
        });
      });
    });
  }

  void _disconnect(CallSocketService callSocket, bool isSendSocket) async {
    try {
      log("inside the try ");
      if (isSendSocket) {
        log("sending socket leave call ");
        callSocket.sendLeave(G.userPhoneNumber, widget.callTo);
      }
      if (webrtcPeerConnection != null) {
        webrtcPeerConnection!.dispose();
      }
      theCallStatus = "Idle";
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });
      _localStream.dispose();
      _localRenderer.dispose();
      _remoteRenderer.dispose();
      _localStream.dispose();
      log("aftet the disposes befire pop");
      if (mounted) {
        Navigator.pop(context);
      }
      log("after pop");
    } catch (e) {
      log("error while disconnect $e");
    }
  }

  void switchCamera() async {
    Helper.switchCamera(_localStream.getVideoTracks()[0]);
    setState(() {
      camerSwitchBack = !camerSwitchBack;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.isVideoCall == true? !speaker == true:speaker;
    CallSocketService callSocket =
        Provider.of<CallSocketService>(context, listen: true);
    if (callSocket.offerData != null) {
      log("received offer ");
      createAnswer(callSocket);
    }
    if (callSocket.temp != null) {
      log("the call socket data received on build of Audio  ${callSocket.temp} ");
      switch (callSocket.temp["type"]) {
        case "callRequestResponse":
          {
            if (callSocket.temp["status"] == "Accepted") {
              createOffer(callSocket);
              callSocket.temp = null;
              log("inside call request accepted from socket ");
            } else if (callSocket.temp["status"] == "Reject") {
              callSocket.temp = null;
              _disconnect(callSocket, false);
            }
          }
          break;

        case "offer":
          {
            log("received offer ");
            // createAnswer(callSocket);
            // callSocket.temp=null;
          }
          break;
        case "answer":
          {
            _setRemoteDescription(callSocket.temp["answer"], callSocket);
            log("received answer");
            callSocket.temp = null;
          }
          break;
        case "candidate":
          {
            // List<dynamic> dynamicCandidates =
            //     callSocket.temp['ListOfCandidates'];
            // List<RTCIceCandidate> candidates =
            //     dynamicCandidates.map((dynamic candidate) {
            //   return RTCIceCandidate(
            //     candidate['candidate'],
            //     candidate['sdpMid'],
            //     candidate['sdpMLineIndex'],
            //   );
            // }).toList();
            log("REceived candidate socket data ${callSocket.temp['candidate']}");
            _addCandidate(callSocket.temp['candidate'], callSocket);

            theCallStatus = "Connected";
            callSocket.temp = null;
          }
          break;
        case "leaveCall":
          {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${widget.otherPersonData == null ? "" : widget.otherPersonData!.publicName} rejected the call"),
                        TextButton(
                          onPressed: () async {
                            callSocket.temp = null;
                            Navigator.pop(context);
                            _disconnect(callSocket, false);
                          },
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
              );
            });
            callSocket.temp = null;
          }
          break;

        case "changeToVideo":
          {
            displayVideoDialog = true;
            videorequestCount++;
            log("Received change to video request $videorequestCount");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              displayVideoDialog
                  ? showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          content: Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: MediaQuery.of(context).size.height / 5,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      "Requesting for Video Call $videorequestCount"),
                                  Row(
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            log("Accepted the video call ${widget.callTo}");
                                            callSocket.sendVideoRequestResponse(
                                                "Yes", widget.callTo);
                                            displayVideoDialog = false;
                                            onVideoCallAccepted();
                                            Navigator.pop(context);
                                          },
                                          child: Text("Accept")),
                                      TextButton(
                                          onPressed: () {
                                            Audio().stopAudio();
                                            log("rejected the video call  ${widget.callTo}");
                                            callSocket.sendVideoRequestResponse(
                                                "No", widget.callTo);
                                            Navigator.pop(context);
                                          },
                                          child: Text("Reject"))
                                    ],
                                  )
                                ]),
                          ),
                        );
                      })
                  : null;
            });

            callSocket.temp = null;
          }
          break;
        case "videoResponse":
          {
            if (callSocket.temp["isAccepted"] == "Yes") {
              log("other user accepted the video call");
              onVideoCallAccepted();
            } else if (callSocket.temp["isAccepted"] == "No") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              "${widget.otherPersonData!.publicName} rejected the video call"),
                        ],
                      ),
                    );
                  },
                );
              });
            }
            callSocket.temp = null;
          }
          break;
      }
    }

    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            videoControl == false
                ? Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 57.0),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: ShapeDecoration(
                                image: widget.otherPersonData != null
                                    ? DecorationImage(
                                        image: NetworkImage(G.HOST +
                                            "api/v1/images/" +
                                            widget.otherPersonData!
                                                .privateProfilePicUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : DecorationImage(
                                        image: AssetImage("assets/profile.png"),
                                        fit: BoxFit.cover,
                                      ),
                                shape: OvalBorder(),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 17,
                          ),
                          SizedBox(
                            height: 30,
                            child: Text(
                              widget.otherPersonData != null
                                  ? widget.otherPersonData!.publicName
                                      .toString()
                                  : "${widget.callTo}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF303030),
                                fontSize: 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                          ),
                          Text(
                            theCallStatus,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF707070),
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: RTCVideoView(
                      _remoteRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ), //when its video call then
            videoControl
                ? Positioned(
                    top: 130,
                    right: 5,
                    child: Column(
                      children: [
                        Container(
                            width: 100,
                            height: 140,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    "https://via.placeholder.com/100x140"),
                                fit: BoxFit.fill,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            // height: MediaQuery.of(context).size.height * 0.2,
                            // width: MediaQuery.of(context).size.width * 0.3,
                            key: new Key("local"),
                            margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                            // decoration: new BoxDecoration(color: Colors.black),
                            child: calling == null
                                ? RTCVideoView(
                                    _localRenderer,
                                    objectFit: RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                                  )
                                : new RTCVideoView(_localRenderer,
                                    objectFit: RTCVideoViewObjectFit
                                        .RTCVideoViewObjectFitCover,
                                    mirror: true)),
                        Container(
                          width: 55,
                          height: 29,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: Colors.black.withOpacity(0.1599999964237213),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '00:${callDurationInSeconds}',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : SizedBox(),
            receivingCall
                ? Positioned(
                    bottom: 0,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                await callSocket.sendCallResponse(
                                    widget.callTo, "Accepted");

                                setState(() {
                                  receivingCall = false;
                                  if (widget.isVideoCall) {
                                    videoControl = true;
                                  }
                                });
                              },
                              child: Container(
                                width: 63.76,
                                height: 63.76,
                                decoration: ShapeDecoration(
                                  color: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(62.06),
                                  ),
                                ),
                                child: Center(
                                    child: Icon(
                                  Icons.call,
                                  color: Colors.white,
                                )),
                              ),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                await callSocket.sendCallResponse(
                                    widget.callTo, "Reject");
                                _disconnect(callSocket, false);
                                // Navigator.pop(context);
                                // Navigator.popUntil(context, ModalRoute.withName('/homeScreen'));
                              },
                              child: Container(
                                width: 63.76,
                                height: 63.76,
                                decoration: ShapeDecoration(
                                  color: Color(0xFFFF3131),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(62.06),
                                  ),
                                ),
                                child: Center(
                                    child:
                                        SvgPicture.asset("assets/endCall.svg")),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Positioned(
                    bottom: 0,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: Container(
                              width: 63.76,
                              height: 63.76,
                              decoration: ShapeDecoration(
                                color: backendColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(62.06),
                                ),
                              ),
                              child: Center(
                                  child: mic
                                      ? SvgPicture.asset("assets/micLogo.svg")
                                      : Icon(
                                          Icons.mic_off,
                                          color: Colors.white,
                                        )),
                            ),
                            onTap: () {
                              setState(() {
                                mic = !mic;
                              });
                              _localStream.getAudioTracks()[0].enabled = mic;
                            },
                          ),
                          Expanded(child: SizedBox()),
                          GestureDetector(
                            onTap: () {
                              // setState(() {
                              //   videoControl = !videoControl;
                              // });
                              // _localStream.getVideoTracks()[0].enabled =
                              //     videoControl;
                              setState(() {
                                if (videoControl) {
                                  if (_localStream
                                      .getVideoTracks()[0]
                                      .enabled) {
                                    _localStream.getVideoTracks()[0].enabled =
                                        false;
                                  } else {
                                    _localStream.getVideoTracks()[0].enabled =
                                        true;
                                  }
                                } else {
                                  sendVideoRequest(callSocket);
                                }
                              });
                            },
                            child: Container(
                              width: 63.76,
                              height: 63.76,
                              decoration: ShapeDecoration(
                                color: backendColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(62.06),
                                ),
                              ),
                              child: Center(
                                  child: videoControl
                                      ? SvgPicture.asset("assets/video.svg")
                                      : Icon(
                                          Icons.videocam_off_outlined,
                                          color: Colors.white,
                                        )),
                            ),
                          ),

                          // GestureDetector(
                          //   onTap: () {
                          //     switchCamera();
                          //   },
                          //   child: Container(
                          //     width: 63.76,
                          //     height: 63.76,
                          //     decoration: ShapeDecoration(
                          //       color: backendColor,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(62.06),
                          //       ),
                          //     ),
                          //     child: Center(
                          //       child: CircleAvatar(
                          //         child: Icon(
                          //           video ? Icons.videocam : Icons.videocam_off,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          //       Center(
                          //           child: SvgPicture.asset(
                          //               "assets/switchCam.svg"))),
                          // ),
                          Expanded(child: SizedBox()),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                speaker = !speaker;
                                _localStream
                                    .getAudioTracks()[0]
                                    .enableSpeakerphone(speaker);
                              });
                            },
                            child: Container(
                                width: 63.76,
                                height: 63.76,
                                decoration: ShapeDecoration(
                                  color: backendColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(62.06),
                                  ),
                                ),
                                child: Center(
                                    child: widget.isVideoCall
                                        ? SvgPicture.asset(
                                            "assets/speakerLogo.svg")
                                        : Icon(
                                            Icons.volume_off,
                                            color: Colors.white,
                                          ))),
                          ),
                          Expanded(child: SizedBox()),
                          GestureDetector(
                            onTap: () {
                              log("ending the call ");
                              _disconnect(callSocket, true);
                            },
                            child: Container(
                              width: 63.76,
                              height: 63.76,
                              decoration: ShapeDecoration(
                                color: Color(0xFFFF3131),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(62.06),
                                ),
                              ),
                              child: Center(
                                  child:
                                      SvgPicture.asset("assets/endCall.svg")),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            videoControl
                ? Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    height: 30,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                      child: Container(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: ShapeDecoration(
                                color: Color(0x14191B1A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                    "assets/videoCallbackArrow.svg"),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              widget.otherPersonData != null
                                  ? widget.otherPersonData!.publicName
                                      .toString()
                                  : "${widget.callTo}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
