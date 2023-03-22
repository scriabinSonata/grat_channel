import 'dart:convert';

import 'package:grat_channel/channel_event.dart';
import 'package:web_socket_channel/io.dart';

abstract class GratChannelInterface {
  final String url;
  final Map<String, Object> payload;
  final bool? cancelOnError;
  final bool? logging;
  IOWebSocketChannel? channel;

  GratChannelInterface(
    this.url,
    this.payload, {
    this.cancelOnError,
    this.logging,
  });

  void connect() {
    channel = IOWebSocketChannel.connect(url);

    channel!.stream.listen(
      (event) => onDataParser(event, channel!),
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void exit() {
    channel?.sink.add(encode('bye'));
    channel?.sink.close();
  }

  ///```
  ///
  /// 데이터를 소켓에 보낼 때 사용.
  ///
  /// ex)
  /// add('send', data.toMap());
  ///```
  void add(String type, [Map<String, dynamic>? message]) {
    channel?.sink.add(encode(type, message));
  }

  String encode(String type, [Map<String, dynamic>? message]) {
    return jsonEncode({
      'type': type,
      'message': _addPayload(message),
    });
  }

  Map<String, dynamic> _addPayload(Map<String, dynamic>? source) {
    return {
      if (source != null) ...source,
      ...payload,
    };
  }

  Future<void> onData(ChannelEvent event, IOWebSocketChannel channel);

  void onDataParser(dynamic event, IOWebSocketChannel channel) {
    Map<String, dynamic> parsedEvent = jsonDecode(event)['data'];

    if (logging == true) {
      log(parsedEvent);
    }

    onData(
        ChannelEvent(
          parsedEvent['type'],
          parsedEvent['message'],
        ),
        channel);
  }

  void onError(dynamic error) {}

  void onDone() {}

  void log(Map<String, dynamic> event) {}
}
