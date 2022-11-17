import 'dart:async';

import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:test/test.dart';
import 'package:nyxx_interactions/src/backend/interaction_backend.dart';

import '../mocks/nyxx_websocket.mocks.dart';

main() {
  final client = NyxxWebsocketMock();

  test("nyxx backend", () {
    final backend = WebsocketInteractionBackend(client);
    backend.setup();

    expect(backend.getStream(), isA<Stream<ApiData>>());
    expect(backend.getStream(), isA<Stream<Map<String, dynamic>>>());
    expect(backend.getStreamController(), isA<StreamController<Map<String, dynamic>>>());
  });
}
