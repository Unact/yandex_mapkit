package com.unact.yandexmapkit;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.map.Cluster;
import com.yandex.mapkit.map.ClusterListener;
import com.yandex.mapkit.map.ClusterTapListener;
import com.yandex.mapkit.map.ClusterizedPlacemarkCollection;
import com.yandex.mapkit.map.MapObject;
import com.yandex.mapkit.map.MapObjectCollection;
import com.yandex.mapkit.map.MapObjectTapListener;
import com.yandex.mapkit.map.PlacemarkMapObject;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.FlutterException;
import io.flutter.plugin.common.MethodChannel;

public class ClusterizedPlacemarkCollectionController
  extends MapObjectController
  implements ClusterListener, ClusterTapListener, MapObjectTapListener
{
  private int clusterCnt = 0;
  private final Map<Cluster, PlacemarkMapObjectController> clusters = new HashMap<>();
  private final Map<String, PlacemarkMapObjectController> placemarks = new HashMap<>();
  public final ClusterizedPlacemarkCollection clusterizedPlacemarkCollection;
  private boolean consumeTapEvents = false;
  @SuppressWarnings({"UnusedDeclaration", "FieldCanBeLocal"})
  private final WeakReference<YandexMapController> controller;
  public final String id;

  public ClusterizedPlacemarkCollectionController(
    MapObjectCollection parent,
    Map<String, Object> params,
    WeakReference<YandexMapController> controller
  ) {
    ClusterizedPlacemarkCollection clusterizedPlacemarkCollection =
      parent.addClusterizedPlacemarkCollection(this);

    this.clusterizedPlacemarkCollection = clusterizedPlacemarkCollection;
    this.id = (String) params.get("id");
    this.controller = controller;

    clusterizedPlacemarkCollection.setUserData(this.id);
    clusterizedPlacemarkCollection.addTapListener(this);
    update(params);
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void update(Map<String, Object> params) {
    updatePlacemarks((Map<String, Object>) params.get("placemarks"));
    clusterizedPlacemarkCollection.setVisible((Boolean) params.get("isVisible"));
    clusterizedPlacemarkCollection.clusterPlacemarks(
      ((Double) params.get("radius")).floatValue(),
      ((Number) params.get("minZoom")).intValue()
    );

    consumeTapEvents = (Boolean) params.get("consumeTapEvents");
  }

  public void remove() {
    for (PlacemarkMapObjectController placemarkController : placemarks.values()) {
      placemarkController.remove();
    }

    placemarks.clear();
    clusterizedPlacemarkCollection.getParent().remove(clusterizedPlacemarkCollection);

    removeClusters();
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  private void updatePlacemarks(Map<String, Object> params) {
    addPlacemarks((List<Map<String, Object>>) params.get("toAdd"));
    changePlacemarks((List<Map<String, Object>>) params.get("toChange"));
    removePlacemarks((List<Map<String, Object>>) params.get("toRemove"));
  }

  private void addPlacemarks(List<Map<String, Object>> params) {
    for (Map<String, Object> el : params) {
      addPlacemark(el);
    }
  }

  private void changePlacemarks(List<Map<String, Object>> params) {
    for (Map<String, Object> el : params) {
      changePlacemark(el);
    }
  }

  private void removePlacemarks(List<Map<String, Object>> params) {
    for (Map<String, Object> el : params) {
      removePlacemark(el);
    }
  }

  private void addPlacemark(Map<String, Object> params) {
    PlacemarkMapObjectController placemarkController = new PlacemarkMapObjectController(
      clusterizedPlacemarkCollection,
      params,
      controller
    );

    placemarks.put(placemarkController.id, placemarkController);
  }

  private void changePlacemark(Map<String, Object> params) {
    String id = (String) params.get("id");
    PlacemarkMapObjectController placemarkController = placemarks.get(id);

    if (placemarkController != null) placemarkController.update(params);
  }

  private void removePlacemark(Map<String, Object> params) {
    String id = (String) params.get("id");
    PlacemarkMapObjectController placemarkController = placemarks.get(id);

    if (placemarkController != null) placemarkController.remove();
    placemarks.remove(id);
  }

  public void removeClusters() {
    List<String> appearancePlacemarkIds = new ArrayList<>();
    for (PlacemarkMapObjectController placemarkController : clusters.values()) {
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
    final ClusterizedPlacemarkCollectionController self = this;
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
      @SuppressWarnings({"unchecked", "ConstantConditions"})
      public void success(@Nullable Object result) {
        if (
            result instanceof FlutterException ||
            controller.get() == null ||
            !self.clusterizedPlacemarkCollection.isValid() ||
            !cluster.isValid() ||
            !cluster.getAppearance().isValid()
        ) {
          return;
        }

        Map<String, Object> params = ((Map<String, Object>) result);

        clusters.put(
          cluster,
          new PlacemarkMapObjectController(cluster.getAppearance(), params, controller)
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
  @SuppressWarnings({"ConstantConditions"})
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

  @Override
  public boolean onMapObjectTap(@NonNull MapObject mapObject, @NonNull Point point) {
    controller.get().mapObjectTap(id, point);

    return consumeTapEvents;
  }
}
