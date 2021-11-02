import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:nyxx_interactions/src/models/arg_choice.dart';
import 'package:nyxx_interactions/src/models/command_option.dart';
import 'package:nyxx_interactions/src/models/interaction_option.dart';
import 'package:nyxx_interactions/src/models/slash_command.dart';
import 'package:test/test.dart';

import '../mocks/nyxx_rest.mocks.dart';

main() {
  test('ArgChoice', () {
    final entity = ArgChoice({"name": "test", "value": "test1"});

    expect(entity.value, equals("test1"));
    expect(entity.name, equals("test"));
  });

  test('CommandOption', () {
    final entity = CommandOption({
      'type': 3,
      'name': 'test',
      'description': 'this is description',
      'required': false,
      'choices': [
        {"name": "test", "value": "test1"}
      ],
      'options': [
        {'type': 4, 'name': 'subOption', 'description': 'test'}
      ],
    });

    expect(entity.type, equals(CommandOptionType.string));
    expect(entity.name, equals('test'));
    expect(entity.description, equals('this is description'));
    expect(entity.required, equals(false));
    expect(entity.choices, hasLength(1));
    expect(entity.options, hasLength(1));
  });

  test('SlashCommand', () {
    final client = NyxxRestMock();

    final entity = SlashCommand({
      "id": 123,
      "application_id": 456,
      'name': 'testname',
      'description': 'testdesc',
      'type': SlashCommandType.chat.value,
      'options': [
        {'type': 4, 'name': 'subOption', 'description': 'test'}
      ],
    }, client);

    expect(entity.id, equals(Snowflake(123)));
    expect(entity.applicationId, equals(Snowflake(456)));
    expect(entity.name, equals('testname'));
    expect(entity.description, equals('testdesc'));
    expect(entity.type, equals(SlashCommandType.chat));
    expect(entity.options, hasLength(1));
    expect(entity.defaultPermissions, isTrue);
    expect(entity.guild, isNull);
  });

  test('InteractionOption options not empty', () {
    final entity = InteractionOption({
      'value': 'testval',
      'name': 'testname',
      'type': CommandOptionType.boolean.value,
      'focused': false,
      'options': [
        {'type': 4, 'name': 'subOption', 'description': 'test'}
      ],
    });

    expect(entity.value, equals('testval'));
    expect(entity.name, equals('testname'));
    expect(entity.type, equals(CommandOptionType.boolean));
    expect(entity.isFocused, equals(false));
    expect(entity.options, hasLength(1));
  });

  test('InteractionOption options empty', () {
    final entity = InteractionOption({
      'value': 'testval',
      'name': 'testname',
      'type': CommandOptionType.boolean.value,
      'focused': false,
    });

    expect(entity.value, equals('testval'));
    expect(entity.name, equals('testname'));
    expect(entity.type, equals(CommandOptionType.boolean));
    expect(entity.isFocused, equals(false));
    expect(entity.options, isEmpty);
  });
}
