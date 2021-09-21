package com.unact.yandexmapkit;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;

import com.yandex.runtime.image.ImageProvider;

import java.util.Map;

import io.flutter.Log;

public class MapClusterDefaultImageProvider extends ImageProvider {

    private static final float FONT_SIZE = 15;
    private static final float MARGIN_SIZE = 3;
    private static final float STROKE_SIZE = 3;

    private float density;
    private Bitmap outerBitmap;
    private Map<String, Object> options;

    public MapClusterDefaultImageProvider(int clusterSize, float density) {
        this.text = Integer.toString(clusterSize);
        this.density = density;
    }

    public MapClusterDefaultImageProvider(int clusterSize, float density, Map<String, Object> options) {
        this.text = Integer.toString(clusterSize);
        this.density = density;
        this.options = options;
    }

    public void setOuterBitmap(Bitmap bm) {
        outerBitmap = bm;
    }

    @Override
    public String getId() {
        return "text_" + text;
    }

    private final String text;
    @Override
    public Bitmap getImage() {
        // Styling text
        Paint textPaint = new Paint();
        textPaint.setTextSize(FONT_SIZE * density);
        if(options.containsKey("textAlign")) {
            String paramsTextAlign = (String) options.get("textAlign");
            switch (paramsTextAlign) {
                case "center":
                    textPaint.setTextAlign(Paint.Align.CENTER);
                    break;
                case "left":
                    textPaint.setTextAlign(Paint.Align.RIGHT);
                    break;
                case "right":
                    textPaint.setTextAlign(Paint.Align.LEFT);
                    break;
                default:
                    textPaint.setTextAlign(Paint.Align.CENTER);
                    break;
            }
        } else {
            textPaint.setTextAlign(Paint.Align.CENTER);
        }

        textPaint.setStyle(Paint.Style.FILL);
        textPaint.setAntiAlias(true);
        if(options.containsKey("textColor")) {
            Map<String, Integer> paramsColor = (Map<String, Integer>) options.get("textColor");
            if(paramsColor.containsKey("r")
                    && paramsColor.containsKey("g")
                    && paramsColor.containsKey("b")) {
                textPaint.setColor(Color.rgb( paramsColor.get("r"),paramsColor.get("g"), paramsColor.get("b")));
            } else {
                textPaint.setColor(Color.BLACK);
            }
        } else {
            textPaint.setColor(Color.BLACK);
        }


        // Sizes
        float widthF = textPaint.measureText(text);
        Paint.FontMetrics textMetrics = textPaint.getFontMetrics();
        float heightF = Math.abs(textMetrics.bottom) + Math.abs(textMetrics.top);
        float textRadius = (float)Math.sqrt(widthF * widthF + heightF * heightF) / 2;
        float internalRadius = textRadius + MARGIN_SIZE * density;
        float externalRadius = internalRadius + STROKE_SIZE * density;

        int width = (int) (2 * externalRadius + 0.5);
        Bitmap bitmap = null;
        Canvas canvas = null;
        // If background is asset
        if(outerBitmap != null) {
            bitmap = outerBitmap.copy(Bitmap.Config.ARGB_8888, true);
            //bitmap = Bitmap.createBitmap(bitmap);
            canvas = new Canvas(bitmap);
        }
        // If not
        if(bitmap == null) {
            bitmap = Bitmap.createBitmap(width, width, Bitmap.Config.ARGB_8888);
            canvas = new Canvas(bitmap);
            Paint backgroundPaint = new Paint();
            backgroundPaint.setAntiAlias(true);
            backgroundPaint.setColor(Color.BLACK);
            // Radius border color
            if(options.containsKey("strokeColor")) {
                Map<String, Integer> strokeColor = (Map<String, Integer>) options.get("strokeColor");
                if(strokeColor.containsKey("r") && strokeColor.containsKey("g") && strokeColor.containsKey("b")) {
                    backgroundPaint.setColor(Color.rgb(strokeColor.get("r"), strokeColor.get("g"), strokeColor.get("b")));
                }
            }

            canvas.drawCircle(width / 2, width / 2, externalRadius, backgroundPaint);

            // Circle background color
            backgroundPaint.setColor(Color.WHITE);
            if(options.containsKey("backgroundColor")) {
                Map<String, Integer> backgroundColor = (Map<String, Integer>) options.get("backgroundColor");
                if(backgroundColor.containsKey("r") && backgroundColor.containsKey("g") && backgroundColor.containsKey("b")) {
                    backgroundPaint.setColor(Color.rgb(backgroundColor.get("r"), backgroundColor.get("g"), backgroundColor.get("b")));
                }
            }

            canvas.drawCircle(width / 2, width / 2, internalRadius, backgroundPaint);
        }


        canvas.drawText(
                text,
                width / 2,
                width / 2 - (textMetrics.ascent + textMetrics.descent) / 2,
                textPaint);

        return bitmap;
    }
}
