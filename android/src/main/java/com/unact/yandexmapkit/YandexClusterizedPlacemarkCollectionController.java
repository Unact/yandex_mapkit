package com.unact.yandexmapkit;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.yandex.mapkit.map.Cluster;
import com.yandex.mapkit.map.ClusterListener;
import com.yandex.mapkit.map.ClusterTapListener;
import com.yandex.mapkit.map.ClusterizedPlacemarkCollection;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.PlacemarkMapObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexClusterizedPlacemarkCollectionController
  extends YandexMapObjectController
  implements ClusterListener, ClusterTapListener
{
  private int clusterCnt = 0;
  private final Map<Cluster, YandexPlacemarkController> clusters = new HashMap<>();
  private final List<YandexPlacemarkController> placemarkControllers = new ArrayList<>();
  public final ClusterizedPlacemarkCollection clusterizedPlacemarkCollection;
  private final YandexMapObjectTapListener tapListener;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final WeakReference<YandexMapController> controller;
  public final String id;

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public YandexClusterizedPlacemarkCollectionController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    ClusterizedPlacemarkCollection clusterizedPlacemarkCollection =
      parent.addClusterizedPlacemarkCollection(this);

    this.clusterizedPlacemarkCollection = clusterizedPlacemarkCollection;
    this.id = (String) params.get("id");
    this.controller = controller;
    this.tapListener = new YandexMapObjectTapListener(id, controller);

    clusterizedPlacemarkCollection.setUserData(this.id);
    clusterizedPlacemarkCollection.addTapListener(tapListener);
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    updatePlacemarks((Map<String, Object>) params.get("placemarks"));
    clusterizedPlacemarkCollection.clusterPlacemarks(
      ((Double) params.get("radius")).floatValue(),
      ((Number) params.get("minZoom")).intValue()
    );

  }

  public void remove() {
    for (YandexPlacemarkController placemarkController : placemarkControllers) {
      placemarkController.remove();
    }
    clusterizedPlacemarkCollection.getParent().remove(clusterizedPlacemarkCollection);

    removeClusters();
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  private void updatePlacemarks(Map<String, Object> params) {
    addPlacemarks((List<Map<String, Object>>) params.get("toAdd"));
    changePlacemarks((List<Map<String, Object>>) params.get("toChange"));
    removePlacemarks((List<Map<String, Object>>) params.get("toRemove"));
  }

  @SuppressWarnings({"ConstantConditions"})
  private void addPlacemarks(List<Map<String, Object>> params) {
    for (Map<String, Object> el : params) {
      addPlacemark(el);
    }
  }

  @SuppressWarnings({"ConstantConditions"})
  private void changePlacemarks(List<Map<String, Object>> params) {
    for (Map<String, Object> el : params) {
      changePlacemark(el);
    }
  }

  @SuppressWarnings({"ConstantConditions"})
  private void removePlacemarks(List<Map<String, Object>> params) {
    for (Map<String, Object> el : params) {
      removePlacemark(el);
    }
  }

  private void addPlacemark(Map<String, Object> params) {
    YandexPlacemarkController placemarkController = new YandexPlacemarkController(
      clusterizedPlacemarkCollection,
      params,
      controller
    );

    placemarkControllers.add(placemarkController);
  }

  private void changePlacemark(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexPlacemarkController placemarkController : placemarkControllers) {
      if (placemarkController.id.equals(id)) {
        placemarkController.update(params);
        break;
      }
    }
  }

  private void removePlacemark(Map<String, Object> params) {
    String id = (String) params.get("id");

    for (YandexPlacemarkController placemarkController : placemarkControllers) {
      if (placemarkController.id.equals(id)) {
        placemarkController.remove();
        placemarkControllers.remove(placemarkController);
        break;
      }
    }
  }

  public void removeClusters() {
    List<String> appearancePlacemarkIds = new ArrayList<>();
    for (YandexPlacemarkController placemarkController : clusters.values()) {
      appearancePlacemarkIds.add(placemarkController.id);
      placemarkController.remove();
    }

    clusters.clear();

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);
    arguments.put("appearancePlacemarkId", appearancePlacemarkIds);

    controller.get().methodChannel.invokeMethod("onClustersRemoved", arguments);
  }

  public void onClusterAdded(final Cluster cluster) {
    final YandexClusterizedPlacemarkCollectionController self = this;
    clusterCnt += 1;
    List<String> placemarkIds = new ArrayList<>();
    for (PlacemarkMapObject placemark : cluster.getPlacemarks()) {
        placemarkIds.add((String) placemark.getUserData());
    }

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);
    arguments.put("appearancePlacemarkId", id + "_appearance_placemark_" + clusterCnt);
    arguments.put("size", cluster.getSize());
    arguments.put("point", Utils.pointToJson(cluster.getAppearance().getGeometry()));
    arguments.put("placemarkIds", placemarkIds);

    controller.get().methodChannel.invokeMethod("onClusterAdded", arguments, new MethodChannel.Result() {
      @Override
      public void success(@Nullable Object result) {
        Map<String, Object> params = ((Map<String, Object>) result);

        if (!cluster.isValid()) {
          return;
        }

        clusters.put(
          cluster,
          new YandexPlacemarkController(clusterizedPlacemarkCollection, cluster.getAppearance(), params, controller)
        );

        cluster.addClusterTapListener(self);
      }

      @Override
      public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {}
      @Override
      public void notImplemented() {}
    });

  }

  @Override
  public boolean onClusterTap(@NonNull Cluster cluster) {
    List<String> placemarkIds = new ArrayList<>();
    for (PlacemarkMapObject placemark : cluster.getPlacemarks()) {
      placemarkIds.add((String) placemark.getUserData());
    }

    Map<String, Object> arguments = new HashMap<>();
    arguments.put("id", id);
    arguments.put("appearancePlacemarkId", clusters.get(cluster).id);
    arguments.put("size", cluster.getSize());
    arguments.put("point", Utils.pointToJson(cluster.getAppearance().getGeometry()));
    arguments.put("placemarkIds", placemarkIds);

    controller.get().methodChannel.invokeMethod("onClusterTap", arguments);

    return true;
  }
}
