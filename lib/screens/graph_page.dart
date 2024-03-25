import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:digigarden_demo/mainpage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:location/location.dart';
import '../soilsamplepage.dart';


class GraphPage extends StatefulWidget {
  final List<double> recordedValues;
  final BluetoothDevice device;
  final land;
  final LocationData locationData;
  final sampleNo;
  const GraphPage({Key? key, required this.device, required this.recordedValues, required this.land, required this.locationData, required this.sampleNo}) : super(key: key);


  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  late var interpreter;
  var result = "%";
  int nitrogenPercent = 0;

  @override
  void initState() {
    // TODO: implement initState
    loadModel();
    super.initState();
  }

  loadModel() async {
    interpreter = await tfl.Interpreter.fromAsset('assets/model_NH4.tflite');
    var last_value = widget.recordedValues[widget.recordedValues.length -1];
    var first_value = widget.recordedValues[0];
    var net_value = last_value -first_value/4;
    var input = [net_value];
    var output = List.filled(1 * 1, 0).reshape([1, 1]);
    interpreter.run(input, output);
    if (output[0][0] >= 1.0) {
      output[0][0] = 1.0;
    }
    nitrogenPercent = (output[0][0] * 100).toInt();
    result = "${(output[0][0] * 100).toStringAsFixed(2)}%";
    setState(() {
      result;
      nitrogenPercent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked : (didPop) {
      if (didPop) {
        return;
      }
    },
    child:Scaffold(
      appBar: AppBar(
        title: Text('Graph Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          widget.recordedValues.length,
                              (index) => FlSpot(
                            index.toDouble() / (widget.recordedValues.length - 1) * 60,
                            widget.recordedValues[index],
                          ),
                        ),
                        isCurved: true,
                        color: Colors.blue,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
            ),
           Expanded(
             flex:1,
             child:Padding(
               padding: EdgeInsets.all(16.0),
               child: Column(
                 children: [
                   Text("Azot Oranı %"),
                   SizedBox(
                     height: 10,
                   ),
                   Text(result),
                 ],
               )
             )

           ),
           Expanded(
              flex:1,
              child:Padding(
              padding: EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  widget.device.disconnect();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {return SoilSamplePage(land: widget.land, locationData: widget.locationData, sampleNo: widget.sampleNo, nitrogenPercent: nitrogenPercent);}));
                },
                child: Text('Ölçümü Ekle'),
              ),
            )),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    ));
  }
}
