import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:math';
import 'soilinfopage.dart';
import 'soilsamplepage.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';


class GraphData{
  final String dt;
  final int np;
  final DateTime date;

  GraphData(this.dt, this.np, this.date);
}

class LandInfoPage extends StatefulWidget {

  final land;
  const LandInfoPage({super.key, required this.land});

  @override
  State<LandInfoPage> createState() => _LandInfoPageState(land: this.land);
}


class _LandInfoPageState extends State<LandInfoPage> {

   final land;
  _LandInfoPageState({required this.land});


  List<Marker> _markers = <Marker>[];
  Set<Polygon> _polygone = HashSet<Polygon>();
  static CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(0,0),
    zoom: 18,
  );


  List<GraphData> dataGraph = [];

  List<LatLng> _landPoints = <LatLng>[];

  List<LatLng> _soilPoints = <LatLng>[];

  LatLngBounds bounds = LatLngBounds(
    northeast: LatLng(0,0),
    southwest: LatLng(0,0),
  );

  Future<Uint8List> getBytesFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer
        .asUint8List();
  }


  @override
  void initState(){
    super.initState();
    checkCollection('landPolygon').then((result) {
      setState(() {
        if(result == true){
          loadDataPoly();
        }
      });
    });

    checkCollection('soilSample').then((result) {
      setState(() {
        if(result == true){
          loadDataSample();
        }
      });
    });

  }

   checkCollection(String collectionName) async{
    final snapshot = await land.collection(collectionName).get();
    if (snapshot.size > 0) {
      return true;
    }
    return false;
  }

  loadDataPoly() async {

    await land.collection('landPolygon').get().then((event) {
      for (var doc in event.docs) {
        final docData = doc.data();
        GeoPoint geoPoint = docData.toString().contains('points') ? docData["points"]: GeoPoint(0, 0);
        double lat = geoPoint.latitude;
        double lng = geoPoint.longitude;
        LatLng latLng = new LatLng(lat, lng);
        _landPoints.add(latLng);
      }
    });


    _polygone.add(
        Polygon(
          polygonId: PolygonId('1'),
          points: _landPoints,
          fillColor: Colors.brown.withOpacity(0.5),
          geodesic: true,
          strokeWidth: 4,
          strokeColor: Colors.black45,
        )

    );

    bounds = boundsData();
    double latcenter = (bounds.southwest.latitude + bounds.northeast.latitude) /
        2;
    double lngcenter = (bounds.southwest.longitude +
        bounds.northeast.longitude) / 2;
    _kGooglePlex = CameraPosition(
      target: LatLng(latcenter, lngcenter),
      zoom: 18,
    );


  }
   boundsData() {
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
     return bounds;
   }

  loadDataSample() async {
      await land.collection('soilSample').get().then((event) {
          for (var doc in event.docs) {
            final docData = doc.data();
            GeoPoint geoPoint = docData.toString().contains('points')
                ? docData["points"]
                : GeoPoint(0, 0);
            double lat = geoPoint.latitude;
            double lng = geoPoint.longitude;
            LatLng latLng = new LatLng(lat, lng);
            _soilPoints.add(latLng);
            DateTime dt = docData.toString().contains('date') ? docData["date"]
                .toDate() : DateTime(09, 02, 1998);
            final String date = new DateFormat('dd-MM-yyyy').format(dt);
            final int np = docData.toString().contains('nitrogenPercent')
                ? docData['nitrogenPercent']
                : 0;
            if(dt.year > 2022) {
              dataGraph.add(GraphData(date, np, dt));
            }
          }
        });

    dataGraph.sort((a, b){
      return a.date.compareTo(b.date);
    });


    final Uint8List markerIcon = await getBytesFromAssets('assets/point.png', 100);

    for (int i = 0; i < _soilPoints.length; i++) {
      _markers.add(
          Marker(
              markerId: MarkerId(i.toString()),
              consumeTapEvents: true,
              position: _soilPoints[i],
              icon: BitmapDescriptor.fromBytes(markerIcon),
              infoWindow: const InfoWindow(
                  title: 'Toprak Örneği'
              ),
              onTap: () async{
                var soil;
                await land.collection('soilSample').get().then((event){
                  soil = event.docs[i].data();
                });
                 Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SoilInfoPage(soil: soil)));
              }
          )
      );
      setState(() {

      });
    }
  }

  Future<void> _handleRefresh() async{
    Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (a,b,c) => LandInfoPage(land: land)));
    return await Future.delayed(Duration(seconds: 2));
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: widget.land.get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              backgroundColor: Colors.brown.shade100,
              body: const Center(
                  child: Text("Something went wrong"))
          );
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Scaffold(
              backgroundColor: Colors.brown.shade100,
              body:const Center(
                  child:Text("Document does not exist")));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Scaffold(
              backgroundColor: Colors.brown.shade100,
              appBar: AppBar(
                title: Text("${data.containsKey("name") ? snapshot.data!.get("name"):"null"}", style:TextStyle(fontSize: 25)),
              ),
              body: LiquidPullToRefresh(
                onRefresh: _handleRefresh,
                color: Colors.brown,
                height: 100,
                backgroundColor: Colors.brown[100],
                child: SingleChildScrollView(
                  child: Column(
                      children: [
                        Container(
                          height: 500,
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
                            tiltGesturesEnabled:false,
                            zoomGesturesEnabled: true,
                            zoomControlsEnabled: true,
                            rotateGesturesEnabled: true,
                            minMaxZoomPreference: const MinMaxZoomPreference(10, 30),
                            polygons: _polygone,
                            onMapCreated: (GoogleMapController controller) {
                              Completer<GoogleMapController> _controller = Completer();
                              _controller.complete(controller);
                            },),
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 1.0,
                                    spreadRadius: 1.0,
                                    color: Colors.grey[400]!
                                ),
                              ]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(
                                    'assets/address.png'!,
                                    width:50.0,
                                    height: 50.0,
                                    fit:BoxFit.cover,
                                  )
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Adres"!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize:18.0,
                                            fontWeight: FontWeight.bold,
                                          )
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text(
                                          "${data.containsKey("address") ? snapshot.data!.get("address"):"null"}"!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize:17.0,
                                          )
                                      ),
                                    ]
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 1.0,
                                    spreadRadius: 1.0,
                                    color: Colors.grey[400]!
                                ),
                              ]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(
                                    'assets/soilsample.png'!,
                                    width:50.0,
                                    height: 50.0,
                                    fit:BoxFit.cover,
                                  )
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Toprak Örnekleri ${data.containsKey("sampleNo") ? snapshot.data!.get("sampleNo"):"0"}/${data.containsKey("maxSample") ? snapshot.data!.get("maxSample"):"0"}"!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize:18.0,
                                            fontWeight: FontWeight.bold,
                                          )
                                      ),
                                      const SizedBox(height: 10.0),
                                      LinearPercentIndicator(
                                        lineHeight:10,
                                        percent: (data.containsKey("sampleNo") ? snapshot.data!.get("sampleNo"):0)/(data.containsKey("maxSample") ? snapshot.data!.get("maxSample"):1),
                                        progressColor: Colors.black54,
                                        backgroundColor: Colors.black26,
                                      ),
                                    ]
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 1.0,
                                    spreadRadius: 1.0,
                                    color: Colors.grey[400]!
                                ),
                              ]
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.asset(
                                    'assets/garden.png'!,
                                    width:50.0,
                                    height: 50.0,
                                    fit:BoxFit.cover,
                                  )
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "Yetişen ürünler"!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize:18.0,
                                            fontWeight: FontWeight.bold,
                                          )
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text(
                                          "${data.containsKey("products") ? snapshot.data!.get("products"):"null"}"!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize:17.0,
                                          )
                                      ),
                                    ]
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 1.0,
                                    spreadRadius: 1.0,
                                    color: Colors.grey[400]!
                                ),
                              ]
                          ),
                          child: SfCartesianChart(
                            backgroundColor: Colors.white,
                            palette: [Colors.lightGreen],
                            primaryXAxis: CategoryAxis(),
                            title: ChartTitle(text: 'Azot-Zaman Grafiği', textStyle: TextStyle(fontWeight: FontWeight.bold)),
                            legend: Legend(isVisible: true),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <ChartSeries<GraphData, String>>[
                              LineSeries<GraphData, String>(
                                width: 3,
                                dataSource: dataGraph,
                                xValueMapper: (GraphData dataG, _) => dataG.dt,
                                yValueMapper: (GraphData dataG, _) => dataG.np,
                                name: 'Azot %',
                                markerSettings: const MarkerSettings(
                                    isVisible: true,
                                    height: 4,
                                    width: 4,
                                    shape: DataMarkerType.circle,
                                    borderWidth: 3,
                                    borderColor: Colors.brown),
                                dataLabelSettings: DataLabelSettings(isVisible: true),
                              ),

                            ],
                          ),
                        ),
                        SizedBox(height: 100,),
                      ]),
                ),
              ),
            floatingActionButton: FloatingActionButton.extended(
              elevation: 4.0,
              icon: const Icon(Icons.add),
              label: const Text('Toprak Örneği Ekle'),
              onPressed: () {
                Navigator.push( context, MaterialPageRoute( builder: (context) => SoilSamplePage(land: land, bounds: bounds, sampleNo: data['sampleNo'])), ).then((value) => setState(() {
                  _handleRefresh();
                }));

                },
            ),
            floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          );
        }

        return Scaffold(
            backgroundColor: Colors.brown.shade100,
            body:const Center(
              child:Text("YÜKLENİYOR...")));
      },
    );
  }
}




