import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:test/test.dart';

main() {
  test('.registerHandler success', () {
    final builder = CommandOptionBuilder(CommandOptionType.subCommand, 'test', 'test');

    builder.registerHandler((p0) => Future.value());
    expect(builder.handler, isA<SlashCommandHandler>());
  });

  test('.registerHandler failure', () {
    final builder = CommandOptionBuilder(CommandOptionType.user, 'test', 'test');

    expect(() => builder.registerHandler((p0) => Future.value()), throwsA(isA<StateError>()));
  });

  test('.build', () {
    final builder = CommandOptionBuilder(CommandOptionType.channel, 'test', 'test',
        choices: [
          ArgChoiceBuilder("arg1", "val1"),
        ],
        channelTypes: [
          ChannelType.text,
        ],
        autoComplete: true);

    final expectedResult = {
      "type": CommandOptionType.channel.value,
      "name": "test",
      'description': 'test',
      'default': false,
      'required': false,
      'choices': [
        {'name': 'arg1', 'value': 'val1'}
      ],
      'channel_types': [ChannelType.text],
      'autocomplete': true
    };

    expect(builder.build(), equals(expectedResult));
  });
}
