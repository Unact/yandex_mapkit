package com.unact.yandexmapkit;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

abstract public class Init {
  public abstract void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding);

  public abstract void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding);

  public abstract void onAttachedToActivity(@NonNull ActivityPluginBinding binding);

  public abstract void onDetachedFromActivityForConfigChanges();

  public abstract void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding);

  public abstract void onDetachedFromActivity();
}
