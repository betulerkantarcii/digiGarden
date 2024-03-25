import 'dart:async';
import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'record_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class SensorScreen extends StatefulWidget {
  final BluetoothDevice device;
  final land;
  final LatLngBounds bounds;
  final sampleNo;
  const SensorScreen({Key? key, required this.device,required this.land, required this.bounds, required this.sampleNo}) : super(key: key);


  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  late bool isReady;
  late Stream<List<int>> stream;
  List<double> traceCapacitance = [];
  late LocationData locationData;

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    new Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        _Pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _Pop();
      return;
    }

    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;
            setState(() {
              isReady = true;
            });
          }
        });
      }
    });

    if (!isReady) {
      _Pop();
    }
  }

  Future<bool> _onWillPop() async{
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emin misiniz?'),
        content: Text('Cihazla bağlantıyı kesmek ve geri dönmek mi istiyorsunuz?'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Hayır'),
          ),
          ElevatedButton(
            onPressed: () {
              disconnectFromDevice();
              Navigator.of(context).pop(true);
            },
            child: Text('Evet'),
          ),
        ],
      ),
    ) ?? false;
  }

  _Pop() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }


  Future<bool> _onWrongLoc() async{
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ölçüm Başlatılamıyor'),
        content: Text('Ölçüm yapabilmemiz için tarlanızın sınırları içinde olmanız gerekir!'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Tamam'),
          ),
        ],
      ),
    ) ?? false;
  }

  _getLocation() async{
    Location location = Location();
    locationData = await location.getLocation();
    double? lat = locationData.latitude;
    double? long = locationData.longitude;
    lat = double.parse(lat!.toStringAsFixed(5));
    long = double.parse(long!.toStringAsFixed(5));
    var _point = LatLng(lat!, long!);
    return _point;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kağıt-tabanlı Elektrikli Gaz Sensörü'),
        ),
        body: Container(
            child: !isReady
                ? Center(
              child: Text(
                "Bağlanıyor..",
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
            )
                : Container(
              child: StreamBuilder<List<int>>(
                stream: stream,
                builder: (BuildContext context,
                    AsyncSnapshot<List<int>> snapshot) {
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');

                  if (snapshot.connectionState ==
                      ConnectionState.active) {
                    var currentValue = _dataParser(snapshot.requireData);
                    traceCapacitance.add(double.tryParse(currentValue) ?? 0);

                    return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Sensörden okunan değer',
                                        style: TextStyle(fontSize: 14)),
                                    Text('${currentValue}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24))
                                  ]),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              flex: 1,
                              child:ElevatedButton(
                                    onPressed: () async{
                                      var _point = await _getLocation();
                                      if (widget.bounds.contains(_point) == true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => RecordScreen(device: widget.device,stream: stream, land: widget.land, locationData: locationData, sampleNo: widget.sampleNo)),
                                        );
                                      }
                                      else {
                                        _onWrongLoc();
                                      }
                                    },
                                    child: Text('Ölçüme Başla'),
                                ),
                            ),
                            SizedBox(
                              height: 200,
                            )
                          ],
                        ));
                  } else {
                    return Text('Bağlantıyı kontrol edin');
                  }
                },
              ),
            )),
      ),
    );
  }
}