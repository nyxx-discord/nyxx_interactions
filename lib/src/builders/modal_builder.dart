import 'package:nyxx/nyxx.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

class ModalBuilder implements Builder {
  /// Your identifier for modal
  String customId;

  /// User facing title for modal
  String title;

  /// Components for modal
  List<ComponentRowBuilder> componentRows = [];

  ModalBuilder(this.customId, this.title);

  @override
  RawApiMap build() => {
        "title": title,
        "custom_id": customId,
        if (componentRows.isNotEmpty) "components": [for (final row in componentRows) row.build()]
      };
}
