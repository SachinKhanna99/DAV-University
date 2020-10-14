import 'dart:io';
import 'package:davteacher/Model/mydata.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
class ShowData extends StatefulWidget {
  @override
  _ShowDataState createState() => _ShowDataState();
}

class _ShowDataState extends State<ShowData> {
  List<Mydata> alldata = [];
FirebaseAuth auth=FirebaseAuth.instance;

bool downloading=false;
String progressString="";
  @override
  void initState() {

   showdata();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teacher Dashboard"),
        centerTitle: true,
      ),
      body: new Container(
        child: alldata.length == 0
            ? new Text("No Data Available")
            : new ListView.builder(

                itemCount: alldata.length,
                itemBuilder: (_, index) {
                  return UI(
                    alldata[index].name,
                    alldata[index].subject1,
                    alldata[index].subject2,
                    alldata[index].course,
                    alldata[index].file
                  );

                }
                ),
      ),
    );
  }

  void  downloadedFile(String file) async {
String ifds=file.replaceAll("%20", " ");
    StorageReference reference=FirebaseStorage.instance.ref().child(ifds);
    String extension='docx';
    String name='sachinx';
    String _message;

    final String url = await reference.getDownloadURL();
    print("SADasdasdasdasd--------------------->$url");
    final http.Response downloadData = await http.get(url);
    var dio = new Dio();
    var dir = await getExternalStorageDirectory();
    var knockDir =
    await new Directory('${dir.path}/iLearn').create(recursive: true);
    print(url);
    var bodyBytes = downloadData.bodyBytes;

    await dio.download(url, '${knockDir.path}/$name.$extension',
        onReceiveProgress: (rec, total) {
          //print("Rec: $rec , Total: $total");

          if (mounted) {
            setState(() {
              downloading = true;
              progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
            });
          }
        });
    if (mounted) {
      setState(() {
        downloading = false;
        progressString = "Completed";
        _message = "File is downloaded to your SD card 'iLearn' folder!";
      });
    }
    print("Download completed");
  }



  Widget UI(String name,  String subject1,String subject2,String course,String file) {
    return new Card(
      elevation: 10.0,
      child: new Container(
        padding: new EdgeInsets.all(20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text('Name : $name',style: Theme.of(context).textTheme.title,),
            new Text('subject1 : $subject1'),
            new Text('subject2 : $subject2'),
            new RaisedButton(
              child: Text('file : $file'),
                onPressed: (){downloadedFile(file.replaceAll('%20', ' '));})


          ],
        ),
      ),
    );
  }
  getUID() async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    return  uid;
  }
  void showdata()async {
    final uid=await getUID();
    print(uid);
    DatabaseReference reference = FirebaseDatabase.instance.reference();
    reference.child('teachers').child(uid).once().then((DataSnapshot snapshot) {
      var keys = snapshot.value.keys;
      var data = snapshot.value;
      alldata.clear();
      for (var key in keys) {
        Mydata d = new Mydata(
          data[key]['name'],
          data[key]['subject1'],
          data[key]['subject2'],
          data[key]['course'],
          data[key]['filename']
        );
        alldata.add(d);
      }
      setState(() {
        print('Length : ${alldata.length}');
      });
    });
  }
}
