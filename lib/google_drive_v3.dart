
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'dart:io';
import 'dart:developer';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:google_drive_v3/secureStorage.dart';
import 'package:url_launcher/url_launcher.dart';

const _scopes = [ga.DriveApi.driveFileScope,ga.DriveApi.driveAppdataScope,ga.DriveApi.driveScope];
class GoogleDriveV3 {
  static const MethodChannel _channel =
      const MethodChannel('google_drive_v3');

  final storage = SecureStorage();
  String _clientId = "";
  String _clientSecret = "";

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  GoogleDriveV3({clientId : "", clientSecret : ""}){
    this._clientId = clientId;
    this._clientSecret = clientSecret;
    //print("Client ID : " + _clientId);
  }

  Future<http.Client> getHttpClient() async {
    //Get Credentials
    var credentials = await storage.getCredentials();
    if (credentials == null) {
      //Needs user authentication
      var authClient = await clientViaUserConsent(
          ClientId(this._clientId, this._clientSecret), _scopes, (url) {
        //Open Url in Browser
        launch(url);
      });
      //Save Credentials
      await storage.saveCredentials(authClient.credentials.accessToken,
          authClient.credentials.refreshToken);
      return authClient;
    } else {
      var parsedDate = DateTime.parse(credentials["expiry"]);
      if(parsedDate.toLocal().isBefore(DateTime.now().toLocal())){
        var authClient = await clientViaUserConsent(
            ClientId(this._clientId, this._clientSecret), _scopes, (url) {
          //Open Url in Browser
          launch(url);
        });
        //Save Credentials
        await storage.saveCredentials(authClient.credentials.accessToken,
            authClient.credentials.refreshToken);
        return authClient;
      }

      //Already authenticated
      return authenticatedClient(
          http.Client(),
          AccessCredentials(
              AccessToken(credentials["type"], credentials["data"],
                  DateTime.tryParse(credentials["expiry"])),
              credentials["refreshToken"],
              _scopes));
    }
  }

  //Download File
  Future download(String fileId) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    ga.Media file = await drive.files.get(fileId, downloadOptions: ga.DownloadOptions.fullMedia);
    print ("Download File : MIME - ${(file.contentType)} , Length - ${(file.length)}");
    return file.stream;
  }

  //Download File
  Future getMeta(String fileId) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    var response = await drive.files.get(fileId, downloadOptions: ga.DownloadOptions.metadata);
    print ("Get Meta : " + jsonEncode(response));
    return jsonEncode(response);
  }

  //Upload File
  Future<Map> upload(File file,[String folder_id = ""]) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    print("Uploading file");
    var response = await drive.files.create(
        ga.File()
          ..name = p.basename(file.absolute.path)
          ..parents = [folder_id],
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
    );
    print ("Upload File ${response.toJson()}");

    return response.toJson();
  }

  //Update File
  Future<Map> updateFile(File file,String fileID) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    print("Uploading file");

    var response = await drive.files.update(
        ga.File()
          ..name = p.basename(file.absolute.path),
        fileID,
        uploadMedia: ga.Media(file.openRead(), file.lengthSync())
    );
    print ("Update File  ${response.toJson()}");
    return response.toJson();

  }

  //Create Folder
  Future<Map> createFolder(String name,[String folder_id = ""]) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);

    var response;

    if(folder_id.isNotEmpty){
      response = await drive.files.create(
          ga.File()
            ..name = name
            ..mimeType = 'application/vnd.google-apps.folder'  // this defines its folder
            ..parents = [folder_id]
      );
    }
    else{
      response = await drive.files.create(
        ga.File()
          ..name = name
          ..mimeType = 'application/vnd.google-apps.folder',  // this defines its folder
      );
    }
    print ("CreateFolder ${response.toJson()}");
    return response.toJson();
  }

  //Create Doc
  Future<Map> createDoc(String name,[String folder_id = ""]) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);

    var response;

    if(folder_id.isNotEmpty){
      response = await drive.files.create(
          ga.File()
            ..name = name
            ..mimeType = 'application/vnd.google-apps.document'  // this defines its Document
            ..parents = [folder_id]
      );
    }
    else{
      response = await drive.files.create(
          ga.File()
            ..name = name
            ..mimeType = 'application/vnd.google-apps.document'  // this defines its Document
      );
    }
    print ("CreateDoc ${response.toJson()}");
    return response.toJson();
  }

  //Create Note
  Future<Map> createNote(String name,[String folder_id = ""]) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);

    var response;

    if(folder_id.isNotEmpty){
      response = await drive.files.create(
          ga.File()
            ..name = name
            ..mimeType = 'text/plain'  // this defines its Document
            ..parents = [folder_id]
      );
    }
    else{
      response = await drive.files.create(
          ga.File()
            ..name = name
            ..mimeType = 'text/plain'  // this defines its Document
      );
    }
    print ("CreateNote ${response.toJson()}");
    return response.toJson();
  }

  Future<Map> listFiles([String folder_id = ""]) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    var response;
    if(folder_id.isNotEmpty){
      response = await drive.files.list(pageSize: 1000, q: "'"  + folder_id + "' in parents");
    }
    else{
      response = await drive.files.list();
    }

    log ("ListFiles ${response.toJson()}");
    return response.toJson();

  }

  Future<Map> searchFiles(String query,[String folder_id = ""]) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    var response = await drive.files.list(q: query );
    if(folder_id.isNotEmpty){
      query = query + " and '" + folder_id + "' in parents";
    }
    response = await drive.files.list(q: query , pageSize: 1000);
    log ("Search Files ${response.toJson()}");
    return response.toJson();
  }


}
