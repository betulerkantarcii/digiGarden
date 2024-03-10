import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SoilInfoPage extends StatefulWidget {
  const SoilInfoPage({super.key, required this.soil});
  final soil;
  @override
  State<SoilInfoPage> createState() => _SoilInfoPageState();
}

class _SoilInfoPageState extends State<SoilInfoPage> {
  @override
  Widget build(BuildContext context) {
    GeoPoint geoPoint = widget.soil.toString().contains('points') ? widget.soil["points"]: GeoPoint(0, 0);
    double lat = geoPoint.latitude;
    double lng = geoPoint.longitude;


    DateTime dt =  widget.soil.toString().contains('date') ? widget.soil["date"].toDate(): DateTime(1998, 02, 09);
    final date = new DateFormat('dd-MM-yyyy').format(dt);


    return Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: AppBar(
          title: Text('${widget.soil.toString().contains('name') ? widget.soil["name"]:''}', style:TextStyle(fontSize: 25)),
        ),
        body:SingleChildScrollView(
        child:Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child:Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Center(
                    child:Text("Azot Yüzdesi", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),

                  ),
                  SizedBox(height: 20,),
                  CircularPercentIndicator(
                    animation: true,
                    animationDuration: 1000,
                    radius:300,
                    lineWidth: 40,
                    percent: (widget.soil.toString().contains('nitrogenPercent') ? widget.soil["nitrogenPercent"]:0)/100,
                    progressColor: Colors.brown,
                    backgroundColor: Colors.brown.shade200,
                    circularStrokeCap: CircularStrokeCap.butt,
                    center: Text('${widget.soil.toString().contains('nitrogenPercent') ? widget.soil["nitrogenPercent"]:''}%'!, style: TextStyle(fontSize: 50)),
                  ),
                  SizedBox(height: 20,),
                  LinearPercentIndicator(
                    animation:true,
                    animationDuration:1000,
                    lineHeight:30,
                    percent:(widget.soil.toString().contains('nitrogenPercent') ? widget.soil["nitrogenPercent"]:0)/100,
                    progressColor: Colors.brown,
                    backgroundColor: Colors.brown.shade200,
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            height: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 10.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.lightGreen,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1.0,
                                      spreadRadius: 1.0,
                                      color: Colors.grey[400]!
                                  ),
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Koordinatlar"!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize:19.0,
                                      fontWeight: FontWeight.bold,
                                    )
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                    "$lat, $lng"!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize:18.0,
                                    )
                                ),
                              ],
                            )

                        ),
                      ),

                      Expanded(
                        child: Container(
                            height: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 10.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.blueGrey.shade300,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1.0,
                                      spreadRadius: 1.0,
                                      color: Colors.grey[400]!
                                  ),
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Örnek Alınma Tarihi"!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize:19.0,
                                      fontWeight: FontWeight.bold,
                                    )
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                    "$date"!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize:20.0,
                                    )
                                ),
                              ],
                            )

                        ),
                      ),

                    ],

                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                            height: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 10.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.deepOrangeAccent,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1.0,
                                      spreadRadius: 1.0,
                                      color: Colors.grey[400]!
                                  ),
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Üzerinde Yetişen Ürün"!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize:19.0,
                                      fontWeight: FontWeight.bold,
                                    )
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                    "${widget.soil.toString().contains('product') ? widget.soil["product"]:''}"!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize:20.0,
                                    )
                                ),
                              ],
                            )

                        ),
                      ),

                      Expanded(
                        child: Container(
                            height: 150,
                            margin: const EdgeInsets.symmetric(horizontal: 10.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.orangeAccent,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 1.0,
                                      spreadRadius: 1.0,
                                      color: Colors.grey[400]!
                                  ),
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Nem Yüzdesi"!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize:18.0,
                                      fontWeight: FontWeight.bold,
                                    )
                                ),
                                const SizedBox(height: 10.0),
                                Text(
                                    "${widget.soil.toString().contains('moistPercent') ? widget.soil["moistPercent"]:''}%"!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize:20.0,
                                    )
                                ),
                              ],
                            )

                        ),
                      ),

                    ],

                  ),
                ],

              )
          ),

        ),
        )
    );
  }
}

