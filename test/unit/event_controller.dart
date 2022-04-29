import 'package:nyxx_interactions/src/internal/event_controller.dart';
import 'package:test/test.dart';

main() {
  test("event controller", () async {
    final eventController = EventController();
    expect(eventController, isA<IEventController>());

    await eventController.dispose();
    expect(eventController, isA<IEventController>());
  });
}
