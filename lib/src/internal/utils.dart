import 'package:nyxx/nyxx.dart';

import 'package:nyxx_interactions/src/builders/slash_command_builder.dart';
import 'package:nyxx_interactions/src/models/command_option.dart';
import 'package:nyxx_interactions/src/models/interaction_option.dart';
import 'package:nyxx_interactions/src/models/interaction.dart';

/// Slash command names and subcommands names have to match this regex
final RegExp slashCommandNameRegex = RegExp(r"^[\w-]{1,32}$");

Iterable<Iterable<T>> partition<T>(Iterable<T> list, bool Function(T) predicate) {
  final matches = <T>[];
  final nonMatches = <T>[];

  for (final e in list) {
    if (predicate(e)) {
      matches.add(e);
      continue;
    }

    nonMatches.add(e);
  }

  return [matches, nonMatches];
}

/// Determine what handler should be executed based on [interaction]
String determineInteractionCommandHandler(ISlashCommandInteraction interaction) {
  String commandHash = interaction.name;
  if (interaction.guild != null) {
    commandHash = '${interaction.guild!.id}/$commandHash';
  }

  try {
    final subCommandGroup = interaction.options.firstWhere((element) => element.type == CommandOptionType.subCommandGroup);
    final subCommand = subCommandGroup.options.firstWhere((element) => element.type == CommandOptionType.subCommand);

    return "$commandHash|${subCommandGroup.name}|${subCommand.name}";
    // ignore: empty_catches
  } on StateError {}

  try {
    final subCommand = interaction.options.firstWhere((element) => element.type == CommandOptionType.subCommand);
    return "$commandHash|${subCommand.name}";
    // ignore: empty_catches
  } on StateError {}

  return commandHash;
}

/// Groups [SlashCommandBuilder] for registering them later in bulk
Map<Snowflake, Iterable<SlashCommandBuilder>> groupSlashCommandBuilders(Iterable<SlashCommandBuilder> commands) {
  final commandsMap = <Snowflake, List<SlashCommandBuilder>>{};

  for (final slashCommand in commands) {
    final id = slashCommand.guild!;

    if (commandsMap.containsKey(id)) {
      commandsMap[id]!.add(slashCommand);
      continue;
    }

    commandsMap[id] = [slashCommand];
  }

  return commandsMap;
}

Iterable<IInteractionOption> extractArgs(Iterable<IInteractionOption> args) {
  if (args.length == 1 && (args.first.type == CommandOptionType.subCommand || args.first.type == CommandOptionType.subCommandGroup)) {
    return extractArgs(args.first.options);
  }

  return args;
}
