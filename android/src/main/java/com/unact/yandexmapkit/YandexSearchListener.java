package com.unact.yandexmapkit;

import androidx.annotation.NonNull;

import com.yandex.mapkit.GeoObject;
import com.yandex.mapkit.GeoObjectCollection;
import com.yandex.mapkit.geometry.Geometry;
import com.yandex.mapkit.search.Address;
import com.yandex.mapkit.search.BusinessObjectMetadata;
import com.yandex.mapkit.search.Response;
import com.yandex.mapkit.search.Session;
import com.yandex.mapkit.search.ToponymObjectMetadata;
import com.yandex.runtime.Error;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexSearchListener implements Session.SearchListener {

  private MethodChannel.Result 	result;
  private int 									page;

  YandexSearchListener(MethodChannel.Result result, int page) {

    this.result = result;
    this.page 	= page;
  }

	@Override
	public void onSearchResponse(@NonNull Response response) {

    Map<String, Object> data = new HashMap<>();

    data.put("found", response.getMetadata().getFound());
    data.put("page", page);

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

    result.success(arguments);
	}

	@Override
	public void onSearchError(@NonNull Error error) {

    Map<String, Object> arguments = new HashMap<>();

    arguments.put("error", "Unknown error");

    result.success(arguments);
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
}