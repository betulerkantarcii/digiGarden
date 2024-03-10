import 'package:digigarden_demo/editaccountpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgetpasswordpage.dart';

class LoginEditPage extends StatefulWidget{
  const LoginEditPage({super.key});
  @override
  State<LoginEditPage> createState() => _LoginEditPage();
}

class _LoginEditPage extends State<LoginEditPage>{
  Future<FirebaseApp> _initilizeFirebase() async{
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: AppBar(
          title: Text("Profili Düzenle"),
        ),
        body:FutureBuilder(
          future: _initilizeFirebase(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.done){
              return LoginInfoPage();
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        )
    );
  }
}

class LoginInfoPage extends StatefulWidget {
  const LoginInfoPage({super.key});
  @override
  State<LoginInfoPage> createState() => _LoginInfoPageState();
}


class _LoginInfoPageState extends State<LoginInfoPage> {

  var emailMessage;
  var passwordMessage;
  static String error_message = "";
  static bool _validateEmail = false;
  static bool _validatePassword = false;

  static Future<User?> loginUsingEmailPassword({
    required String email,
    required String password,
    required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e){
      error_message = e.code;
    }
    return user;
  }



  @override
  Widget build(BuildContext context) {
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profili düzenlemek için bilgileri giriniz!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 33.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 44.0,
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration:  InputDecoration(
                hintText: "E-Posta Adresi",
                prefixIcon: Icon(Icons.mail, color:Colors.black),
                errorText: _validateEmail?emailMessage:null,
              ),
            ),
            const SizedBox(
              height: 26.0,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Şifre",
                prefixIcon: Icon(Icons.lock, color: Colors.black),
                errorText: _validatePassword?passwordMessage:null,
              ),
            ),
            const SizedBox(
              height: 12.0,
            ),
            const SizedBox(
              height: 88.0,
            ),
            Container(
                width: double.infinity,
                child: RawMaterialButton(
                  fillColor: Colors.brown,
                  elevation: 3.0,
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)
                  ),
                  onPressed: () async{
                    User? user = await loginUsingEmailPassword(email: _emailController.text, password: _passwordController.text, context: context);
                    setState(() {
                      if(error_message == 'user-not-found'){
                        _validateEmail = true;
                        emailMessage = "Bu e-posta adresi sistemimize kayıtlı değildir.";
                      }
                      else if(error_message == 'invalid-email'){
                        _validateEmail = true;
                        emailMessage = "E-posta formatı doğru değildir. Lütfen ornek@ornek.com şeklinde deneyiniz.";
                      }
                      else{
                        _validateEmail = false;
                      }
                      if(error_message == 'wrong-password'){
                        _validatePassword = true;
                        passwordMessage = "Şifre doğru değil.";
                      }
                      else{
                        _validatePassword = false;
                      }
                    });
                    if(user != null){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> EditAccountPage(email: _emailController.text, password: _passwordController.text)));
                    }
                  },
                  child: const Text("Devam Et", style: TextStyle(color: Colors.white, fontSize: 18.0),),
                )
            )
          ],
        )
    );
  }
}