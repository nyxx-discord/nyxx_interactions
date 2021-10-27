import 'package:nyxx/nyxx.dart';

import 'package:nyxx_interactions/src/models/command_option.dart';

abstract class IInteractionOption {
  /// The value given by the user
  dynamic get value;

  /// Type of interaction
  CommandOptionType get type;

  /// Name of option
  String get name;

  /// Any args under this as you can have sub commands
  Iterable<InteractionOption> get options;

  /// True if options is focused
  bool get isFocused;
}

/// The option given by the user when sending a command
class InteractionOption implements IInteractionOption {
  /// The value given by the user
  @override
  late final dynamic value;

  /// Type of interaction
  @override
  late final CommandOptionType type;

  /// Name of option
  @override
  late final String name;

  /// Any args under this as you can have sub commands
  @override
  late final Iterable<InteractionOption> options;

  /// True if options is focused
  @override
  late final bool isFocused;

  /// Creates na instance of [InteractionOption]
  InteractionOption(RawApiMap raw) {
    value = raw["value"] as dynamic;
    name = raw["name"] as String;
    type = CommandOptionType(raw["type"] as int);

    if (raw["options"] != null) {
      options = (raw["options"] as List<dynamic>).map((e) => InteractionOption(e as RawApiMap));
    } else {
      options = [];
    }

    isFocused = raw["focused"] as bool? ?? false;
  }
}
