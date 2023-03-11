import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LandsMapPage extends StatefulWidget {

  final landsInfo;
  const LandsMapPage({super.key, required this.landsInfo});

  @override
  State<LandsMapPage> createState() => _LandsMapPageState(landsInfo:landsInfo);
}


class _LandsMapPageState extends State<LandsMapPage> {

  final landsInfo;
  _LandsMapPageState({required this.landsInfo});

  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  Set<Polygon> _polygone = HashSet<Polygon>();

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(38.9569, 35.6324),
    zoom: 17,
  );



  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    int count = 1;
    double latcenter=0;
    double lngcenter=0;
    await
    landsInfo.get().then( (QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        List<LatLng> _landPoints = <LatLng>[];
        List<double> _opacity = <double>[];
        LatLngBounds bounds = LatLngBounds(
          northeast: LatLng(0,0),
          southwest: LatLng(0,0),
        );
        int nitroSum = 0;
        int countSum = 0;
        landsInfo.doc(doc.id).collection('landPolygon').get().then((event) {
          setState(() {
            for (var doc in event.docs) {
              final docData = doc.data();
              GeoPoint geoPoint = docData.toString().contains('points') ? docData["points"]: GeoPoint(0, 0);
              double lat = geoPoint.latitude;
              double lng = geoPoint.longitude;
              LatLng latLng = new LatLng(lat, lng);
              _landPoints.add(latLng);
            }
            var lngs = _landPoints.map<double>((m) => m.longitude).toList();
            var lats = _landPoints.map<double>((m) => m.latitude).toList();
            double topMost = lngs.reduce(max);
            double leftMost = lats.reduce(min);
            double rightMost = lats.reduce(max);
            double bottomMost = lngs.reduce(min);
            bounds = LatLngBounds(
              northeast: LatLng(rightMost, topMost),
              southwest: LatLng(leftMost, bottomMost),
            );
            latcenter += ((bounds.southwest.latitude + bounds.northeast.latitude) / 2);
            lngcenter += ((bounds.southwest.longitude + bounds.northeast.longitude) / 2);
            /*
            _kGooglePlex = CameraPosition(
              target: LatLng(latcenter/(count-1), lngcenter/(count-1)),
              zoom: 17,
            );
             */

          });
        });

        landsInfo.doc(doc.id).collection('soilSample').get().then((event) {
          setState(() {
            for (var doc in event.docs) {
              final docData = doc.data();
              final int np = docData.toString().contains('nitrogenPercent')
                  ? docData['nitrogenPercent']
                  : 0;
            }
          });
        });
        setState(() {
          _polygone.add(
              Polygon(
                polygonId: PolygonId('$count'),
                points: _landPoints,
                fillColor: Colors.brown.withOpacity(0.3),
                geodesic: true,
                strokeWidth: 4,
                strokeColor: Colors.black45,
              )

          );
          count++;
        });
      });
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade100,
      appBar: AppBar(
        title: const Text("Tüm Parseller"),
      ),
      body: Container(
        height: 500,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          buildingsEnabled: false,
          indoorViewEnabled: false,
          scrollGesturesEnabled: false,
          mapToolbarEnabled: false,
          trafficEnabled: false,
          tiltGesturesEnabled:false,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          rotateGesturesEnabled: true,
          minMaxZoomPreference: const MinMaxZoomPreference(10, 30),
          polygons: _polygone,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );

  }

}