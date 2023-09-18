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
import com.yandex.runtime.any.Collection;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class YandexSearchListener implements Session.SearchListener {
    private final MethodChannel.Result result;
    private final int page;

    YandexSearchListener(MethodChannel.Result result, int page) {
        this.result = result;
        this.page = page;
    }

    @Override
    public void onSearchResponse(@NonNull Response response) {
        Map<String, Object> arguments = new HashMap<>();
        List<Map<String, Object>> dataItems = new ArrayList<>();

        for (GeoObjectCollection.Item item : response.getCollection().getChildren()) {
            GeoObject obj = item.getObj();

            if (obj == null) {
                continue;
            }

            List<Map<String, Object>> geometryList = new ArrayList<>();
            for (Geometry geometry : obj.getGeometry()) {
                geometryList.add(Utils.geometryToJson(geometry));
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

    @Override
    public void onSearchError(@NonNull Error error) {
        result.success(Utils.errorToJson(error));
    }

    private Map<String, Object> getToponymMetadata(Collection metadataContainer) {
        ToponymObjectMetadata meta = metadataContainer.getItem(ToponymObjectMetadata.class);

        if (meta == null) {
            return null;
        }

        Map<String, Object> address = new HashMap<>();
        address.put("formattedAddress", meta.getAddress().getFormattedAddress());
        address.put("addressComponents", getAddressComponents(meta.getAddress()));

        Map<String, Object> toponymMetadata = new HashMap<>();
        toponymMetadata.put("address", address);
        toponymMetadata.put("balloonPoint", Utils.pointToJson(meta.getBalloonPoint()));

        return toponymMetadata;
    }

    private Map<String, Object> getBusinessMetadata(Collection metadataContainer) {
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
