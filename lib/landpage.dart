import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'landinfopage.dart';
import 'dart:convert';

import 'landsmappage.dart';


class LandPage extends StatefulWidget {
  const LandPage({super.key});
  @override
  State<LandPage> createState() => _LandPageState();
}


class _LandPageState extends State<LandPage> {
  final _firestore = FirebaseFirestore.instance;


  String text = "";
  @override
  Widget build(BuildContext context) {

    var user = _firestore.collection('users').doc('HwuG5gvspdZM0SxATgpu');
    var landsInfo = user.collection("lands");

    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        title: const Text("Parsellerim", style:TextStyle(fontSize: 25)),
      ),
      body: StreamBuilder(
        stream: landsInfo.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
          if(streamSnapshot.hasData){
            return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index){
                  final DocumentSnapshot item = streamSnapshot.data!.docs[index];
                  return Padding(
                    padding: (index == 0)
                        ? const EdgeInsets.symmetric(vertical: 20.0)
                        : const EdgeInsets.only(bottom: 20.0),
                    child: Slidable(
                      key: Key('$item'),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                              onPressed: (context) {
                                showDialog(
                                    context: context,
                                    builder: (context) => SimpleDialog(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText: 'Parsel adını değiştir',
                                              labelStyle: TextStyle(fontSize: 20.0),
                                            ),
                                            style: const TextStyle(fontSize: 20.0),
                                            onChanged: (value){
                                              setState(() {
                                                text= value;
                                              });
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                              onPressed: () async{
                                                  await landsInfo.doc(item!.id).update({"name":text});
                                              },
                                              child: const Text("Güncelle", style:TextStyle(fontSize: 20.0))),
                                        )
                                      ],
                                    )
                                );
                              },
                              backgroundColor: Colors.lightGreen,
                              icon:Icons.edit),
                        ],),
                      child: GestureDetector(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                      'assets/land1.png',
                                      width:100.0,
                                      height: 100.0,
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
                                            item.data().toString().contains('name') ? item.get('name') : '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize:20.0,
                                              fontWeight: FontWeight.bold,
                                            )
                                        ),
                                        const SizedBox(height: 10.0),
                                        const Text(
                                            'Parsel hakkındaki bilgiler için dokunun',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:15.0,
                                              color: Colors.grey,
                                            )
                                        ),
                                      ]
                                  ),
                                )
                              ],
                            ),
                          ),
                          onTap: () async{
                            var landItem = await landsInfo.doc(item.id);
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>LandInfoPage(land:landItem)));
                          }
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton.extended(
          elevation: 4.0,
          label: const Text('Tüm Parseller'),
          onPressed: () {
            Navigator.push( context, MaterialPageRoute( builder: (context) => LandsMapPage(landsInfo: landsInfo)));
          },
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
    );
  }
}