package com.unact.yandexmapkit.full;

import com.unact.yandexmapkit.lite.UtilsLite;
import com.yandex.mapkit.directions.driving.DrivingOptions;
import com.yandex.mapkit.geometry.Point;
import com.yandex.mapkit.search.SearchOptions;
import com.yandex.mapkit.search.SuggestOptions;
import com.yandex.mapkit.transport.masstransit.TimeOptions;

import java.util.Map;

public class UtilsFull extends UtilsLite {
  public static TimeOptions timeOptionsFromJson(Map<String, Object> json) {
    return new TimeOptions(
      (Long) json.get("departureTime"),
      (Long) json.get("arrivalTime")
    );
  }

  public static DrivingOptions drivingOptionsFromJson(Map<String, Object> json) {
    return new DrivingOptions(
      (Double) json.get("initialAzimuth"),
      (Integer) json.get("routesCount"),
      (Boolean) json.get("avoidTolls"),
      (Boolean) json.get("avoidUnpaved"),
      (Boolean) json.get("avoidPoorConditions"),
      null,
      null
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static SearchOptions searchOptionsFromJson(Map<String, Object> json) {
    Point userPosition = json.get("userPosition") != null ?
      pointFromJson((Map<String, Object>) json.get("userPosition")) :
      null;

    return new SearchOptions(
      ((Number) json.get("searchType")).intValue(),
      (Integer) json.get("resultPageSize"),
      0,
      userPosition,
      (String) json.get("origin"),
      (Boolean) json.get("geometry"),
      (Boolean) json.get("disableSpellingCorrection"),
      null
    );
  }

  @SuppressWarnings({"unchecked", "ConstantConditions"})
  public static SuggestOptions suggestOptionsFromJson(Map<String, Object> json) {
    Point userPosition = json.get("userPosition") != null ?
      pointFromJson((Map<String, Object>) json.get("userPosition")) :
      null;

    return new SuggestOptions(
      ((Number) json.get("suggestType")).intValue(),
      userPosition,
      ((Boolean) json.get("suggestWords"))
    );
  }
}
