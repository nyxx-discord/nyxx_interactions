import 'package:nyxx/nyxx.dart';

import 'package:nyxx_interactions/src/builders/arg_choice_builder.dart';
import 'package:nyxx_interactions/src/models/command_option.dart';
import 'package:nyxx_interactions/src/models/locale.dart';
import 'package:nyxx_interactions/src/typedefs.dart';
import 'package:nyxx_interactions/src/builders/slash_command_builder.dart';

/// An argument for a [SlashCommandBuilder].
class CommandOptionBuilder extends Builder {
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
  final CommandOptionType type;

  /// The name of your argument / sub-group.
  final String name;

  /// The localizations name of your argument / sub-group.
  /// See [SlashCommandBuilder.localizationsName] for more information.
  final Map<Locale, String>? localizationsName;

  /// The description of your argument / sub-group.
  final String description;

  /// The localizations description of your argument / sub-group.
  /// See [SlashCommandBuilder.localizationsDescription] for more information.
  final Map<Locale, String>? localizationsDescription;

  /// If this should be the first required option the user picks
  bool defaultArg = false;

  /// If this argument is required
  bool required = false;

  /// Choices for [CommandOptionType.string], [CommandOptionType.integer] and [CommandOptionType.number] types for the user to pick from
  List<ArgChoiceBuilder>? choices;

  /// If the option is a subcommand or subcommand group type, this nested options will be the parameters
  List<CommandOptionBuilder>? options;

  /// If [type] is channel then list can be used to restrict types of channel to choose from
  List<ChannelType>? channelTypes;

  /// Set to true if option should be autocompleted
  bool autoComplete;

  SlashCommandHandler? handler;

  AutocompleteInteractionHandler? autocompleteHandler;

  /// If this is a number option ([CommandOptionType.integer] or [CommandOptionType.number]), the minimum value the user can input.
  num? min;

  /// If this is a number option ([CommandOptionType.integer] or [CommandOptionType.number]), the minimum value the user can input.
  num? max;

  /// Used to create an argument for a [SlashCommandBuilder].
  CommandOptionBuilder(
    this.type,
    this.name,
    this.description, {
    this.defaultArg = false,
    this.required = false,
    this.choices,
    this.options,
    this.channelTypes,
    this.autoComplete = false,
    this.min,
    this.max,
    this.localizationsName,
    this.localizationsDescription,
  });

  /// Registers handler for subcommand
  void registerHandler(SlashCommandHandler handler) {
    if (type != CommandOptionType.subCommand) {
      throw StateError("Cannot register handler for command option with type other that subcommand");
    }

    this.handler = handler;
  }

  void registerAutocompleteHandler(AutocompleteInteractionHandler handler) {
    if (choices != null || options != null) {
      throw ArgumentError("Autocomplete cannot be set if choices or options are present");
    }

    autocompleteHandler = handler;
    autoComplete = true;
  }

  @override
  RawApiMap build() => {
        "type": type.value,
        "name": name,
        "description": description,
        "default": defaultArg,
        "required": required,
        if (choices != null) "choices": choices!.map((e) => e.build()).toList(),
        if (options != null) "options": options!.map((e) => e.build()).toList(),
        if (channelTypes != null && type == CommandOptionType.channel) "channel_types": channelTypes!.map((e) => e.value).toList(),
        if (min != null) "min_value": min,
        if (max != null) "max_value": max,
        if (localizationsName != null) "name_localizations": localizationsName!.map((k, v) => MapEntry<String, String>(k.toString(), v)),
        if (localizationsDescription != null) "description_localizations": localizationsDescription!.map((k, v) => MapEntry<String, String>(k.toString(), v)),
        "autocomplete": autoComplete,
      };
}
