package com.unact.yandexmapkit;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;

import com.yandex.runtime.image.ImageProvider;

public class MapClusterIconTextImageProvider extends ImageProvider {

    private static final float FONT_SIZE = 15;
    private static final float MARGIN_SIZE = 3;
    private static final float STROKE_SIZE = 3;

    private float density;
    private int backgroundPaintColor;

    public MapClusterIconTextImageProvider(int clusterSize, int color, float density) {
        this.text = Integer.toString(clusterSize);
        backgroundPaintColor = color;
        this.density = density;
    }

    @Override
    public String getId() {
        return "text_" + text;
    }

    private final String text;
    @Override
    public Bitmap getImage() {
        Paint textPaint = new Paint();
        textPaint.setTextSize(FONT_SIZE * density);
        textPaint.setTextAlign(Paint.Align.CENTER);
        textPaint.setStyle(Paint.Style.FILL);
        textPaint.setAntiAlias(true);

        float widthF = textPaint.measureText(text);
        Paint.FontMetrics textMetrics = textPaint.getFontMetrics();
        float heightF = Math.abs(textMetrics.bottom) + Math.abs(textMetrics.top);
        float textRadius = (float)Math.sqrt(widthF * widthF + heightF * heightF) / 2;
        float internalRadius = textRadius + MARGIN_SIZE * density;
        float externalRadius = internalRadius + STROKE_SIZE * density;

        int width = (int) (2 * externalRadius + 0.5);

        Bitmap bitmap = Bitmap.createBitmap(width, width, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        Paint backgroundPaint = new Paint();
        backgroundPaint.setAntiAlias(true);
        backgroundPaint.setColor(backgroundPaintColor);
        canvas.drawCircle(width / 2, width / 2, externalRadius, backgroundPaint);

        backgroundPaint.setColor(Color.WHITE);
        canvas.drawCircle(width / 2, width / 2, internalRadius, backgroundPaint);

        canvas.drawText(
                text,
                width / 2,
                width / 2 - (textMetrics.ascent + textMetrics.descent) / 2,
                textPaint);

        return bitmap;
    }
}
