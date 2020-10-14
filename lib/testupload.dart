import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class TestUpload extends StatefulWidget {
  @override
  _TestUploadState createState() => _TestUploadState();
}

class _TestUploadState extends State<TestUpload> {
  String _extension;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Upload"),
      ),
      body: RaisedButton(
        child: Text("Upload"),
        onPressed: (){
          getPdfAndUpload();
        },
      ),
    );
  }
    Future getPdfAndUpload() async {
      var rng = new Random();
      String randomName = "";
      for (var i = 0; i < 20; i++) {
        print(rng.nextInt(100));
        randomName += rng.nextInt(100).toString();
      }
    var file = await FilePicker.getFile(
          type: FileType.any,
          allowedExtensions: (_extension?.isNotEmpty ?? false)
              ? _extension?.replaceAll(' ', '')?.split(',')
              : null);
      String fileName = '${randomName}.pdf';
      print(fileName);
      print('${file.readAsBytesSync()}');
      savePdf(file.readAsBytesSync(), fileName);
    }
  }
    Future savePdf(List<int> asset, String name) async {
      StorageReference reference = FirebaseStorage.instance.ref().child(name);
      StorageUploadTask uploadTask = reference.putData(asset);
      String url = await (await uploadTask.onComplete).ref.getDownloadURL();
      print(url);
      documentFileUpload(url);
      return url;
    }
    void documentFileUpload(String url)
    {
      final mainReference = FirebaseDatabase.instance.reference().child('teachers');
      var data = {
        "PDF": url,
      };
      mainReference.child("Documents").child('pdf').push().set(data).then((v) {});
    }

