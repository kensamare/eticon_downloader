import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:eticon_downloader/eticon_downloader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String URL_VIDEO =
      'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';
  String URL_IMAGE =
      "https://www.meme-arsenal.com/memes/8d8f919797c342515ac95ae2a850ae23.jpg";
  String URL_FILE = "https://www.xerox.ru/upload/iblock/ddd/documate-3125.pdf";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await EticonDownloader.platformVersion ?? 'Unknown platform version';
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(URL_IMAGE),
              Text('Running on: $_platformVersion\n'),
              TextButton(
                child: Text("Download file"),
                onPressed: () async {
                  await EticonDownloader.downloadFile(url: URL_FILE);
                },
              ),
              TextButton(
                child: Text("Download image"),
                onPressed: () async {
                  await EticonDownloader.downloadMedia(url: URL_IMAGE);
                },
              ),
              TextButton(
                child: Text("Download video"),
                onPressed: () async {
                  await EticonDownloader.downloadMedia(url: URL_VIDEO);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
