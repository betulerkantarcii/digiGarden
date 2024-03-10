import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:intl/intl.dart';
import 'mainpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_date_textbox/cupertino_date_textbox.dart';

class EditAccountPage extends StatefulWidget{
  const EditAccountPage({super.key, required this.email, required this.password});
  final email;
  final password;
  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {

  TextEditingController _fullnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  var auth = FirebaseAuth. instance;
  var currentUser = FirebaseAuth.instance.currentUser;
  var account;

  var full_name;
  var phone;
  var address;

  bool _validateEmail = true;
  bool _validatePassword = true;



  _fetchInfo() async{
    final firebaseUser = await FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      account = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);
    }
    if(firebaseUser != null) {
      var docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if(docSnapshot.exists){
        Map<String, dynamic>? data = docSnapshot.data();
        full_name = data?["full_name"];
        phone = data?["phone"];
        address = data?["address"];
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: AppBar(
          title: const Text('Profilimi Düzenle', style: TextStyle(fontSize: 25)),
        ),
        body: FutureBuilder(
        future: _fetchInfo(),
        builder: (context, snapshot){
        if (snapshot.connectionState != ConnectionState.done)
          return Center(child:Text("Yükleniyor...", style: TextStyle(fontSize: 20),));
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _fullnameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: '$full_name',
                    hintText: "Ad Soyad",
                    prefixIcon: Icon(Icons.account_circle_rounded),
                  ),
                  style: TextStyle(fontSize:20),
                ),
                const SizedBox(height: 20,),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: widget.email,
                    hintText: "E-Posta Adresi",
                    prefixIcon: Icon(Icons.mail),
                    errorText: _validateEmail?null:"E-posta formatı doğru değildir. Lütfen ornek@ornek.com şeklinde deneyiniz."
                  ),
                  style: TextStyle(fontSize:20),
                ),
                const SizedBox(height: 20,),
                TextField(
                  controller: _phoneController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: '$phone',
                    hintText: "Telefon No",
                    prefixIcon: Icon(Icons.phone),
                  ),
                  style: TextStyle(fontSize:20),
                ),
                const SizedBox(height: 20,),
                TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: widget.password,
                    hintText: "Şifre",
                    prefixIcon: Icon(Icons.password_rounded),
                    errorText: _validatePassword?null:"Şifreniz en az 6 karakterden oluşmalıdır!"
                  ),
                  style: TextStyle(fontSize:20),
                ),
                const SizedBox(height: 20,),
                TextField(
                  controller: _addressController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: '$address',
                    hintText: "Adres",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  style: TextStyle(fontSize:20, color: Colors.black),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                    onPressed: () async{
                      setState(() {
                       if(_emailController.text.isEmpty){
                         _validateEmail=true;
                       }
                       else if(EmailValidator.validate(_emailController.text)){
                         _validateEmail = true;
                       }
                       else{
                         _validateEmail = false;
                       }

                       if(_passwordController.text.isEmpty){
                         _validatePassword=true;
                       }
                       else if(_passwordController.text.length >=6){
                         _validatePassword=true;
                       }
                       else{
                         _validatePassword=false;
                       }

                      });

                      loadInfo();

                      const snackBar = SnackBar(
                        content: Text('Bilgiler kaydedildi!'),
                        backgroundColor: (Colors.black54),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainPage(index:2)),(route) => false);

                    },
                    child: const Text("Kaydet", style:TextStyle(fontSize: 20.0))),
              ],
            )
          )

        );
        }),);

  }

  loadInfo() async{
    if(_fullnameController.text.isNotEmpty) {
      await account.update({"full_name": _fullnameController.text});
    }
    if(_validateEmail == true && _emailController.text.isNotEmpty){
      await currentUser!.updateEmail(_emailController.text);
    }
    if(_phoneController.text.isNotEmpty){
      await account.update({"phone": _phoneController.text});
    }
    if(_addressController.text.isNotEmpty){
      await account.update({"address": _addressController.text});
    }
    if(_validatePassword == true && _passwordController.text.isNotEmpty){
      await currentUser!.updatePassword (_passwordController.text);
    }
  }


}

