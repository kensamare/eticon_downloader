package com.example.eticon_downloader;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.io.File;
import java.io.OutputStream;
import java.io.InputStream;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Paths;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** EticonDownloaderPlugin */
public class EticonDownloaderPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Activity activity;
  private Context context;
  private int errorCode = 0;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "eticon_downloader");
    channel.setMethodCallHandler(this);
    this.context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if(call.method.equals("downloadFiles")){
      boolean res = downloadFiles(call);
      if(res){
        result.success("Success save file");
      } else{
        result.error(String.valueOf(errorCode), null, null);
      }
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private boolean downloadFiles(MethodCall call){
    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q){
      try{
        Uri uri = createFileInPublicDownloadsDir(call.argument("fileName"), call.argument("mime"));
        File download = new File(call.argument("localPath").toString());
        byte[] bytes = Files.readAllBytes(download.toPath());
        OutputStream outputStream = context.getApplicationContext().getContentResolver().openOutputStream(uri, "w");
        outputStream.write(bytes);
        outputStream.flush();
        outputStream.close();
      }catch(Exception e){
        Log.d("ERROR", e.toString());
        errorCode = 1;
        return false;
      }
    } else{
      errorCode = 2;
      return false;

    }
    return true;
  }


  @RequiresApi(api = Build.VERSION_CODES.Q)
  private Uri createFileInPublicDownloadsDir(String filename, String mimeType) {

    Uri collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI;
    ContentValues values = new ContentValues();
    values.put(MediaStore.Downloads.DISPLAY_NAME, filename);
    values.put(MediaStore.Downloads.MIME_TYPE, mimeType);
    values.put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS);
    ContentResolver contentResolver = context.getApplicationContext().getContentResolver();
    try {
      Uri uri = contentResolver.insert(collection, values);
        Log.d("URI", uri.toString());
      return uri;
    } catch (Exception e) {
//      Uri contentUri = MediaStore.Files.getContentUri("external");
//
////      String selection = MediaStore.MediaColumns.RELATIVE_PATH + "=?";
////
////      String[] selectionArgs = new String[]{Environment.DIRECTORY_DOWNLOADS};
//
//      Cursor cursor = context.getContentResolver().query(contentUri, null, null, null, null);
//
//      Uri uri1 = null;
//      Log.d("Test3", "All");
//      Log.d("TEST2", String.valueOf(cursor.getCount()));
//      if (cursor.getCount() == 0) {
//        Log.d("Test3", "OH, NOTHING");
//      } else {
//        while (cursor.moveToNext()) {
//          long id = cursor.getLong(cursor.getColumnIndex(MediaStore.MediaColumns._ID));
//          String name = cursor.getString(cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME));
//          uri1 = ContentUris.withAppendedId(contentUri, id);
//          Log.d("TEST", uri1.toString());
//          Log.d("TEST", name);
//        }
//      }
//      e.printStackTrace();
      Log.e("ERROR" ,"Create a file using MediaStore API failed.");
    }
    return null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
