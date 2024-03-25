import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_date_textbox/cupertino_date_textbox.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'mainpage.dart';
import 'package:location/location.dart';

class SoilSamplePage extends StatefulWidget {
  final land;
  final LocationData locationData;
  final sampleNo;
  final nitrogenPercent;
  const SoilSamplePage({super.key, required this.land, required this.locationData, required this.sampleNo, required this.nitrogenPercent});
  @override
  State<SoilSamplePage> createState() => _SoilSamplePageState();
}

class _SoilSamplePageState extends State<SoilSamplePage> {

  TextEditingController _soilName = new TextEditingController();
  TextEditingController _moist = new TextEditingController();
  TextEditingController _product = new TextEditingController();


  DateTime _selectedDateTime = DateTime.now();

  bool allowDecimal=true;

  bool _validatesoilName = false;
  bool _validateMoist = false;
  bool _validateProduct = false;
  String _moistCheck = "Bu alanı doldurunuz";
  String _coordInfo = "Bu alanı doldurunuz";

  String _getRegexString() => allowDecimal ? r'[0-9]+[,.]{0,1}[0-9]*' : r'[0-9]';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      child: Scaffold(
          backgroundColor: Colors.brown[100],
          appBar: AppBar(
            title: Text('Toprak Örneği', style:TextStyle(fontSize: 25)),
          ),
          body:SingleChildScrollView(
            child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30,),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  controller: _soilName,
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Toprak Örneği Adı',
                      errorText: _validatesoilName?"Bu alanı doldurunuz":null,
                  ),
                ),
              ),
              const Text('Koordinatlar', style: TextStyle(fontSize: 20, color: Colors.black54)),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  ("Enlem: "+ widget.locationData.latitude!.toStringAsFixed(5)),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  ("Boylam: " + widget.locationData.longitude!.toStringAsFixed(5)),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const Text('Azot', style: TextStyle(fontSize: 20, color: Colors.black54)),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  ("Azot Yüzdesi: " + widget.nitrogenPercent.toString() + "%"),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  controller: _moist,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  style: const TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nem Yüzdesi %',
                    errorText: _validateMoist?_moistCheck:null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CupertinoDateTextBox(
                    fontSize: 20,
                    initialValue: _selectedDateTime,
                    onDateChange: onBirthdayChange,
                    hintText: DateFormat.yMd().format(_selectedDateTime)),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  controller: _product,
                  style: const TextStyle(fontSize: 20),
                  decoration:  InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Üzerinde Yetişen Ürün',
                     errorText: _validateProduct?"Bu alanı doldurunuz":null,
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: () async{
                setState(() {
                  _soilName.text.isEmpty ? _validatesoilName = true :  _validatesoilName = false;
                  _moist.text.isEmpty ? _validateMoist = true :  _validateMoist = false;
                  _product.text.isEmpty ? _validateProduct = true :  _validateProduct = false;


                  if(_moist.text.isNotEmpty) {
                    if (int.parse(_moist.text) >= 0 &&
                        int.parse(_moist.text) <= 100) {
                      _validateMoist = false;
                    }
                    else {
                      _moistCheck = "Değer 0 ile 100 arasında olmalıdır.";
                      _validateMoist = true;
                    }
                  }

                });
                if(_validatesoilName==false && _validateMoist==false && _validateProduct==false) {
                  var _date = Timestamp.fromMillisecondsSinceEpoch(
                      _selectedDateTime.millisecondsSinceEpoch);
                  double? lat = widget.locationData.latitude;
                  double? long = widget.locationData.longitude;
                  lat = double.parse(lat!.toStringAsFixed(5));
                  long = double.parse(long!.toStringAsFixed(5));
                  var _geopoint = GeoPoint(lat, long);
                  Map<String, dynamic> dataToSave = <String, dynamic>{
                    'date': _date,
                    'name': _soilName.text,
                    'nitrogenPercent': widget.nitrogenPercent,
                    'moistPercent': int.parse(_moist.text),
                    'points': _geopoint,
                    'product': _product.text,
                  };
                  await widget.land.collection("soilSample").add(dataToSave);
                  await widget.land.update({"sampleNo": widget.sampleNo + 1});
                  const snackBar = SnackBar(
                    content: Text('Toprak Örneği Eklendi!'),
                    backgroundColor: (Colors.black54),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  //Navigator.pop(context,true);
                  Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) {return MainPage(index: 1);}), (route) => false);
                }

              },
              child: const Text('Toprak Örneği Ekle', style: TextStyle(fontSize: 20))),
              const SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
              Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (context) {return MainPage(index: 1);}), (route) => false);
              }, child: const Text("Vazgeç", style: TextStyle(fontSize: 20))),
              const SizedBox(height: 20,),
            ],
          )
          )
      ),
    );
  }
  void onBirthdayChange(DateTime birthday) {
    setState(() {
      _selectedDateTime = birthday;
    });
  }



}