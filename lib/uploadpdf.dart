import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:http/http.dart' as http;
class UploadPdf extends StatefulWidget {
  @override
  _UploadPdfState createState() => _UploadPdfState();
}

class _UploadPdfState extends State<UploadPdf> {
  String  _path;
  Map<String,String> _paths;
  String _extension;
  FileType _picktype=FileType.any;
  bool _multiplefile=false;
  GlobalKey<ScaffoldState>_scaffoldkey=new GlobalKey();
  List<StorageUploadTask> _list=<StorageUploadTask>[];
  bool downloading = false;
  var progressString = "";
final FirebaseAuth auth=FirebaseAuth.instance;


  getUID() async {
    final FirebaseUser user = await auth.currentUser();
    final uid = user.uid;
    return  uid;
  }
  dropdown(){
    return DropdownButton(
      hint: Text("Select"),
      value: _picktype,
      items: <DropdownMenuItem>[
        DropdownMenuItem(
          child: Text("Audio"),
          value: FileType.audio,
        ),
        DropdownMenuItem(
          child: Text("Video"),
          value: FileType.video,
        ),
        DropdownMenuItem(
          child: Text("File"),
          value: FileType.any,
        ), DropdownMenuItem(
          child: Text("Image"),
          value: FileType.image,
        ),

      ],
      onChanged: (value){
        setState(() {
          _picktype=value;
        });
      },
    );
  }
  @override
  Widget build(BuildContext context) {

    final List<Widget> children=<Widget>[];
    _list.forEach((StorageUploadTask task) {
      final Widget title=UploadTask(task: task,
      onDismiss: (){
        setState(() {
          _list.remove(task);
        }
        );
      },onDownload: (){
    //    donwloadFile(task.lastSnapshot.ref);
        downloadedFile(task.lastSnapshot.ref);

        },
      );
      children.add(title);
    });
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text("Upload Task"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            dropdown(),
            SwitchListTile.adaptive(
                title: Text("Pick Multiple Images",textAlign: TextAlign.left,),
                onChanged:(bool value){
                  setState(() {
                    _multiplefile=value;
                  });
                },
              value: _multiplefile,),

            OutlineButton(
              child: Text("Open File Explorer"),
              onPressed: (){
                openfileexplorer();
              },
            ),
            SizedBox(height: 20,),
            Flexible(
              child: ListView(
                children: children,
              ),
            )
          ],
        ),
      ),
    );
  }

  void openfileexplorer() async{
    try{
      if(_multiplefile){
        _paths = await FilePicker.getMultiFilePath(
            type: _picktype,
            allowedExtensions: (_extension?.isNotEmpty ?? false)
                ? _extension?.replaceAll(' ', '')?.split(',')
                : null);
      }else{
        _path=await FilePicker.getFilePath(
          type: FileType.custom, allowedExtensions: (_extension?.isNotEmpty ?? false)
            ? _extension?.replaceAll(' ', '')?.split(',')
            : null);
      }
      uploadFirebase();
    }on PlatformException catch(e){
      print("Unspotted Operation" +e.toString());
    }if(!mounted){
      return;
    }
  }
  uploadFirebase(){
    if(_multiplefile){
   _paths.forEach((fileName,filePath) {
     upload(fileName, filePath);
   });
    }else{
    String fileName=_path.split('/').last;
    String Filepath=_path;
    upload(fileName, Filepath);
    }
  }

  void upload(fileName, filePath) async{
_extension=fileName.toString().split('.').last;
StorageReference reference=FirebaseStorage.instance.ref().child(fileName);
final StorageUploadTask uploadTask=reference.putFile(File(filePath),
StorageMetadata(
  contentType: '$_picktype/$_extension',

));

final String url = await reference.getDownloadURL();

donwloadupload(url,fileName);
setState(() {
  _list.add(uploadTask);
});


  }


 void  downloadedFile(StorageReference reference) async {
    String fileName="sachin";
    String extension=".docx";
    String _message;
    final String url = await reference.getDownloadURL();
    var dio = new Dio();
    var dir = await getExternalStorageDirectory();
    var knockDir =
    await new Directory('${dir.path}/iLearn').create(recursive: true);
    print(url);
    await dio.download(url, '${knockDir.path}/$fileName.$extension',
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


Future<String> get  localpathdevice async{
//final _devicepath=await getApplicationDocumentsDirectory();
//return _devicepath.path;
  Directory appDocDirectory = await getApplicationDocumentsDirectory();

  new Directory(appDocDirectory.path+'/'+'dir').create(recursive: true);
// The created directory is returned as a Future.
//      .then((Directory directory) {
//    print('Path of New Dir: '+directory.path);
//    return directory.path;
//  });
Directory directory;
print(directory.path);
return directory.path;

}


  void donwloadFile(StorageReference ref) async{
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(url);

      final File tempFile = File("$localpathdevice");
      if (tempFile.existsSync()) {
        await tempFile.path;
      }
      await tempFile.create(recursive: true);
      final StorageFileDownloadTask task = ref.writeToFile(tempFile);
      final int byteCount = (await task.future).totalByteCount;
      var bodyBytes = downloadData.bodyBytes;
      final String name = await ref.getName();
      final String path = await ref.getPath();
      print(
        'Success!\nDownloaded $name \nUrl: $url'
            '\npath: $path \nBytes Count :: $byteCount',
      );

      _scaffoldkey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          content: Image.memory(
            bodyBytes,
            fit: BoxFit.fill,
          ),

        ),

      );
  }


  void donwloadupload(String url,String filename)async {
    final uid=await getUID();
    final mainref=FirebaseDatabase.instance.reference();
    var data= {
      "pdf": url,
      "filename":filename
    };
    mainref.child('teachers').child(uid).push().set(data).then((value) => {
      print("Completed"),
    });
  }


}
class UploadTask extends StatelessWidget {
  const UploadTask(
  {Key key,this.task,this.onDismiss,this.onDownload}):super(key:key);
  final StorageUploadTask task;
  final VoidCallback onDismiss;
  final VoidCallback onDownload;
  String byteTransfer(StorageTaskSnapshot snapshot){
    return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';
  }
  String get status{
    String result;
    if(task.isComplete){
      if(task.isSuccessful){
        result='Completed';
      } else if(task.isCanceled){
        result='Cancelled';
      }else{
        result='Failed Error ${task.lastSnapshot.error}';
      }
    }else if(task.isInProgress){
    result= 'Uploading ...';
    }else if(task.isPaused){
      result='Paused';
    }
    return result;
  }
  @override
  Widget build(BuildContext context) {

    return StreamBuilder<StorageTaskEvent>(
      stream: task.events,
      builder: (BuildContext context,AsyncSnapshot<StorageTaskEvent> asycsnapshot){
      Widget subtitle;
      if(asycsnapshot.hasData){
        final StorageTaskEvent event=asycsnapshot.data;
        final StorageTaskSnapshot snapshot=event.snapshot;
        subtitle= Text('$status : ${byteTransfer(snapshot)} bytes sent');
      }else{
          subtitle= const Text("Starting...");
      }
      return Dismissible(
        key: Key(task.hashCode.toString()),
        onDismissed: (_)=>onDismiss(),
        child: ListTile(
          title: Text('Upload Task ${task.hashCode}'),
          subtitle: subtitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Offstage(
                offstage: !task.isInProgress,
                child: IconButton(
                  icon: Icon(Icons.pause),
                  onPressed: ()=>task.pause(),
                ),
              ),
              Offstage(
                offstage: !task.isPaused,
                child: IconButton(
                  icon: Icon(Icons.file_upload),
                  onPressed: ()=>task.resume(),
                ),
              ),
              Offstage(
                offstage: task.isComplete,
                child: IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: ()=>task.cancel(),
              )
              ),
              Offstage(
                  offstage: !(task.isComplete && task.isSuccessful),
                  child: IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: (){
                    onDownload();
                    }
                  ),
              ),

            ],
          ),
        ),
      );
      },
    );
  }


}

