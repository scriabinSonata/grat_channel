import 'package:grat_channel/grat_channel.dart';
import 'package:web_socket_channel/io.dart';

class SampleChannel extends GratChannelInterface {
  SampleChannel({
    required String url,
    required Map<String, Object> payload,
  }) : super(url, payload);

  @override
  Future<void> onData(ChannelEvent event, IOWebSocketChannel channel) async {
    switch (event.type) {
      case 'request':
        channel.sink.add(encode('response', {'key': 'value'}));
        break;
    }
  }
}
