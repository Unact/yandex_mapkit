package com.unact.yandexmapkit;

import com.yandex.mapkit.search.Session;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

interface YandexSearchSessionCloseCallbackInterface {
  void onClose(int sessionId);
}

public class YandexSearchSession implements MethodChannel.MethodCallHandler {

  private int id;
  private Session session;
  private int page = 0;

  private MethodChannel methodChannel;

  private YandexSearchSessionCloseCallbackInterface closeCallback;

  public YandexSearchSession(
    int id,
    Session session,
    BinaryMessenger messenger,
    YandexSearchSessionCloseCallbackInterface onClose) {

    this.id = id;
    this.session = session;
    this.closeCallback = onClose;

    methodChannel = new MethodChannel(messenger, "yandex_mapkit/yandex_search_session_" + id);
    methodChannel.setMethodCallHandler(this);
  }

	@Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "cancelSearch":
        cancelSearch();
        result.success(null);
        break;
      case "retrySearch":
        retrySearch(result);
        break;
      case "hasNextPage":
        boolean value = hasNextPage();
        result.success(value);
        break;
      case "fetchNextPage":
        fetchNextPage(result);
        break;
      case "close":
        close();
        result.success(null);
        break;
      default:
        result.notImplemented();
        break;
		}
  }

  public void cancelSearch() {

    session.cancel();
  }

  public void retrySearch(MethodChannel.Result result) {

    page = 0;

    session.retry(new YandexSearchListener(result, page));
  }

  public boolean hasNextPage() {

    return session.hasNextPage();
  }

	public void fetchNextPage(MethodChannel.Result result) {

    if (session.hasNextPage()) {

      page++;

      session.fetchNextPage(new YandexSearchListener(result, page));
    }
	}

	public void close() {

    session.cancel();
    session = null;

    methodChannel.setMethodCallHandler(null);

    closeCallback.onClose(id);
	}
}
