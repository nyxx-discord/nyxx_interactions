import 'package:nyxx/nyxx.dart';
import "package:nyxx_interactions/nyxx_interactions.dart";

import "package:test/test.dart";

void main() {
  test("invalid name", () {
    expect(() => SlashCommandBuilder("invalid name", "test", []), throwsA(isA<ArgumentError>()));
  });

  test("missing description", () {
    expect(() => SlashCommandBuilder("invalid-name", null, []), throwsA(isA<ArgumentError>()));
  });

  test("description present for context menu", () {
    expect(() => SlashCommandBuilder("invalid-name", "test", [], type: SlashCommandType.user), throwsA(isA<ArgumentError>()));
  });

  test(".setId", () {
    final slashCommandBuilder = SlashCommandBuilder("invalid-name", "test", []);

    expect(() => slashCommandBuilder.id, throwsA(isA<Error>()));

    slashCommandBuilder.setId(Snowflake.zero());
    expect(slashCommandBuilder.id, equals(Snowflake.zero()));
  });

  test(".addPermission", () {
    final slashCommandBuilder = SlashCommandBuilder("invalid-name", "test", []);

    slashCommandBuilder
      ..addPermission(RoleCommandPermissionBuilder(Snowflake.zero()))
      ..addPermission(UserCommandPermissionBuilder(Snowflake.bulk()));

    expect(slashCommandBuilder.permissions, isNotNull);
    expect(slashCommandBuilder.permissions, hasLength(2));
  });

  test('.registerHandler failure', () {
    final slashCommandBuilder = SlashCommandBuilder("invalid-name", "test", [CommandOptionBuilder(CommandOptionType.subCommand, "test", 'test')]);

    expect(() => slashCommandBuilder.registerHandler((p0) => Future.value()), throwsA(isA<ArgumentError>()));
  });

  test('.registerHandler success', () {
    final slashCommandBuilder = SlashCommandBuilder("invalid-name", "test", []);

    slashCommandBuilder.registerHandler((p0) => Future.value());
    expect(slashCommandBuilder.handler, isA<SlashCommandHandler>());
  });

  test('.build', () {
    final slashCommandBuilder = SlashCommandBuilder("invalid-name", "test", []);

    final expectedResult = {
      "name": "invalid-name",
      "description": "test",
      "type": SlashCommandType.chat,
      "default_permission": true,
    };

    expect(slashCommandBuilder.build(), equals(expectedResult));
  });
}
