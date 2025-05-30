import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:koram_app/Helper/Helper.dart';
import 'package:koram_app/Models/NewUserModel.dart';
import 'package:koram_app/Models/User.dart';
import 'package:provider/provider.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

import 'HomeScreen.dart';

class VideoCallingScreen extends StatefulWidget {
  final String caller;
  final String callTo;
  Function? callback;
  bool isReceiving;
  var sockettemp;
  VideoCallingScreen(
      {required this.callTo,
      required this.caller,
      required this.isReceiving,
      this.callback,
      this.sockettemp});

  @override
  _VideoCallingScreenState createState() => _VideoCallingScreenState();
}

class _VideoCallingScreenState extends State<VideoCallingScreen> {
  bool _offer = false;
  var calling = false;
  bool connected = false;
  late RTCPeerConnection _peerConnection;
  final _localRenderer = new RTCVideoRenderer();
  final _remoteRenderer = new RTCVideoRenderer();
  late IOWebSocketChannel _channel;
  var temp;
  bool video = true;

  bool speaker = false;
  late MediaStream _localStream;

  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  void logMediaStream(MediaStream mediaStream) {
    log("MEDIAAAAAAAAAAAAAAAAAAAAAA");
    print('MediaStream ID: ${mediaStream.id}');

    mediaStream.getTracks().forEach((MediaStreamTrack track) {
      print('Track ID: ${track.id}');
      print('Track Kind: ${track.kind}');
      print('Track Label: ${track.label}');
      print('Track Enabled: ${track.enabled}');
    });
  }

  @override
  dispose() {
    // _localStream.dispose();
    // _localRenderer.dispose();
    // _remoteRenderer.dispose();
    // _channel.sink.close();
    // super.dispose();

    widget.callback;

    _channel.sink.add(
      jsonEncode(
        {
          "type": "leave",
          "name": temp["name"],
        },
      ),
    );
    _peerConnection.removeStream(_localStream);
    _peerConnection.dispose();
    _peerConnection.close();
    _channel.sink.close();
    _localStream.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();

    super.dispose();
    // Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void initState() {
    initRenderers();
    var counter = 0;
    _channel = IOWebSocketChannel.connect("ws://${G.IP}:9090");

    _channel.stream.listen((message) {
      counter++;
      temp = jsonDecode(message);
      log("message Printtt $counter");
      print(message);
      log("namee $counter ${temp["name"]}");
      switch (temp["type"]) {
        case "offer":
          {
            _setRemoteDescription(temp["offer"]);
            setState(() {
              incoming = true;
            });
          }
          break;
        case "answer":
          log("ANSWERRRR LOGG ${temp["answer"]}");
          _setRemoteDescription(temp["answer"]);
          break;

        case "candidate":
          _addCandidate(temp["candidate"]);
          break;

        case "leave":
          _disconnect();
          break;
      }
    }, onDone: () {
      log("done from Audiooo @@@@@@@");
    });

    _createPeerConnection().then((pc) {
      log("Create PeerConnection ${pc.toString()}");
      _peerConnection = pc;
      _channel.sink.add(jsonEncode({
        "type": "login",
        "name": widget.caller,
        "otherName": widget.callTo
      }));

      log("inside init olf audio");
      if (widget.isReceiving) {
        log("inside receiving@@@@@@@@@@@@@");
        log(widget.sockettemp.toString());
        _setRemoteDescription(widget.sockettemp);
        setState(() {
          incoming = true;
        });
      }
    });

    super.initState();
  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _createOffer() async {
    setState(() {
      calling = true;
    });
    final prefs = await SharedPreferences.getInstance();
    List<String> callHistory = prefs.getStringList("call_history") ?? [];
    callHistory.add(json.encode({
      "call_type": "video",
      "caller": widget.caller,
      "callTo": widget.callTo,
      "time": DateTime.now().toString()
    }));
    prefs.setStringList("call_history", callHistory);
    RTCSessionDescription description =
        await _peerConnection.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp!);
    log("session print statement");
    print(json.encode(session));

    _channel.sink.add(jsonEncode({
      "type": "offer",
      "name": widget.callTo,
      "offer": session,
      "callType": "Video"
    }));

    _offer = true;
    _peerConnection.onIceCandidate = (e) {
      if (e.candidate != null) {
        print(json.encode({
          'precandidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMLineIndex,
        }));

        _channel.sink.add(jsonEncode({
          "type": "candidate",
          "name": widget.callTo,
          "candidate": {
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          }
        }));
      }
    };
    _peerConnection.setLocalDescription(description);
  }

  void _createAnswer(String sender) async {
    log("Inside ANswerr $sender");
    RTCSessionDescription description =
        await _peerConnection.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp!);
    print(json.encode(session));
    final prefs = await SharedPreferences.getInstance();
    List<String> callHistory = prefs.getStringList("call_history") ?? [];
    callHistory.add(json.encode({
      "call_type": "video",
      "caller": widget.callTo,
      "callTo": widget.caller,
      "time": DateTime.now().toString()
    }));
    prefs.setStringList("call_history", callHistory);
    _peerConnection.setLocalDescription(description);

    _channel.sink.add(jsonEncode(
        {"type": "answer", "name": widget.callTo, "answer": session}));

    _peerConnection.onIceCandidate = (e) {
      if (e.candidate != null) {
        print(json.encode({
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMLineIndex,
        }));

        _channel.sink.add(jsonEncode({
          "type": "candidate",
          "name": widget.callTo,
          "candidate": {
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          }
        }));
      }
    };
  }

  bool incoming = false;
  void _addCandidate(var can) async {
    dynamic session = can;
    log("Before Printing Candidate");
    print(session['candidate']);
    dynamic candidate = new RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection.addCandidate(candidate);
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {
          "url": 'turn:contabo.dexteroot.ml:3478?transport=udp',
          "credential": '131313',
          "username": 'yogirajh007'
        }
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);
    if (pc != null) print(pc);

    pc.addStream(_localStream);
    pc.getRemoteStreams();
    pc.onIceConnectionState = (e) {
      log("On ice connection state");

      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      log("STREAMMMM $stream");
      setState(() {
        calling = false;
        connected = true;
      });

      setState(() {
        _remoteRenderer.srcObject = stream;
        print("gggggggggggggg ${stream}");
        logMediaStream(stream);
      });
    };

    return pc;
  }

  late Map<String, dynamic> mediaConstraints;
  _getUserMedia() async {
    mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    setState(() {
      _localRenderer.srcObject = stream;
    });

    return stream;
  }

  void _setRemoteDescription(var obj) async {
    dynamic session = obj;
    log("Setting Remote desc logg offer $_offer");
    print(obj);
    log("after printing");
    String sdp = write(session, null);

    RTCSessionDescription description =
        new RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print(description.toMap());

    await _peerConnection.setRemoteDescription(description);
  }

  void _disconnect() async {
    _channel.sink.add(
      jsonEncode(
        {
          "type": "leave",
          "name": temp["name"],
        },
      ),
    );
    _peerConnection.removeStream(_localStream);
    _peerConnection.dispose();
    _peerConnection.close();
    _channel.sink.close();
    _localStream.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    if (widget.isReceiving) {
      widget.callback;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      Navigator.of(context).pop();
    }
  }

  bool mic = true;
  bool ans = false;

  @override
  Widget build(BuildContext context) {
    final UserDetail user = UserDetail();
    // Provider.of<UsersProviderClass>(context).getUserWithPhoneNumber(widget.caller);
    return Scaffold(
        key: _scaffoldkey,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
                // padding:
                //     EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                key: new Key("remote"),
                // margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                decoration: new BoxDecoration(color: Colors.transparent),
                child:
                    // calling == null
                    //     ?
                    Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                )
                // : Container(
                //     height: MediaQuery.of(context).size.height,
                //     width: MediaQuery.of(context).size.width,
                //     color: backendColor,
                //     // child: Image.network(
                //     //   G.HOST + "api/v1/images/" + user.profilePicUrl,
                //     //   fit: BoxFit.cover,
                //     // ),
                //   )
                ),
            Positioned(
                child: Container(
                    height: 170,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 120,
                          padding: EdgeInsets.all(3),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(G.HOST +
                                    "api/v1/images/" +
                                    user.publicProfilePicUrl!),
                              ),
                              Text(user.privateName!)
                            ],
                          ),
                        ),
                      ],
                    ))),
            Positioned(
              bottom: 0,
              child: Container(
                  height: 170,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      if (incoming)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (!ans)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    ans = true;
                                  });
                                  // _createAnswer(temp["name"]);
                                  _createAnswer(widget.callTo);

                                  // setState(() {
                                  //   ans = false;
                                  // });
                                },
                                child: CircleAvatar(
                                    radius: 30,
                                    child: Icon(Icons.call),
                                    backgroundColor: Colors.green),
                              ),
                            GestureDetector(
                              onTap: _disconnect,
                              child: CircleAvatar(
                                  radius: 30,
                                  child: Icon(Icons.call_end),
                                  backgroundColor: Colors.red),
                            ),
                          ],
                        )
                      else ...[
                        if (calling == false)
                          GestureDetector(
                            onTap: incoming
                                ? () async {
                                    _createAnswer(widget.callTo);
                                  }
                                : _createOffer,
                            child: CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.call),
                                backgroundColor: Colors.green),
                          )
                        else
                          GestureDetector(
                            onTap: _disconnect,
                            child: CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.call_end),
                                backgroundColor: Colors.red),
                          ),
                      ],
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  mic = !mic;
                                });
                                _localStream.getAudioTracks()[0].enabled = mic;
                              },
                              child: CircleAvatar(
                                  child: Icon(
                                    mic ? Icons.mic : Icons.mic_off,
                                    // size: 50,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () {
                                _localStream.getVideoTracks()[0].switchCamera();
                              },
                              child: CircleAvatar(
                                  child: Icon(
                                    Icons.cameraswitch,
                                    
                                  ),
                                  backgroundColor: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  video = !video;
                                });
                                _localStream.getVideoTracks()[0].enabled =
                                    video;
                              },
                              child: CircleAvatar(
                                  child: Icon(
                                    video ? Icons.videocam : Icons.videocam_off,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
            // Positioned(
            //   bottom: 0,
            //   child: Container(
            //       height: 150,
            //       width: MediaQuery.of(context).size.width,
            //       child: Column(
            //         children: [
            //           GestureDetector(
            //             child: CircleAvatar(
            //                 child: Icon(Icons.call_end),
            //                 backgroundColor: Colors.red),
            //           )
            //         ],
            //       )),
            // ),
            Positioned(
              bottom: 170,
              right: 5,
              child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.3,
                  key: new Key("local"),
                  margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                  decoration: new BoxDecoration(color: Colors.black),
                  child: calling == null
                      ? RTCVideoView(
                          _localRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : new RTCVideoView(_localRenderer,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          mirror: true)),
            )
          ],
        ));
  }
}
