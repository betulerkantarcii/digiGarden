import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FlutterBlueApp extends StatefulWidget {
  final land;
  final LatLngBounds bounds;
  final sampleNo;
  const FlutterBlueApp({Key? key, required this.land, required this.bounds, required this.sampleNo}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? ScanScreen(land: widget.land, bounds: widget.bounds, sampleNo: widget.sampleNo)
        : BluetoothOffScreen(adapterState: _adapterState);
    return screen;
  }
}