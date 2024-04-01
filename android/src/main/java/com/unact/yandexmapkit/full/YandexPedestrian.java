package com.unact.yandexmapkit.full;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.transport.TransportFactory;
import com.yandex.mapkit.transport.masstransit.PedestrianRouter;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexPedestrian implements MethodCallHandler {
  private final PedestrianRouter pedestrianRouter;
  private final BinaryMessenger binaryMessenger;

  public YandexPedestrian(Context context, BinaryMessenger messenger) {
    TransportFactory.initialize(context);

    pedestrianRouter = TransportFactory.getInstance().createPedestrianRouter();
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

    YandexPedestrianSession.initSession(id, binaryMessenger, pedestrianRouter);
  }
}
