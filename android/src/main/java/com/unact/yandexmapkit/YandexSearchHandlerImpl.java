package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.GeoObject;
import com.yandex.mapkit.GeoObjectCollection;
import com.yandex.mapkit.geometry.Geometry;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.search.Address;
import com.yandex.mapkit.search.BusinessObjectMetadata;
import com.yandex.mapkit.search.Response;
import com.yandex.mapkit.search.SearchOptions;
import com.yandex.mapkit.search.Session;
import com.yandex.mapkit.search.Snippet;
import com.yandex.mapkit.search.SuggestItem;
import com.yandex.mapkit.search.SearchFactory;
import com.yandex.mapkit.search.SearchManagerType;
import com.yandex.mapkit.search.SuggestOptions;
import com.yandex.mapkit.search.SearchManager;
import com.yandex.mapkit.search.SuggestSession;
import com.yandex.mapkit.search.ToponymObjectMetadata;
import com.yandex.runtime.Error;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexSearchHandlerImpl implements MethodCallHandler {

  private MethodChannel methodChannel;

  private Map<Integer, SuggestSession> suggestSessionsById = new HashMap<>();
  private Session searchSession;

  private final SearchManager searchManager;

  public YandexSearchHandlerImpl(Context context, MethodChannel channel) {
    SearchFactory.initialize(context);
    methodChannel = channel;
    searchManager = SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "getSuggestions":
        getSuggestions(call);
        result.success(null);
        break;
      case "cancelSuggestSession":
        cancelSuggestSession(call);
        result.success(null);
        break;
      case "searchByText":
        searchByText(call);
        result.success(null);
        break;
      case "cancelSearch":
        cancelSearch();
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @SuppressWarnings("unchecked")
  private void cancelSuggestSession(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    final int listenerId = ((Number) params.get("listenerId")).intValue();

    suggestSessionsById.remove(listenerId);
  }

  @SuppressWarnings("unchecked")
  private void getSuggestions(MethodCall call) {
    Map<String, Object> params = ((Map<String, Object>) call.arguments);
    final int listenerId = ((Number) params.get("listenerId")).intValue();
    String formattedAddress = (String) params.get("formattedAddress");
    BoundingBox boundingBox = new BoundingBox(
      new Point(((Double) params.get("southWestLatitude")), ((Double) params.get("southWestLongitude"))),
      new Point(((Double) params.get("northEastLatitude")), ((Double) params.get("northEastLongitude")))
    );
    Boolean suggestWords = ((Boolean) params.get("suggestWords"));
    SuggestSession suggestSession = searchManager.createSuggestSession();
    SuggestOptions suggestOptions = new SuggestOptions();
    suggestOptions.setSuggestTypes(((Number) params.get("suggestType")).intValue());
    suggestOptions.setSuggestWords(suggestWords);

    suggestSession.suggest(formattedAddress, boundingBox, suggestOptions, new YandexSuggestListener(listenerId));
    suggestSessionsById.put(listenerId, suggestSession);
  }

  public void searchByText(MethodCall call) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    String              searchText  = (String) params.get("searchText");
    Map<String, Object> geometry    = (Map<String, Object>) params.get("geometry");
    Map<String, Object> options     = (Map<String, Object>) params.get("options");

    Geometry geometryObj;

    if (geometry.containsKey("point")) {

      Map<String, Object> point = (Map<String, Object>) geometry.get("point");

      geometryObj = Geometry.fromPoint(
              new Point(((Double) point.get("latitude")), ((Double) point.get("longitude")))
      );

    } else {

      Map<String, Object> boundingBox = (Map<String, Object>) geometry.get("boundingBox");

      Map<String, Object> southWest = (Map<String, Object>) boundingBox.get("southWest");
      Map<String, Object> northEast = (Map<String, Object>) boundingBox.get("northEast");

      geometryObj = Geometry.fromBoundingBox(
        new BoundingBox(
          new Point(((Double) southWest.get("latitude")), ((Double) southWest.get("longitude"))),
          new Point(((Double) northEast.get("latitude")), ((Double) northEast.get("longitude")))
        )
      );
    }

    int                 searchTypeOption     = ((Number) options.get("searchType")).intValue();
    Number              resultPageSizeOption = (Number) options.get("resultPageSize");
    Map<String, Object> userPositionOption   = (Map<String, Object>) options.get("userPosition");

    Integer resultPageSize = null;
    if (resultPageSizeOption != null) {
      resultPageSize = resultPageSizeOption.intValue();
    }

    // Theses params are not implemented on the flutter side yet
    int snippetOption = Snippet.NONE.value;
    List<String> experimentalSnippetsOption = new ArrayList<>();

    Point userPosition = null;

    if (userPositionOption != null) {
      userPosition = new Point(((Double) userPositionOption.get("latitude")), ((Double) userPositionOption.get("longitude")));
    }

    String  originOption                    = (String) options.get("origin");
    String  directPageIdOption              = (String) options.get("directPageId");
    String  appleCtxOption                  = (String) options.get("appleCtx");
    Boolean geometryOption                  = (Boolean) options.get("geometry");
    String  advertPageIdOption              = (String) options.get("advertPageId");
    Boolean suggestWordsOption              = (Boolean) options.get("suggestWords");
    Boolean disableSpellingCorrectionOption = (Boolean) options.get("disableSpellingCorrection");

    if (geometryOption == null) {
      geometryOption = false;
    }

    if (suggestWordsOption == null) {
      suggestWordsOption = false;
    }

    if (disableSpellingCorrectionOption == null) {
      disableSpellingCorrectionOption = false;
    }

    SearchOptions searchOptions = new SearchOptions(
      searchTypeOption,
      resultPageSize,
      snippetOption,
      experimentalSnippetsOption,
      userPosition,
      originOption,
      directPageIdOption,
      appleCtxOption,
      geometryOption,
      advertPageIdOption,
      suggestWordsOption,
      disableSpellingCorrectionOption
    );

    searchSession = searchManager.submit(
      searchText,
      geometryObj,
      searchOptions,
      new YandexSearchListener()
    );
  }

  public void cancelSearch() {

    if (searchSession != null) {
      searchSession.cancel();
    }
  }

  private class YandexSuggestListener implements SuggestSession.SuggestListener {

    public YandexSuggestListener(int id) {
      listenerId = id;
    }

    private int listenerId;

    @Override
    public void onResponse(@NonNull List<SuggestItem> suggestItems) {
      List<Map<String, Object>> suggests = new ArrayList<>();

      for (SuggestItem suggestItemResult : suggestItems) {
        Map<String, Object> suggestMap = new HashMap<>();
        suggestMap.put("title", suggestItemResult.getTitle().getText());
        if(suggestItemResult.getSubtitle() != null) {
          suggestMap.put("subtitle", suggestItemResult.getSubtitle().getText());
        }
        if(suggestItemResult.getDisplayText() != null) {
          suggestMap.put("displayText", suggestItemResult.getDisplayText());
        }
        suggestMap.put("searchText", suggestItemResult.getSearchText());
        suggestMap.put("type", suggestItemResult.getType().ordinal());
        suggestMap.put("tags", suggestItemResult.getTags());

        suggests.add(suggestMap);
      }

      Map<String, Object> arguments = new HashMap<>();
      arguments.put("listenerId", listenerId);
      arguments.put("response", suggests);

      methodChannel.invokeMethod("onSuggestListenerResponse", arguments);
    }

    @Override
    public void onError(@NonNull Error error) {
      Map<String, Object> arguments = new HashMap<>();
      arguments.put("listenerId", listenerId);
      methodChannel.invokeMethod("onSuggestListenerError", arguments);
    }
  }

  private class YandexSearchListener implements Session.SearchListener {

    @Override
    public void onSearchResponse(@NonNull Response response) {

      Map<String, Object> data = new HashMap<>();

      data.put("found", response.getMetadata().getFound());

      List<Map<String, Object>> dataItems = new ArrayList<>();

      Iterator<GeoObjectCollection.Item> objectsIterator = response.getCollection().getChildren().iterator();

      while (objectsIterator.hasNext()) {

        GeoObjectCollection.Item item = objectsIterator.next();

        GeoObject obj = item.getObj();
        if (item.getObj() == null) {
          continue;
        }

        Map<String, Object> dataItem = new HashMap<>();

        dataItem.put("name", obj.getName());

        List<Map<String, Object>> geometry = new ArrayList<>();

        Iterator<Geometry> geometryIterator = obj.getGeometry().iterator();

        while (geometryIterator.hasNext()) {

          final Geometry geometryItem = geometryIterator.next();

          if (geometryItem.getPoint() != null) {
            geometry.add(
              new HashMap<String,Object>() {{
                put(
                  "point",
                  new HashMap<String, Object>() {{
                    put("latitude", geometryItem.getPoint().getLatitude());
                    put("longitude", geometryItem.getPoint().getLongitude());
                  }}
                );
              }}
            );
          }

          if (geometryItem.getBoundingBox() != null) {
            geometry.add(
              new HashMap<String,Object>() {{
                put("boundingBox",
                  new HashMap<String, Object>() {{
                    put("southWest", new HashMap<String, Object>() {{
                      put("latitude", geometryItem.getBoundingBox().getSouthWest().getLatitude());
                      put("longitude", geometryItem.getBoundingBox().getSouthWest().getLongitude());
                    }});
                    put("northEast", new HashMap<String, Object>() {{
                      put("latitude", geometryItem.getBoundingBox().getNorthEast().getLatitude());
                      put("longitude", geometryItem.getBoundingBox().getNorthEast().getLongitude());
                    }});
                  }}
                );
              }}
            );
          }
        }

        dataItem.put("geometry", geometry);

        ToponymObjectMetadata toponymMeta = obj.getMetadataContainer().getItem(ToponymObjectMetadata.class);
        if (toponymMeta != null) {
          dataItem.put("toponymMetadata", getToponymMetadata(toponymMeta));
        }

        BusinessObjectMetadata businessMeta = obj.getMetadataContainer().getItem(BusinessObjectMetadata.class);
        if (businessMeta != null) {
          dataItem.put("businessMetadata", getBusinessMetadata(businessMeta));
        }

        dataItems.add(dataItem);
      }

      data.put("items", dataItems);

      Map<String, Object> arguments = new HashMap<>();

      arguments.put("response", data);

      methodChannel.invokeMethod("onSearchListenerResponse", arguments);
    }

    private Map<String, Object> getToponymMetadata(ToponymObjectMetadata meta) {

      Map<String, Object> toponymMetadata = new HashMap<>();

      Map<String, Double> balloonPoint = new HashMap<>();

      balloonPoint.put("latitude", meta.getBalloonPoint().getLatitude());
      balloonPoint.put("longitude", meta.getBalloonPoint().getLongitude());

      toponymMetadata.put("balloonPoint", balloonPoint);

      Map<String, Object> address = new HashMap<>();

      address.put("formattedAddress", meta.getAddress().getFormattedAddress());
      address.put("addressComponents", getAddressComponents(meta.getAddress()));

      toponymMetadata.put("address", address);

      return toponymMetadata;
    }

    private Map<String, Object> getBusinessMetadata(BusinessObjectMetadata meta) {

      Map<String, Object> businessMetadata = new HashMap<>();

      businessMetadata.put("name", meta.getName());

      if (meta.getShortName() != null) {
        businessMetadata.put("shortName", meta.getShortName());
      }

      Map<String, Object> address = new HashMap<>();

      address.put("formattedAddress", meta.getAddress().getFormattedAddress());
      address.put("addressComponents", getAddressComponents(meta.getAddress()));

      businessMetadata.put("address", address);

      return businessMetadata;
    }

    private Map<Integer, String> getAddressComponents(Address address) {

      Map<Integer, String> addressComponents = new HashMap<>();

      Iterator<Address.Component> iterator = address.getComponents().iterator();

      while (iterator.hasNext()) {

        Address.Component addressComponent = iterator.next();

        Integer flutterKind = 0;

        String value = addressComponent.getName();

        Iterator<Address.Component.Kind> addressKindsIterator = addressComponent.getKinds().iterator();

        while (addressKindsIterator.hasNext()) {

          Address.Component.Kind addressComponentKind = addressKindsIterator.next();

          switch (addressComponentKind) {
            case UNKNOWN:
              flutterKind = 0;
              break;
            case COUNTRY:
              flutterKind = 2;
              break;
            case REGION:
              flutterKind = 3;
              break;
            case PROVINCE:
              flutterKind = 4;
              break;
            case AREA:
              flutterKind = 5;
              break;
            case LOCALITY:
              flutterKind = 6;
              break;
            case DISTRICT:
              flutterKind = 7;
              break;
            case STREET:
              flutterKind = 8;
              break;
            case HOUSE:
              flutterKind = 9;
              break;
            case ENTRANCE:
              flutterKind = 10;
              break;
            case ROUTE:
              flutterKind = 11;
              break;
            case STATION:
              flutterKind = 12;
              break;
            case METRO_STATION:
              flutterKind = 13;
              break;
            case RAILWAY_STATION:
              flutterKind = 14;
              break;
            case VEGETATION:
              flutterKind = 15;
              break;
            case HYDRO:
              flutterKind = 16;
              break;
            case AIRPORT:
              flutterKind = 17;
              break;
            case OTHER:
              break;
          }

          addressComponents.put(flutterKind, value);
        }
      }

      return addressComponents;
    }

    @Override
    public void onSearchError(@NonNull Error error) {

      Map<String, Object> arguments = new HashMap<>();

      String errorMessage = "Unknown error";

      if (error instanceof SearchError) {
        errorMessage = ((SearchError) error).getMessage();
      }

      arguments.put("error", errorMessage);

      methodChannel.invokeMethod("onSearchListenerError", arguments);
    }
  }

  private class SearchError implements Error {

    private String message;

    public SearchError(String message) {
      this.message = message;
    }

    public String getMessage() {
      return message;
    }

    @Override
    public boolean isValid() {
      return false;
    }
  }
}
