import "package:nyxx_interactions/nyxx_interactions.dart";

import 'package:nyxx_interactions/src/internal/event_controller.dart';
import 'package:nyxx_interactions/src/internal/utils.dart';

import "package:test/test.dart";

// final client = NyxxFactory.createNyxxRest("dum", 0, Snowflake.zero());
final slashCommandNameRegexMatcher = matches(slashCommandNameRegex);

void main() {
  group("utils", () {
    test("test slash command regex", () {
      expect("test", slashCommandNameRegexMatcher);
      expect("Atest", slashCommandNameRegexMatcher);
      expect("test-test", slashCommandNameRegexMatcher);

      expect("test.test", isNot(slashCommandNameRegexMatcher));
      expect(".test", isNot(slashCommandNameRegexMatcher));
      expect("*test", isNot(slashCommandNameRegexMatcher));
      expect("/test", isNot(slashCommandNameRegexMatcher));
      expect("\\test", isNot(slashCommandNameRegexMatcher));
    });

    test("partition", () {
      final input = [1, 2, 7, 4, 6, 9];

      final result = partition<int>(input, (e) => e < 5);

      expect(result.first, hasLength(3));
      expect(result.last, hasLength(3));
    });

    test("event controller", () async {
      final eventController = EventController();
      expect(eventController, isA<IEventController>());

      await eventController.dispose();
      expect(eventController, isA<IEventController>());
    });
  });

  group("command sync", () {
    test("manual sync", () async {
      final manualSyncTrue = ManualCommandSync(sync: true);
      expect(await manualSyncTrue.shouldSync([]), isTrue);

      final manualSyncFalse = ManualCommandSync(sync: false);
      expect(await manualSyncFalse.shouldSync([]), isFalse);
    });
  });
}
