<img src="https://user-images.githubusercontent.com/36012868/130392291-52b82b9b-fd52-424b-ba5a-b7630e9cf343.png" data-canonical-src="https://user-images.githubusercontent.com/36012868/130392291-52b82b9b-fd52-424b-ba5a-b7630e9cf343.png" height="200" width=400/>

[![English](https://img.shields.io/badge/Language-Russian-blue?style=plastic)](https://github.com/Lexa1488Ruskiy4elovek/practice/blob/main/doc/README_RU.md)

# ETICON DOWNLOADER

Library for downloading images/videos or files to external storage. Images/videos are saved in Android Gallery and iOS Photos. Files are saved in Downloads on Android and IOS.

## Installation in a project

Add eticon_downloader: 0.1.2 to dev_dependencies pubspec.yaml as shown below:
```dart
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^1.0.0
  eticon_downloader: ^1.0.0
```
### iOS

Add the following permissions to _Info.plist_ file:

* `NSPhotoLibraryUsageDescription` - For permission to save photos/videos in IOS Photos.
* `NSDocumentDirectory` - For permission to save files in Downloads.

### Android

Add the following permissions to _AndroidManifest.xml_ file:

* `android.permission.WRITE_EXTERNAL_STORAGE` - For permission to use external storage.

## Using

### Method downloadFile

```dart
import 'package:eticon_downloader/eticon_downloader.dart';

String URL_FILE = 'https://filesamples.com/samples/document/pdf/sample1.pdf';

TextButton(
  child: Text("Download file"),
    onPressed: () async {
      await EticonDownloader.downloadFile(url: URL_FILE);
    }
)
```

### Method downloadMedia

```dart
String URL_IMAGE = 'https://filesamples.com/samples/image/png/sample_640%C3%97426.png';
TextButton(
  child: Text("Download image"),
    onPressed: () async {
      await EticonDownloader.downloadMedia(url: URL_IMAGE);
    }
)
```

```dart
String URL_VIDEO = 'https://filesamples.com/samples/video/mp4/sample_960x540.mp4';
TextButton(
  child: Text("Download video"),
    onPressed: () async {
      await EticonDownloader.downloadMedia(url: URL_VIDEO);
    }
)
```
