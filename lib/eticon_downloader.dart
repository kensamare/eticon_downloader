import 'dart:async';
import 'dart:io';

import 'download_errors.dart';

import 'package:flutter/services.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gallery_saver/gallery_saver.dart';

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
      if (url.isEmpty) {
        throw EticonDownloadError(error: 'Url is empty');
      }
      if (await _requestPermission(Permission.storage)) {
        http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode.toString().startsWith('30')) {
          throw DownloadException(response.statusCode);
        }
        if (response.statusCode >= 400) {
          throw DownloadException(response.statusCode);
        }
        if (response.statusCode.toString().startsWith('20')) {
          if (fileName.isEmpty) {
            fileName = basename(url);
          }
          return await saveToDownloadDir(
              bytes: response.bodyBytes,
              fileName: fileName,
              addTimestamp: addTimestamp);
        }
      } else {
        return false;
      }
    } catch (error) {
      throw EticonDownloadError(error: 'Problem download file, error: $error');
    }
    return true;
  }

  static Future<bool> get is29SDKorHight async {
    if (Platform.isAndroid) {
      return (await DeviceInfoPlugin().androidInfo).version.sdkInt! >= 29;
    }
    return false;
  }

  static Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> downloadMedia({required String url}) async {
    try {
      if (url.isEmpty) {
        throw EticonDownloadError(error: 'Url is empty');
      }
      int indexOfExtr = url.lastIndexOf('.');
      String fileFormat = url.substring(indexOfExtr);
      if (fileFormat.isEmpty) {
        throw EticonDownloadError(error: 'File format not defined');
      }
      if (fileFormat == '.mp4' ||
          fileFormat == '.mov' ||
          fileFormat == '.avi' ||
          fileFormat == '.wmv' ||
          fileFormat == '.3gp' ||
          fileFormat == '.3gpp' ||
          fileFormat == '.mkv' ||
          fileFormat == '.flv') {
        if (!(await _requestPermission(
            Platform.isAndroid ? Permission.storage : Permission.photos))) {
          return false;
        }
        await GallerySaver.saveVideo(url);
      } else {
        if (!(await _requestPermission(
            Platform.isAndroid ? Permission.storage : Permission.photos))) {
          return false;
        }
        await GallerySaver.saveImage(url);
      }
    } catch (error) {
      throw EticonDownloadError(error: 'Media download problem, error: $error');
    }
    return true;
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
      if (savePath.isEmpty) {
        throw EticonDownloadError(error: 'Path to save files is empty');
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
    } catch (error) {
      throw EticonDownloadError(
          error: 'Problem with saving to downloads directory, error: $error');
    }
    return true;
  }
}
