import 'package:mockito/mockito.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx/src/events/ready_event.dart';
import 'package:nyxx/src/events/raw_event.dart';

class NyxxWebsocketMock extends Fake implements INyxxWebsocket {
  @override
  ClientOptions get options => ClientOptions();

  @override
  IShardManager get shardManager => ShardManagerMock();

  @override
  IWebsocketEventController get eventsWs => EventsWsMock(this);
}

class EventsWsMock extends Fake implements IWebsocketEventController {
  @override
  Stream<IReadyEvent> get onReady => Stream.value(ReadyEvent(client));

  final INyxx client;

  EventsWsMock(this.client);
}

class ShardManagerMock extends Fake implements IShardManager {
  @override
  Stream<IRawEvent> get rawEvent => Stream.value(RawEvent(ShardMock(), {}));
}

class ShardMock extends Fake implements IShard {}
