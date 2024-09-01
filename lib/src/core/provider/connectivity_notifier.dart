import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityNotifier extends ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;

  ConnectivityNotifier() {
    _initialize();
  }

  void _initialize() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      final bool isConnected = !result.contains(ConnectivityResult.none);
      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
