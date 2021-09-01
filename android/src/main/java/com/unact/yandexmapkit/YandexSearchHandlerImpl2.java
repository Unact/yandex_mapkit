package com.unact.yandexmapkit;

import android.content.Context;

import com.yandex.mapkit.geometry.Geometry;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.geometry.BoundingBox;
import com.yandex.mapkit.search.SearchOptions;
import com.yandex.mapkit.search.Session;
import com.yandex.mapkit.search.Snippet;
import com.yandex.mapkit.search.SearchFactory;
import com.yandex.mapkit.search.SearchManagerType;
import com.yandex.mapkit.search.SearchManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class YandexSearchHandlerImpl2 implements MethodCallHandler {

  private final SearchManager searchManager;
  private final BinaryMessenger binaryMessenger;

  private Map<Integer, YandexSearchSession> searchSessionsById  = new HashMap<>();;

  public YandexSearchHandlerImpl2(Context context, BinaryMessenger messenger) {

    SearchFactory.initialize(context);

    searchManager 	= SearchFactory.getInstance().createSearchManager(SearchManagerType.COMBINED);
		binaryMessenger	= messenger;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "searchByText":
        searchByText(call, result);
        break;
      case "searchByPoint":
        searchByPoint(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  public void searchByText(MethodCall call, MethodChannel.Result result) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    int                 sessionId   = ((Number) params.get("sessionId")).intValue();
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

    SearchOptions searchOptions = getSearchOptions(options);

    Session searchSession = searchManager.submit(
      searchText,
      geometryObj,
      searchOptions,
      new YandexSearchListener(result, 0)
    );

    YandexSearchSession session = new YandexSearchSession(
      sessionId,
      searchSession,
      binaryMessenger,
      new CloseSearchSessionCallback()
    );

    searchSessionsById.put(sessionId, session);
  }

  public void searchByPoint(MethodCall call, MethodChannel.Result result) {

    Map<String, Object> params = ((Map<String, Object>) call.arguments);

    int 								sessionId	= ((Number) params.get("sessionId")).intValue();
    Map<String, Object> point    	= (Map<String, Object>) params.get("point");
    Integer             zoom  		= (Integer) params.get("zoom");
    Map<String, Object> options   = (Map<String, Object>) params.get("options");

    SearchOptions searchOptions = getSearchOptions(options);

    Session searchSession = searchManager.submit(
      new Point(((Double) point.get("latitude")), ((Double) point.get("longitude"))),
      zoom,
      searchOptions,
      new YandexSearchListener(result, 0)
    );

    YandexSearchSession session = new YandexSearchSession(
      sessionId,
      searchSession,
      binaryMessenger,
      new CloseSearchSessionCallback()
    );

    searchSessionsById.put(sessionId, session);
  }

  private SearchOptions getSearchOptions(Map<String, Object> options) {

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

    return searchOptions;
  }

	private class CloseSearchSessionCallback implements YandexSearchSessionCloseCallbackInterface {

		@Override
		public void onClose(int sessionId) {
			searchSessionsById.remove(sessionId);
		}
	}
}
