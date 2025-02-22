import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ChatSocketServices.dart';

class connectivityProvider extends ChangeNotifier
{
  var connectionStatus;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  startConnectivityListener() async {

    try {
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen((e){

            connectionStatus=e;
            log("the listen response $e");
            // notifyListeners();

          });


    } on PlatformException catch (e) {
      log('Couldn\'t check connectivity status', error: e);

    }

  }



  void stopListeningToConnectivity() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}