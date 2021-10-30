import "package:nyxx_interactions/nyxx_interactions.dart";

import "package:test/test.dart";

void main() {
  group("arg choice builder", () {
    test("valid value string", () {
      final builder = ArgChoiceBuilder("test", "value");

      final expectedResult = {
        "name": "test",
        "value": "value",
      };

      expect(builder.build(), equals(expectedResult));
    });

    test("valid value int", () {
      final builder = ArgChoiceBuilder("test", 123);

      final expectedResult = {
        "name": "test",
        "value": 123,
      };

      expect(builder.build(), equals(expectedResult));
    });

    test("invalid value", () {
      expect(() => ArgChoiceBuilder("test", DateTime.now()), throwsA(isA<ArgumentError>()));
    });
  });
}
