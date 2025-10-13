package com.unact.yandexmapkitexample;

import android.app.Application;

import com.yandex.mapkit.MapKitFactory;

public class MainApplication extends Application {
  @Override
  public void onCreate() {
    super.onCreate();
    //MapKitFactory.setLocale("YOUR_LOCALE");
    MapKitFactory.setApiKey("ee1c633f-a745-49be-a3cb-f12b9f815e86");;
  }
}
