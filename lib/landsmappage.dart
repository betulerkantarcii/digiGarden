import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class LandsMapData{
  final String landName;
  final List<LatLng> points;
  final List<int> np;

  LandsMapData(this.landName, this.points, this.np);
}

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

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0,0),
    zoom: 17,
  );

  List<LandsMapData> landsData = [];

  Set<Polygon> _polygone = HashSet<Polygon>();
  List<Marker> _markers = <Marker>[];

  List<LatLng> _landBounds = <LatLng>[];
  bool loading = false;

  LatLngBounds bounds = LatLngBounds(
    northeast: LatLng(0,0),
    southwest: LatLng(0,0),
  );


  @override
  void initState() {
    super.initState();
    loadData();
    Future.delayed(Duration(seconds: 1), () async {
      // do something here
      await boundsData();
      // do stuff
    });
    Future.delayed(Duration(seconds: 1), () async {
      // do something here
      await getMap();
      // do stuff
    });


  }


  getMap() {
    for(int i=0; i<landsData.length; i++) {
      double average = landsData[i].np.fold(0, (p, c) => p + c) / landsData[i].np.length;
      Color x = Colors.white;
      if(average > 0 && average <= 10){
        x = Colors.yellow;
      }
      if(average > 10 && average <= 20){
        x = Colors.lightGreen;
      }
      if(average > 20 && average <= 30){
        x = Colors.green;
      }
      if(average > 30 && average <= 40){
        x = Colors.deepOrange;
      }
      if(average > 40 && average <= 50){
        x = Colors.brown;
      }
      setState(() {
        _polygone.add(
            Polygon(
              polygonId: PolygonId('$i'),
              points: landsData[i].points,
              fillColor: x.withOpacity(0.3),
              geodesic: true,
              strokeWidth: 4,
              strokeColor: Colors.black45,
            )

        );
        _markers.add(
            Marker(
              markerId: MarkerId(i.toString()),
              position: landsData[i].points[i],
              icon: BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                  title: '${landsData[i].landName}',
                  snippet: 'Toprak ortalama $average% oranda azot  içermektedir.',
              ),
            )
        );

      });
    }
    loading=true;
  }

  boundsData(){
    var lngs = _landBounds.map<double>((m) => m.longitude).toList();
    var lats = _landBounds.map<double>((m) => m.latitude).toList();

    double topMost = lngs.reduce(max);
    double leftMost = lats.reduce(min);
    double rightMost = lats.reduce(max);
    double bottomMost = lngs.reduce(min);

    bounds = LatLngBounds(
      northeast: LatLng(rightMost, topMost),
      southwest: LatLng(leftMost, bottomMost),
    );
    double latcenter = (bounds.southwest.latitude + bounds.northeast.latitude) /
        2;
    double lngcenter = (bounds.southwest.longitude +
        bounds.northeast.longitude) / 2;
    _kGooglePlex = CameraPosition(
      target: LatLng(latcenter, lngcenter),
      zoom: 17,
    );
  }

  loadData() async {
    double latcenter=0;
    double lngcenter=0;
    await
    landsInfo.get().then( (QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        String _landName = "";
        List<LatLng> _landPoints = <LatLng>[];
        List<int> _nplevels = <int>[];
        LatLngBounds bounds = LatLngBounds(
          northeast: LatLng(0,0),
          southwest: LatLng(0,0),
        );
        landsInfo.doc(doc.id).collection('landPolygon').get().then((event) {
          setState(() {
            for (var doc in event.docs) {
              final docData = doc.data();
              GeoPoint geoPoint = docData.toString().contains('points')
                  ? docData["points"]
                  : GeoPoint(0, 0);
              double lat = geoPoint.latitude;
              double lng = geoPoint.longitude;
              LatLng latLng = new LatLng(lat, lng);
              _landPoints.add(latLng);
              _landBounds.add(latLng);
            }
          });
        });
        landsInfo.doc(doc.id).collection('soilSample').get().then((event) {
          setState(() {
            for (var doc in event.docs) {
              final docData = doc.data();
              final int np = docData.toString().contains('nitrogenPercent')
                  ? docData['nitrogenPercent']
                  : 0;
              _nplevels.add(np);
            }
          });
        });

       _landName = doc.get('name');

        landsData.add(LandsMapData(_landName, _landPoints, _nplevels));
      });
    });

  }



  @override
  Widget build(BuildContext context) {
    if(loading == true) {
      return Scaffold(
        backgroundColor: Colors.brown.shade100,
        appBar: AppBar(
          title: const Text("Tüm Parseller"),
        ),
        body: Container(
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            markers: Set<Marker>.of(_markers),
            myLocationButtonEnabled: false,
            compassEnabled: false,
            buildingsEnabled: false,
            indoorViewEnabled: false,
            scrollGesturesEnabled: false,
            mapToolbarEnabled: false,
            trafficEnabled: false,
            tiltGesturesEnabled: false,
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
    return Scaffold(
        backgroundColor: Colors.brown.shade100,
        appBar: AppBar(
        title: const Text("Tüm Parseller"),
    ),
    body: Center(
      child:Text("Yükleniyor...", style: TextStyle(fontSize: 20)),
    )
    );
  }

}