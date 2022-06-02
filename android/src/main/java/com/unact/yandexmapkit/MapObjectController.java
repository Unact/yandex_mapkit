package com.unact.yandexmapkit;

import java.util.Map;

abstract public class MapObjectController {
  public String id;

  abstract public void update(Map<String, Object> params);

  abstract public void remove();
}
