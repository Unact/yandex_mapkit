package com.unact.yandexmapkit.full;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.transport.TransportFactory;
import com.yandex.mapkit.transport.masstransit.BicycleRouterV2;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexBicycle implements MethodCallHandler {
  private final BicycleRouterV2 bicycleRouter;
  private final BinaryMessenger binaryMessenger;

  public YandexBicycle(Context context, BinaryMessenger messenger) {
    bicycleRouter = TransportFactory.getInstance().createBicycleRouterV2();
    binaryMessenger = messenger;
  }

  @Override
  @SuppressWarnings({"SwitchStatementWithTooFewBranches"})
  public void onMethodCall(MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "initSession":
        initSession(call);
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void initSession(final MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    final int id = ((Number) params.get("id")).intValue();

    YandexBicycleSession.initSession(id, binaryMessenger, bicycleRouter);
  }
}
