package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.map.Cluster;
import com.yandex.mapkit.map.ClusterListener;

public class YandexMapClusterListener implements ClusterListener {
    private Context ctx;
    public YandexMapClusterListener(Context context) {
        ctx = context;
    }
    @Override
    public void onClusterAdded(@NonNull Cluster cluster) {
        cluster.getAppearance().setIcon(
                new MapClusterIconTextImageProvider(
                        cluster.getSize(),
                        ctx.getResources().getColor(android.R.color.white),
                        ctx.getResources().getDisplayMetrics().density
                )
        );


    }
}
