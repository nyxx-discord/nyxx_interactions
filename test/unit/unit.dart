import "package:nyxx_interactions/nyxx_interactions.dart";

import "package:test/test.dart";

// final client = NyxxFactory.createNyxxRest("dum", 0, Snowflake.zero());
final slashCommandNameRegexMatcher = matches(slashCommandNameRegex);

void main() {
  group("test utils", () {
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
  });
}
