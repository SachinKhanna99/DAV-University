import 'package:davteacher/HomeScreen.dart';
import 'package:davteacher/main.dart';
import 'package:davteacher/save.dart';
import 'package:davteacher/showdata.dart';
import 'package:davteacher/testupload.dart';
import 'package:davteacher/uploadpdf.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController name = new TextEditingController();
  String course;
  FirebaseAuth auth=FirebaseAuth.instance;


  getUID() async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    return  uid;
  }
  final Future<FirebaseUser> user=FirebaseAuth.instance.currentUser();
  TextEditingController subject1 = new TextEditingController();
  TextEditingController subject2 = new TextEditingController();

  final DBref = FirebaseDatabase.instance.reference();
  List<DropdownMenuItem<String>> items = [
    new DropdownMenuItem(
      child: new Text("CSE"),
      value: "CSE",
    ),
    new DropdownMenuItem(
      child: new Text("CSA"),
      value: "CSA",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Enter Details"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "Name", labelText: "Name*"),
                    controller: name,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Plase enter Name";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "subject 1", labelText: "Subject*"),
                    controller: subject1,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Plase enter Subject Name";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: "Subject 2(Optional)",
                        labelText: "Subject 2"),
                    controller: subject2,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  new DropdownButtonHideUnderline(
                      child: new DropdownButton(
                          items: items,
                          hint: new Text('Choose Course'),
                          value: course,
                          onChanged: (String val) {
                            setState(() {
                              course = val;
                            });
                          }
                          )
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton(
                    elevation: 20,
                    child: Text("Save data"),
                    onPressed: () {
                      Savedata();
                    },
                  ),
                  RaisedButton(
                    elevation: 20,
                    child: Text("Show data"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>new ShowData()));
                    },
                  ),
                  RaisedButton(
                    elevation: 20,
                    child: Text("Upload Pdf"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>new UploadPdf()));
                    },
                  ),
                  RaisedButton(
                    elevation: 20,
                    child: Text("Test Upload Pdf"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>new TestUpload()));
                    },
                  ),
                  RaisedButton(
                    elevation: 20,
                    child: Text("SAve"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>new Save()));
                    },
                  ),
                  RaisedButton(
                    elevation: 20,
                    child: Text("Logout"),
                    onPressed: () async{

                      await FirebaseAuth.instance.signOut();
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>new HomeScreen()));
                    },
                  ),
                  RaisedButton(
                    elevation: 20,
                    child: Text("Google Logout"),
                    onPressed: () async{

                      GoogleSignIn gooogle=GoogleSignIn();
                      await gooogle.signOut();
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>new HomeScreen()));
                    },
                  ),

                ],
              ),
            ),
          ),
        ));
  }

  void Savedata() async{
    if (_key.currentState.validate()) {
      _key.currentState.save();
     final uid=await getUID();
     print("ASDADASDASDASDASD       $uid");
      final DatabaseReference reference = FirebaseDatabase.instance.reference();
      var data = {
        "name": name.text,
        "subject1": subject1.text,
        "subject2": subject2.text,
        "course":course,
        "uid":uid,
      };reference
          .child('teachers')
        .child(uid)
          .push()
          .set(data)
          .then((value) => _key.currentState.reset());
    }
  }
}
