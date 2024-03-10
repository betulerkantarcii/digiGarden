import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatefulWidget{
  const ForgetPasswordPage({super.key});
  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPage();
}
class _ForgetPasswordPage extends State<ForgetPasswordPage> {
  TextEditingController _emailController = TextEditingController();

  @override
  void dispose(){
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async{
   try{
     await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
     showDialog(context: context, builder: (context){
       return AlertDialog(
         content: Text("Şifre yenileme linki, e-posta adresinize gönderildi. Lütfen e-posta kutunuzu kontrol edin."),
       );
     });
   } on FirebaseAuthException catch (e){
     showDialog(context: context, builder: (context){
       return AlertDialog(
         content: Text("Bu e-posta adresi sistemimizde kayıtlı değildir!"),
       );
     });
   }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        title: Text('Şifre Yenileme', style: TextStyle(fontSize: 25)),
      ),
      body:  Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Şifre yenileme linki, e-posta adresinize gönderilecektir.', style: TextStyle(fontSize: 20, color: Colors.black54),),
          const SizedBox(
            height: 44.0,
          ),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "E-Posta",
              prefixIcon: Icon(Icons.mail, color:Colors.black),
            ),
          ),
          const SizedBox(
            height: 88.0,
          ),
          Center(
            child: Container(
                width: double.infinity,
                child: RawMaterialButton(
                  fillColor: Colors.brown,
                  elevation: 3.0,
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)
                  ),
                  onPressed: () {
                    passwordReset();
                  },
                  child: const Text("Gönder", style: TextStyle(color: Colors.white, fontSize: 18.0),),
                )
            ),
          )
        ],
        ),
      ),
    );
  }
}

