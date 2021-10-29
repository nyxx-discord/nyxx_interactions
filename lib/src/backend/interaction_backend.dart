import 'dart:async';

import 'package:nyxx/nyxx.dart';

typedef ApiData = Map<String, dynamic>;

abstract class InteractionBackend {
  INyxx get client;

  void setup();

  Stream<ApiData> getStream();
  StreamController<ApiData> getStreamController();
}
