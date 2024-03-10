import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'loginpage.dart';
import 'mainpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'logineditpage.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';


class AccountPage extends StatefulWidget{
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  signOut() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    return await auth.signOut();
  }

  Future logout() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut().then((value) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()),(route) => false));
  }

  var full_name;
  var email;
  var phone;
  var registration_date;
  var address;
  var birthdate;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        title: const Text('Hesabım', style:TextStyle(fontSize: 25)),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
            future: _fetch(),
            builder: (context, snapshot){
              if (snapshot.connectionState != ConnectionState.done)
                return Center(child:Text("Yükleniyor...", style: TextStyle(fontSize: 20),));
            return SingleChildScrollView(
             child:Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width:150,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image(image: AssetImage("assets/farmer.png")),
                  ),
                ),
                const SizedBox(height: 10),
                Text("$full_name", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("$email", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginEditPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text("Profilimi düzenle", style: TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 50),
                ListTile(
                  leading: Container(
                    width:50,
                    height:50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.phone, color: Colors.lightGreen, size: 30,),
                  ),
                  title: Text("$phone", style: TextStyle(fontSize: 20),),
                ),
                const SizedBox(height: 10,),
                ListTile(
                  leading: Container(
                    width:50,
                    height:50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.cake_rounded, color: Colors.lightGreen, size: 30,),
                  ),
                  title: Text("$birthdate", style: TextStyle(fontSize: 20),),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    width:50,
                    height:50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.password_rounded, color: Colors.lightGreen, size: 30,),
                  ),
                  title: Text("Şifre", style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    width:50,
                    height:50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.account_circle_rounded, color: Colors.lightGreen, size: 30,),
                  ),
                  title: Text("$registration_date", style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    width:50,
                    height:50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: Icon(Icons.location_on, color: Colors.lightGreen, size: 30,),
                  ),
                  title: Text("$address", style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                    onPressed: () async{
                      await logout();
                    },
                    child: const Text("Çıkış Yap", style:TextStyle(fontSize: 20.0))),
                const SizedBox(height: 20),
              ],
            ));
            }),
    );
  }

  _fetch() async{
    final firebaseUser = await FirebaseAuth.instance.currentUser;
    if(firebaseUser != null) {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if(docSnapshot.exists){
        Map<String, dynamic>? data = docSnapshot.data();
        email = firebaseUser.email;
        full_name = data?["full_name"];
        DateTime dt = data?["registration_date"].toDate();
        registration_date = new DateFormat('dd-MM-yyyy').format(dt);
        DateTime dtBirth = data?["birthdate"].toDate();
        birthdate = new DateFormat('dd-MM-yyyy').format(dtBirth);
        phone = data?["phone"];
        address = data?["address"];
      }
    }
  }
}