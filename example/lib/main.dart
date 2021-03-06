import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_drive_v3/google_drive_v3.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String inputText;
  TextEditingController _inputController,_outputController = TextEditingController();
  final drive = GoogleDriveV3(
      clientId: "753477329914-8sgn681qso431vr8u2gsj7pd1vhj8v78.apps.googleusercontent.com",
      clientSecret: "jlC8GOFC9HpbGGEcCoQOmN1c"
  );
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await GoogleDriveV3.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget FirstBlock = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(onPressed: () async{

            //List all files File
            Map response = await drive.listFiles(inputText);
            List<Map> files = response['files'];
            files.forEach((element) {print(element); });
            _outputController.text = files.toString();

          }, child: Text('List All Files')),
          ElevatedButton(onPressed: () async{
            //Search File
            Map response = await drive.searchFiles(inputText);
            List<Map> files = response['files'];
            files.forEach((element) {print(element); });
            _outputController.text = files.toString();

          }, child: Text('Search Files')),
        ],
      ),
    );

    Widget SecondBlock = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(onPressed: () async{

            //Update File
            var file = await FilePicker.getFile();
            var response =  await drive.updateFile(file,inputText);
            _outputController.text = response.toString();
          }, child: Text('Update')),
          ElevatedButton(onPressed: () async{
            var file = await FilePicker.getFile();
            var response = await drive.upload(file,inputText);
            _outputController.text = response.toString();
          }, child: Text('Upload')),
          ElevatedButton(onPressed: () async{
            //Download File
            var directory =  await getExternalStorageDirectory();
            Stream<List<int>> file = await drive.download(inputText);

            String response = await drive.getMeta(inputText);

            final saveFile = File('${directory.path}/${jsonDecode(response)["name"]}');
            List<int> dataStore = [];
            file.listen((data) {
              print("DataReceived: ${data.length}");
              dataStore.insertAll(dataStore.length, data);
            }, onDone: () {
              print("Task Done");
              saveFile.writeAsBytes(dataStore);
              print("File saved at ${saveFile.path}");
            }, onError: (error) {
              print("Some Error");
            });
          }, child: Text('Download')),
        ],
      ),
    );

    Widget ThirdBlock = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(onPressed: () async{

            //Create Doc
            //Map response = await drive.createDoc("Flutter Doc","1u_tmBbyWJJoP_sodJP8ddSBygqrYtjYd");
            Map response = await drive.createDoc(inputText);
            _outputController.text = response.toString();

          }, child: Text('Create Doc')),
          ElevatedButton(onPressed: () async{
            //Create Note
            // Map response = await drive.createNote("Flutter Note","1u_tmBbyWJJoP_sodJP8ddSBygqrYtjYd");
            Map response = await drive.createNote(inputText);
            _outputController.text = response.toString();
          }, child: Text('Create Note')),
          ElevatedButton(onPressed: () async{
            //Create Folder
            //Map response = await drive.createFolder("Flutter Test","1u_tmBbyWJJoP_sodJP8ddSBygqrYtjYd");
            String response = await drive.getMeta(inputText);
            _outputController.text = response.toString();
          }, child: Text('Get Meta')),
        ],
      ),
    );

    Widget FourthBlock = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(onPressed: () async{
            //Create Folder
            //Map response = await drive.createFolder("Flutter Test","1u_tmBbyWJJoP_sodJP8ddSBygqrYtjYd");
            Map response = await drive.createFolder(inputText);
            _outputController.text = response.toString();
          }, child: Text('Create Folder')),
        ],
      ),
    );

    Widget SixthBlock = Container(
      padding: const EdgeInsets.all(32),
      child: FractionallySizedBox(
        widthFactor: 1,
        child:
        TextField(
          controller: _outputController,
          decoration: InputDecoration(hintText: "Output Log"),

        ),
      ),
    );

    Widget FifthBlock = Container(
      padding: const EdgeInsets.all(32),
      child: FractionallySizedBox(
        widthFactor: 1,
        child:
            TextField(
              onChanged: (value) {
                setState(() {
                  inputText = value;
                });
              },
              controller: _inputController,
              decoration: InputDecoration(hintText: "Input"),

          ),
      ),
    );


    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Drive example app'),
        ),
        body: SingleChildScrollView(child: Column(
          children: [FirstBlock, SecondBlock, ThirdBlock, FourthBlock,SixthBlock,FifthBlock],
        ))
      ),
    );
  }


}
