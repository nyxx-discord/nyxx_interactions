import 'package:nyxx/nyxx.dart';

import 'package:nyxx_interactions/src/builders/slash_command_builder.dart';
import 'package:nyxx_interactions/src/exceptions/command_not_found.dart';
import 'package:nyxx_interactions/src/interactions.dart';
import 'package:nyxx_interactions/src/models/command_option.dart';
import 'package:nyxx_interactions/src/models/interaction_option.dart';
import 'package:nyxx_interactions/src/models/interaction.dart';
import 'package:nyxx_interactions/src/models/slash_command.dart';

/// Slash command names and subcommands names have to match this regex
final RegExp slashCommandNameRegex = RegExp(r"^[-_\p{L}\p{N}\p{sc=Deva}\p{sc=Thai}]{1,32}$", unicode: true);

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
String determineInteractionCommandHandler(ISlashCommandInteraction interaction, IInteractions interactions) {
  String commandHash = interaction.name;

  ISlashCommand triggered = interactions.commands.firstWhere(
    (command) => command.id == interaction.commandId,
    orElse: () => throw CommandNotFoundException(interaction),
  );

  if (triggered.guild != null) {
    commandHash = '${triggered.guild!.id}/$commandHash';
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
