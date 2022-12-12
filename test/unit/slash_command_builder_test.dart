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
    final slashCommandBuilder = SlashCommandBuilder(
      "invalid-name",
      "test",
      [],
      requiredPermissions: PermissionsConstants.administrator,
      localizationsName: {
        Locale.french: 'nom-invalide',
        Locale.german: 'unguelitger-name', // ü -> ue
      },
      localizationsDescription: {
        // Not litteral translations, just here to test if it works
        Locale.french: 'tester',
        Locale.german: 'testen',
      },
      isNsfw: true,
    );

    final expectedResult = {
      "name": "invalid-name",
      "description": "test",
      "type": SlashCommandType.chat,
      "default_permission": true, // TODO: remove when default_permission is removed
      "dm_permission": true,
      "default_member_permissions": PermissionsConstants.administrator.toString(),
      "name_localizations": {
        'fr': 'nom-invalide',
        'de': 'unguelitger-name',
      },
      "description_localizations": {
        'fr': 'tester',
        'de': 'testen',
      },
      'nsfw': true,
    };

    expect(slashCommandBuilder.build(), equals(expectedResult));
  });
}
