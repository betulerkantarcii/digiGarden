import 'package:flutter/material.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}


class _AccountPageState extends State<AccountPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.brown[100],
        appBar: AppBar(
          title: Text('Hesabım', style:TextStyle(fontSize: 25)),
        ),
        body: SingleChildScrollView(

          ),

    );
  }
}