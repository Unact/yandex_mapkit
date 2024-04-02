package com.unact.yandexmapkit.full;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.directions.DirectionsFactory;
import com.yandex.mapkit.directions.driving.DrivingRouter;
import com.yandex.mapkit.directions.driving.DrivingRouterType;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexDriving implements MethodCallHandler {
  private final DrivingRouter drivingRouter;
  private final BinaryMessenger binaryMessenger;

  public YandexDriving(Context context, BinaryMessenger messenger) {
    DirectionsFactory.initialize(context);

    drivingRouter = DirectionsFactory.getInstance().createDrivingRouter(DrivingRouterType.COMBINED);
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

    YandexDrivingSession.initSession(id, binaryMessenger, drivingRouter);
  }
}
