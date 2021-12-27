import 'package:nyxx/nyxx.dart';

import 'package:nyxx_interactions/src/models/arg_choice.dart';

/// The type that a user should input for a [CommandOptionBuilder]
class CommandOptionType extends IEnum<int> {
  /// Specify an arg as a sub command
  static const subCommand = CommandOptionType(1);

  /// Specify an arg as a sub command group
  static const subCommandGroup = CommandOptionType(2);

  /// Specify an arg as a string
  static const string = CommandOptionType(3);

  /// Specify an arg as an int
  static const integer = CommandOptionType(4);

  /// Specify an arg as a bool
  static const boolean = CommandOptionType(5);

  /// Specify an arg as a user e.g @HarryET#2954
  static const user = CommandOptionType(6);

  /// Specify an arg as a channel e.g. #Help
  static const channel = CommandOptionType(7);

  /// Specify an arg as a role e.g. @RoleName
  static const role = CommandOptionType(8);

  /// Specify an arg as a mentionable user or role
  static const mentionable = CommandOptionType(9);

  /// Specify an arg as a double
  static const number = CommandOptionType(10);

  /// Create new instance of CommandArgType
  const CommandOptionType(int value) : super(value);
}

abstract class ICommandOption {
  /// The type of arg that will be later changed to an INT value, their values can be seen in the table below:
  /// | Name              | Value |
  /// |-------------------|-------|
  /// | SUB_COMMAND       | 1     |
  /// | SUB_COMMAND_GROUP | 2     |
  /// | STRING            | 3     |
  /// | INTEGER           | 4     |
  /// | BOOLEAN           | 5     |
  /// | USER              | 6     |
  /// | CHANNEL           | 7     |
  /// | ROLE              | 8     |
  CommandOptionType get type;

  /// The name of your argument / sub-group.
  String get name;

  /// The description of your argument / sub-group.
  String get description;

  /// If this argument is required
  bool get required;

  /// Choices for [CommandOptionType.string] and [CommandOptionType.string] types for the user to pick from
  List<IArgChoice> get choices;

  /// If the option is a subcommand or subcommand group type, this nested options will be the parameters
  List<ICommandOption> get options;
}

/// An argument for a [SlashCommand].
class CommandOption implements ICommandOption {
  /// The type of arg that will be later changed to an INT value, their values can be seen in the table below:
  /// | Name              | Value |
  /// |-------------------|-------|
  /// | SUB_COMMAND       | 1     |
  /// | SUB_COMMAND_GROUP | 2     |
  /// | STRING            | 3     |
  /// | INTEGER           | 4     |
  /// | BOOLEAN           | 5     |
  /// | USER              | 6     |
  /// | CHANNEL           | 7     |
  /// | ROLE              | 8     |
  @override
  late final CommandOptionType type;

  /// The name of your argument / sub-group.
  @override
  late final String name;

  /// The description of your argument / sub-group.
  @override
  late final String description;

  /// If this argument is required
  @override
  late final bool required;

  /// Choices for [CommandOptionType.string] and [CommandOptionType.string] types for the user to pick from
  @override
  late final List<IArgChoice> choices;

  /// If the option is a subcommand or subcommand group type, this nested options will be the parameters
  @override
  late final List<ICommandOption> options;

  /// Creates na instance of [CommandOption]
  CommandOption(RawApiMap raw) {
    type = CommandOptionType(raw["type"] as int);
    name = raw["name"] as String;
    description = raw["description"] as String;
    required = raw["required"] as bool? ?? false;

    choices = [
      if (raw["choices"] != null)
        for (final choiceRaw in raw["choices"]) ArgChoice(choiceRaw as RawApiMap)
    ];

    options = [
      if (raw["options"] != null)
        for (final optionRaw in raw["options"]) CommandOption(optionRaw as RawApiMap)
    ];
  }
}
