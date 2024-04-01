package com.unact.yandexmapkit.full;

import androidx.annotation.NonNull;

import com.yandex.mapkit.BaseMetadata;
import com.yandex.mapkit.GeoObject;
import com.yandex.mapkit.GeoObjectCollection;
import com.yandex.mapkit.geometry.Geometry;
import com.yandex.mapkit.search.Address;
import com.yandex.mapkit.search.BusinessObjectMetadata;
import com.yandex.mapkit.search.Response;
import com.yandex.mapkit.search.SearchManager;
import com.yandex.mapkit.search.Session;
import com.yandex.mapkit.search.ToponymObjectMetadata;
import com.yandex.runtime.Error;
import com.yandex.runtime.TypeDictionary;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexSearchSession implements MethodChannel.MethodCallHandler {
  private final int id;
  private Session session;
  private final MethodChannel methodChannel;
  private final SearchManager searchManager;
  private int page = 0;
  @SuppressWarnings({"MismatchedQueryAndUpdateOfCollection"})
  private static final Map<Integer, YandexSearchSession> searchSessions = new HashMap<>();

  public static void initSession(int id, BinaryMessenger messenger, SearchManager searchManager) {
    searchSessions.put(id, new YandexSearchSession(id, messenger, searchManager));
  }

  public YandexSearchSession(
    int id,
    BinaryMessenger messenger,
    SearchManager searchManager
    ) {
    this.id = id;
    this.searchManager = searchManager;

    methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_search_session_" + id);
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "searchByText":
        searchByText(call, result);
        break;
      case "searchByPoint":
        searchByPoint(call, result);
        break;
      case "cancel":
        cancel();
        result.success(null);
        break;
      case "retry":
        retry(result);
        break;
      case "hasNextPage":
        boolean value = hasNextPage();
        result.success(value);
        break;
      case "fetchNextPage":
        fetchNextPage(result);
        break;
      case "close":
        close();
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void searchByText(MethodCall call, MethodChannel.Result result) {
    YandexSearchSession self = this;
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    session = searchManager.submit(
      (String) params.get("searchText"),
      UtilsFull.geometryFromJson((Map<String, Object>) params.get("geometry")),
      UtilsFull.searchOptionsFromJson((Map<String, Object>) params.get("searchOptions")),
      new Session.SearchListener() {
        @Override
        public void onSearchResponse(@NonNull Response response) { self.onSearchResponse(response, result); }
        @Override
        public void onSearchError(@NonNull Error error) { self.onSearchError(error, result); }
      }
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public void searchByPoint(MethodCall call, MethodChannel.Result result) {
    YandexSearchSession self = this;
    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    session = searchManager.submit(
      UtilsFull.pointFromJson((Map<String, Object>) params.get("point")),
      ((Integer) params.get("zoom")),
      UtilsFull.searchOptionsFromJson((Map<String, Object>) params.get("searchOptions")),
      new Session.SearchListener() {
        @Override
        public void onSearchResponse(@NonNull Response response) { self.onSearchResponse(response, result); }
        @Override
        public void onSearchError(@NonNull Error error) { self.onSearchError(error, result); }
      }
    );
  }

  public void cancel() {
    session.cancel();
  }

  public void retry(MethodChannel.Result result) {
    YandexSearchSession self = this;
    page = 0;

    session.retry(
      new Session.SearchListener() {
        @Override
        public void onSearchResponse(@NonNull Response response) { self.onSearchResponse(response, result); }
        @Override
        public void onSearchError(@NonNull Error error) { self.onSearchError(error, result); }
      }
    );
  }

  public boolean hasNextPage() {
    return session.hasNextPage();
  }

  public void fetchNextPage(MethodChannel.Result result) {
    YandexSearchSession self = this;

    if (session.hasNextPage()) {
      page++;

      session.fetchNextPage(
        new Session.SearchListener() {
          @Override
          public void onSearchResponse(@NonNull Response response) { self.onSearchResponse(response, result); }
          @Override
          public void onSearchError(@NonNull Error error) { self.onSearchError(error, result); }
        }
      );
    }
  }

  public void close() {
    session.cancel();
    methodChannel.setMethodCallHandler(null);

    searchSessions.remove(id);
  }

  private void onSearchResponse(@NonNull Response response, @NonNull Result result) {
    Map<String, Object> arguments = new HashMap<>();
    List<Map<String, Object>> dataItems = new ArrayList<>();

    for (GeoObjectCollection.Item item : response.getCollection().getChildren()) {
      GeoObject obj = item.getObj();

      if (obj == null) {
        continue;
      }

      List<Map<String, Object>> geometryList = new ArrayList<>();
      for (Geometry geometry : obj.getGeometry()) {
        geometryList.add(UtilsFull.geometryToJson(geometry));
      }

      Map<String, Object> dataItem = new HashMap<>();
      dataItem.put("name", obj.getName());
      dataItem.put("geometry", geometryList);
      dataItem.put("toponymMetadata", getToponymMetadata(obj.getMetadataContainer()));
      dataItem.put("businessMetadata", getBusinessMetadata(obj.getMetadataContainer()));

      dataItems.add(dataItem);
    }

    arguments.put("found", response.getMetadata().getFound());
    arguments.put("page", page);
    arguments.put("items", dataItems);

    result.success(arguments);
  }

  private void onSearchError(@NonNull Error error, @NonNull Result result) {
    result.success(UtilsFull.errorToJson(error));
  }

  private Map<String, Object> getToponymMetadata(TypeDictionary<BaseMetadata> metadataContainer) {
    ToponymObjectMetadata meta = metadataContainer.getItem(ToponymObjectMetadata.class);

    if (meta == null) {
      return null;
    }

    Map<String, Object> address = new HashMap<>();
    address.put("formattedAddress", meta.getAddress().getFormattedAddress());
    address.put("addressComponents", getAddressComponents(meta.getAddress()));

    Map<String, Object> toponymMetadata = new HashMap<>();
    toponymMetadata.put("address", address);
    toponymMetadata.put("balloonPoint", UtilsFull.pointToJson(meta.getBalloonPoint()));

    return toponymMetadata;
  }

  private Map<String, Object> getBusinessMetadata(TypeDictionary<BaseMetadata> metadataContainer) {
    BusinessObjectMetadata meta = metadataContainer.getItem(BusinessObjectMetadata.class);

    if (meta == null) {
      return null;
    }

    Map<String, Object> address = new HashMap<>();
    address.put("formattedAddress", meta.getAddress().getFormattedAddress());
    address.put("addressComponents", getAddressComponents(meta.getAddress()));

    Map<String, Object> businessMetadata = new HashMap<>();
    businessMetadata.put("name", meta.getName());
    businessMetadata.put("shortName", meta.getShortName());
    businessMetadata.put("address", address);

    return businessMetadata;
  }

  private Map<Integer, String> getAddressComponents(Address address) {
    Map<Integer, String> addressComponents = new HashMap<>();

    for (Address.Component addressComponent : address.getComponents()) {
      String value = addressComponent.getName();

      for (Address.Component.Kind addressComponentKind : addressComponent.getKinds()) {
        int flutterKind = 0;

        switch (addressComponentKind) {
          case COUNTRY:
            flutterKind = 1;
            break;
          case REGION:
            flutterKind = 2;
            break;
          case PROVINCE:
            flutterKind = 3;
            break;
          case AREA:
            flutterKind = 4;
            break;
          case LOCALITY:
            flutterKind = 5;
            break;
          case DISTRICT:
            flutterKind = 6;
            break;
          case STREET:
            flutterKind = 7;
            break;
          case HOUSE:
            flutterKind = 8;
            break;
          case ENTRANCE:
            flutterKind = 9;
            break;
          case ROUTE:
            flutterKind = 10;
            break;
          case STATION:
            flutterKind = 11;
            break;
          case METRO_STATION:
            flutterKind = 12;
            break;
          case RAILWAY_STATION:
            flutterKind = 13;
            break;
          case VEGETATION:
            flutterKind = 14;
            break;
          case HYDRO:
            flutterKind = 15;
            break;
          case AIRPORT:
            flutterKind = 16;
            break;
          case OTHER:
            flutterKind = 17;
            break;
          default:
            break;
        }

        addressComponents.put(flutterKind, value);
      }
    }

    return addressComponents;
  }
}
