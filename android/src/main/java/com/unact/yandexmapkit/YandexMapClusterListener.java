package com.unact.yandexmapkit;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import androidx.annotation.NonNull;

import com.yandex.mapkit.map.Cluster;
import com.yandex.mapkit.map.ClusterListener;
import com.yandex.runtime.image.ImageProvider;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

public class YandexMapClusterListener implements ClusterListener {
    private Context ctx;
    private AssetManager assetManager;
    private Bitmap outerBitmap;
    private Map<String, Object> options;

    public void setOptions(Map<String, Object> options) {
        this.options = options;
    }

    public YandexMapClusterListener(Context context) {
        ctx = context;
        assetManager = ctx.getAssets();
    }
    @Override
    public void onClusterAdded(@NonNull Cluster cluster) {
        ImageProvider imageProvider = new MapClusterDefaultImageProvider(
                cluster.getSize(),
                ctx.getResources().getDisplayMetrics().density
        );

        if(options != null) {
            imageProvider = new MapClusterDefaultImageProvider(
                    cluster.getSize(),
                    ctx.getResources().getDisplayMetrics().density,
                    options
            );
        }

        if(outerBitmap != null) {
            ((MapClusterDefaultImageProvider) imageProvider).setOuterBitmap(outerBitmap);
        }


        cluster.getAppearance().setIcon(imageProvider);
    }

    public void loadBitmap(String assetName) {
        if(assetName == "") {
            return;
        }
        Bitmap result = null;

        try {
            InputStream i = assetManager.open(assetName);

            try {
                result = BitmapFactory.decodeStream(i);
            } finally {
                i.close();
            }
        } catch (IOException var7) {
            Log.e("yandex.maps", "Can't load image from asset: " + assetName, var7);
        }

        if(result != null) {
            this.outerBitmap = result;
        }
    }

}
