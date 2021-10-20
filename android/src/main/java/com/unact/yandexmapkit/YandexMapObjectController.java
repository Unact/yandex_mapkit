package com.unact.yandexmapkit;

import java.util.Map;

abstract public class YandexMapObjectController {
  public String id;

  abstract public void update(Map<String, Object> params);

  abstract public void remove(Map<String, Object> params);
}
