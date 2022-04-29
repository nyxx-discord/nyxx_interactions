import 'package:nyxx_interactions/src/internal/utils.dart';

import "package:test/test.dart";

final slashCommandNameRegexMatcher = matches(slashCommandNameRegex);

void main() {
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
}
