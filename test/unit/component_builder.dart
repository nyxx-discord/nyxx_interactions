import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:test/test.dart';

main() {
  test("components", () {
    final customButton = ButtonBuilder("label", "customId", ComponentStyle.secondary);
    final linkButton = LinkButtonBuilder("label2", "discord://-/");
    final multiselect = MultiselectBuilder("customId2", [MultiselectOptionBuilder("label1", "value1", true)]);

    final componentRow = ComponentRowBuilder()
      ..addComponent(customButton)
      ..addComponent(linkButton);

    final secondComponentRow = ComponentRowBuilder()..addComponent(multiselect);

    final messageBuilder = ComponentMessageBuilder()
      ..addComponentRow(componentRow)
      ..addComponentRow(secondComponentRow)
      ..content = "test content";

    final expectedResult = {
      'content': "test content",
      'components': [
        {
          'type': 1,
          'components': [
            {'type': 2, 'label': 'label', 'style': 2, 'custom_id': 'customId'},
            {'type': 2, 'label': 'label2', 'style': 5, 'url': 'discord://-/'}
          ]
        },
        {
          'type': 1,
          'components': [
            {
              'type': 3,
              'custom_id': 'customId2',
              'options': [
                {'label': 'label1', 'value': 'value1', 'default': true}
              ]
            }
          ]
        }
      ]
    };

    expect(messageBuilder.build(), equals(expectedResult));
  });

  test("MultiselectOptionBuilder emoji unicode", () {
    final builder = MultiselectOptionBuilder("test", 'test')..emoji = UnicodeEmoji('😂');

    final expectedResult = {
      'label': 'test',
      'value': 'test',
      'default': false,
      'emoji': {'name': '😂'}
    };

    expect(builder.build(), equals(expectedResult));
  });

  test("MultiselectOptionBuilder emoji unicode", () {
    final builder = MultiselectOptionBuilder("test", 'test')..emoji = IBaseGuildEmoji.fromId(Snowflake.zero());

    final expectedResult = {
      'label': 'test',
      'value': 'test',
      'default': false,
      'emoji': {'id': '0'}
    };

    expect(builder.build(), equals(expectedResult));
  });

  test('ComponentMessageBuilder component rows', () {
    final messageBuilder = ComponentMessageBuilder();

    expect(() => messageBuilder.addComponentRow(ComponentRowBuilder()), throwsA(isA<ArgumentError>()));

    messageBuilder
      ..addComponentRow(ComponentRowBuilder()..addComponent(LinkButtonBuilder('test', 'test')))
      ..addComponentRow(ComponentRowBuilder()..addComponent(LinkButtonBuilder('test', 'test')))
      ..addComponentRow(ComponentRowBuilder()..addComponent(LinkButtonBuilder('test', 'test')))
      ..addComponentRow(ComponentRowBuilder()..addComponent(LinkButtonBuilder('test', 'test')))
      ..addComponentRow(ComponentRowBuilder()..addComponent(LinkButtonBuilder('test', 'test')));

    expect(() => messageBuilder.addComponentRow(ComponentRowBuilder()..addComponent(LinkButtonBuilder('test', 'test'))), throwsA(isA<ArgumentError>()));
  });

  test("ButtonBuilder label length", () {
    expect(
        () => ButtonBuilder(
            'Fusce accumsan sit amet neque vitae viverra. Sed leo est, finibus ut velit at, commodo vestibulum nulla metus.', 'test', ComponentStyle.secondary),
        throwsA(isA<ArgumentError>()));
  });

  test("ButtonBuilder customId length", () {
    expect(
        () => ButtonBuilder(
            'test', 'Fusce accumsan sit amet neque vitae viverra. Sed leo est, finibus ut velit at, commodo vestibulum nulla metus.', ComponentStyle.secondary),
        throwsA(isA<ArgumentError>()));
  });

  test('MultiselectBuilder', () {
    expect(() => MultiselectBuilder('Fusce accumsan sit amet neque vitae viverra. Sed leo est, finibus ut velit at, commodo vestibulum nulla metus.'),
        throwsA(isA<ArgumentError>()));

    final builder = MultiselectBuilder("test")..addOption(MultiselectOptionBuilder("label", "value"));

    expect(builder.options, hasLength(1));
  });

  test("LinkButtonBuilder url length", () {
    const url = """
Morbi non laoreet nulla, mollis suscipit nisi. Aenean vestibulum vehicula auctor. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Maecenas ullamcorper viverra aliquam. Duis sit amet nisl at libero blandit sagittis. Fusce quis faucibus libero. Quisque luctus est enim, quis efficitur sapien mollis eu.
Suspendisse aliquet volutpat ante eu ornare. Etiam ante erat, pulvinar vel justo sed, mollis rhoncus lacus. Nulla cursus, dolor et luctus cursus, diam tortor volutpat ex, et volutpat posuere.
    """;

    expect(() => LinkButtonBuilder('test', url), throwsA(isA<ArgumentError>()));
  });

  test("ButtonBuilder emoji", () {
    final builder = ButtonBuilder("label", "customId", ComponentStyle.primary)..emoji = UnicodeEmoji('😂');

    final expectedResult = {
      'type': 2,
      'label': 'label',
      'style': 1,
      'emoji': {'name': '😂'},
      'custom_id': 'customId'
    };

    expect(builder.build(), equals(expectedResult));
  });
}
