import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';


class EticonDownloader {
  static const MethodChannel _channel = MethodChannel('eticon_downloader');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> downloadFile(
      {required String url,
      String fileName = "",
      bool addTimestamp = true}) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      if (fileName.isEmpty) {
        fileName = basename(url);
      }
      return await saveToDownloadDir(bytes: response.bodyBytes, fileName: fileName, addTimestamp: addTimestamp);
    } catch (e) {
      print(e);
      Future.delayed(Duration(seconds: 2)).asStream().listen((event) { });
      return false;
    }
    return true;
  }

  static Future<bool> get is29SDKorHight async {
    if (Platform.isAndroid) {
      return (await DeviceInfoPlugin().androidInfo).version.sdkInt! >= 29;
    }
    return false;
  }

  static Future<bool> saveToDownloadDir(
      {required List<int> bytes,
      required String fileName,
      bool addTimestamp = true}) async {
    try {
      if (addTimestamp) {
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        int indexOfExtr = fileName.lastIndexOf('.');
        fileName = fileName.substring(0, indexOfExtr) +
            '_$timestamp' +
            fileName.substring(indexOfExtr);
      }
      String savePath;
      if (Platform.isIOS ||
          (Platform.isAndroid &&
              (await DeviceInfoPlugin().androidInfo).version.sdkInt! >= 29)) {
        savePath =
            '${(await path.getApplicationDocumentsDirectory()).path}/$fileName';
      } else {
        savePath = '${(await AndroidPathProvider.downloadsPath)}/$fileName';
      }
      File(savePath)
        ..createSync()
        ..writeAsBytesSync(bytes);
      if (Platform.isAndroid &&
          (await DeviceInfoPlugin().androidInfo).version.sdkInt! >= 29) {
        await _channel.invokeMethod('downloadFiles', {
          "fileName": fileName,
          "mime": mime(fileName),
          "localPath": savePath
        });
        File(savePath).deleteSync();
      }
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }
}
