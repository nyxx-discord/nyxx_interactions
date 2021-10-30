import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';
import 'package:test/test.dart';

import '../mocks/nyxx_rest.mocks.dart';

main() {
  final client = NyxxRestMock();

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

    expect(messageBuilder.build(client), equals(expectedResult));
  });
}
