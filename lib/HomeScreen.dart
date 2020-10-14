import 'package:davteacher/SecondPage.dart';
import 'package:davteacher/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context,snapshot){
        if(snapshot.connectionState==ConnectionState.active){
          FirebaseUser user=snapshot.data;
          if(user==null){
          return MainScreen();
          }
          return SecondPage();
        }else{
          return Container(
            child: Scaffold(
              body: Text("Asd"),
            ),
          );
        }
      },
    );
  }
}
