package com.unact.yandexmapkit;

import android.content.Context;

import androidx.annotation.NonNull;

import com.yandex.mapkit.map.Cluster;
import com.yandex.mapkit.map.ClusterListener;
import com.yandex.runtime.image.ImageProvider;

public class YandexMapClusterListener implements ClusterListener {
    private Context ctx;
    private ImageProvider imageProvider;
    public YandexMapClusterListener(Context context) {
        ctx = context;
    }
    @Override
    public void onClusterAdded(@NonNull Cluster cluster) {
        if(null == imageProvider) {
            imageProvider = new MapClusterDefaultImageProvider(
                    cluster.getSize(),
                    ctx.getResources().getColor(android.R.color.white),
                    ctx.getResources().getDisplayMetrics().density
            );
        }

        cluster.getAppearance().setIcon(imageProvider);
    }

    public void setImageProvider(ImageProvider imageProvider) {
        this.imageProvider = imageProvider;
    }
}
